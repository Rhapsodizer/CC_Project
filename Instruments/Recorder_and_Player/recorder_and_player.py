from tkinter import filedialog
from pydub import AudioSegment
import numpy as np
import threading
import tkinter as tk
from threading import Thread
from pvrecorder import PvRecorder
import wave
import struct
import time
from Utils import utils
from Utils.error_manager import ErrorWindow
from pythonosc import dispatcher, osc_server
import os
os.environ['PYGAME_HIDE_SUPPORT_PROMPT'] = 'hide'
import pygame


def open_rap_window(tr_parent):
    rap = RecorderAndPlayer(tr_parent)

    # Create a dispatcher instance
    dispatcher_instance = dispatcher.Dispatcher()
    dispatcher_instance.map("/action", lambda addr, *args: handle_osc_message(addr, args, rap))

    # Start an OSC server to listen for messages
    server = osc_server.ThreadingOSCUDPServer(('127.0.0.1', 5006), dispatcher_instance)
    server_thread = Thread(target=server.serve_forever)
    server_thread.daemon = True
    server_thread.start()


class RecorderAndPlayer:
    def __init__(self, tr_parent):
        self.track_parent = tr_parent
        self.window = tk.Toplevel(self.track_parent.window)
        self.window.geometry("1024x512")
        self.window.config(bg="#DCDCDC")
        self.window.title("Recorder and Player")
        self.window.resizable(width=False, height=False)
        self.c_width = 1024
        self.c_tb_height = 200
        self.c_height = 256
        self.toolbar_canvas = tk.Canvas(self.window, width=self.c_width, height=self.c_tb_height, bg="#DCDCDC")
        self.toolbar_canvas.place(x=0, y=0)
        self.ampl_c_width = self.c_width - 40
        self.ampl_c_height = self.c_height - 20
        self.ampl_c_pos_x = 20
        self.ampl_c_pos_y = 1
        self.canvas = tk.Canvas(self.window, width=self.c_width, height=self.c_height, bg="#DCDCDC")
        self.canvas.place(x=0, y=254)
        self.bpm = self.track_parent.ls_parent.bpm
        self.steps = self.track_parent.ls_parent.steps
        self.loop_duration = 60/self.bpm * self.steps  # in seconds
        self.loaded = False
        self.toolbar_pos_x = 20
        self.toolbar_pos_y = 20
        self.toolbar_length = self.c_width - 40
        self.toolbar_height = self.c_tb_height - 20
        self.toolbar_color = "#B4B4B4"
        self.file_title = ""
        self.audio_file = None
        self.values_of_audio_segment = None
        self.waiting_time = 10  # ms
        self.discrete_time_instant = 0
        self.audio_data = []
        self.show_audio_data = []
        self.is_playing = False
        self.is_recording = False
        self.has_finished_recording = False
        self.recorder = None
        # self.expected_lag = 0.5
        dirname = os.path.dirname(__file__)
        self.recorded_filename = "recorded_audio.wav"
        self.recorded_file_path = os.path.join(dirname, "./recorded_audio.wav")
        self.frame_length = 256
        self.tc_height = 52
        self.tc_width = 256
        self.time_canvas = tk.Canvas(self.window, width=self.tc_width, height=self.tc_height, bg="#B4B4B4")
        self.time_canvas.place(x=self.c_width/2 - self.tc_width/2, y=201)
        self.audio_time = 0.00
        self.zero_time = 0.00
        self.has_already_received_play = False
        self.draw_all()
        # Initialize pygame for audio playback
        pygame.mixer.init()

    def plus_clicked(self, event):
        self.audio_data = []
        self.show_audio_data = []
        self.loaded = False
        self.reset_time()
        self.draw_all()
        self.choose_file(event)

    def record_clicked(self, event):
        _ = event
        if not self.is_recording:
            self.audio_data = []
            self.show_audio_data = []
            self.loaded = False
            self.reset_time()
            self.recorder = PvRecorder(device_index=-1, frame_length=self.frame_length)
            self.recorder.start()
            thread = Thread(target=self.record_mic)
            thread.start()

    # def calculate_loop_duration(self):
    #     loop_dur = 60/self.bpm * self.steps
    #     print(loop_dur)
    #     return loop_dur

    def draw_toolbar(self):
        [record_rect, record_circle, plus] = utils.draw_toolbar_rap(self)
        self.toolbar_canvas.tag_bind(record_rect, "<Button-1>", self.record_clicked)
        self.toolbar_canvas.tag_bind(record_circle, "<Button-1>", self.record_clicked)
        self.toolbar_canvas.tag_bind(plus, "<Button-1>", self.plus_clicked)

    def draw_time_bar(self):
        utils.draw_time_bar_rap(self)

    def draw_visual(self):
        self.canvas.delete("all")
        # Draw ampl container
        utils.round_rectangle(self.canvas,
                              self.ampl_c_pos_x, self.ampl_c_pos_y,
                              self.ampl_c_pos_x + self.ampl_c_width, self.ampl_c_pos_y + self.ampl_c_height,
                              radius=20, fill_color=self.toolbar_color, outline_color="#000000")
        if self.loaded:
            # self.canvas.delete("all")
            duration_time_in_ms = int(self.loop_duration * 1000)
            # cut the audio segment so that lasts N seconds
            cut_audio_segment = self.values_of_audio_segment[:duration_time_in_ms]
            # Capture amplitude every 100 ms
            for t in range(0, len(cut_audio_segment), self.waiting_time):
                self.audio_data.append(np.max(np.abs(cut_audio_segment[t:t + self.waiting_time])))

            self.visualize_amplitude()

    def draw_all(self):
        self.draw_toolbar()
        self.draw_time_bar()
        self.draw_visual()

    def choose_file(self, event):
        _ = event
        self.reset_time()
        self.audio_file = filedialog.askopenfilename(
            parent=self.window,
            filetypes=[("MP3 Files", "*.mp3"), ("WAV Files", "*.wav")])
        if self.audio_file:
            audio_segment = AudioSegment.from_mp3(self.audio_file)
            self.values_of_audio_segment = audio_segment.get_array_of_samples()
            self.file_title = os.path.basename(self.audio_file)
            self.loaded = True
            self.track_parent.instrument_is_ready = True
            self.draw_all()

    def play_audio(self):
        print("in play audio")
        pygame.mixer.music.load(self.audio_file)
        pygame.mixer.music.play()
        # pygame.mixer.music.pause()
        # pygame.mixer.music.unpause()

    def stop_file(self):
        pygame.mixer.music.stop()
        self.has_already_received_play = False
        self.reset_time()
        self.visualize_amplitude()

    def loop_file(self):
        self.reset_time()
        self.visualize_amplitude()
        self.has_already_received_play = False

    def visualize_amplitude(self):
        if len(self.audio_data) > 0:
            dim = self.ampl_c_width / len(self.audio_data)
            max_amplitude = np.max(self.audio_data)
            min_amplitude = np.min(self.audio_data)

            new_max = self.c_height * 0.5
            new_min = 0
            audio_data_normalized = []
            for i, amplitude in enumerate(self.audio_data):
                audio_data_normalized.append((self.audio_data[i] - min_amplitude) * (new_max - new_min) /
                                             (max_amplitude - min_amplitude) + new_min)

            for i, amplitude in enumerate(audio_data_normalized):
                x = self.ampl_c_pos_x + i * dim
                y = amplitude
                self.canvas.create_rectangle(x, self.c_height * 0.5 - y / 2,
                                             x + float(dim), self.c_height * 0.5 + y / 2,
                                             fill="#8C8C8C", outline="#8C8C8C")

            self.show_audio_data = audio_data_normalized
        else:
            ErrorWindow("Setup Error", "Error: Setup Error")

    def play_file_in_thread(self):
        self.reset_time()
        self.zero_time = time.time()
        if len(self.show_audio_data) > 0:
            dim = self.ampl_c_width / len(self.show_audio_data)
            if self.audio_file != "":
                self.is_playing = True
                self.discrete_time_instant = 0

                audio_thread = threading.Thread(target=self.play_audio)
                audio_thread.start()

                display_thread = threading.Thread(target=self.draw_file, args=[dim])
                display_thread.start()
        else:
            ErrorWindow("Setup Error", "Error: Setup Error")

    def draw_file(self, dim):
        if self.has_already_received_play:
            amplitude = self.show_audio_data[self.discrete_time_instant]
            x = self.ampl_c_pos_x + self.discrete_time_instant * dim
            y = amplitude
            self.canvas.create_rectangle(x, self.c_height * 0.5 - y / 2,
                                         x + float(dim), self.c_height * 0.5 + y / 2, fill="#000000")
            self.canvas.update()
            self.draw_time_bar()
            i = self.audio_time * 100
            while i < self.discrete_time_instant:
                self.audio_time = round(round(time.time(), 2) - self.zero_time, 2)
                i = self.audio_time * 100
                print(i)
            self.discrete_time_instant += 1
            if self.discrete_time_instant < len(self.show_audio_data):
                if self.audio_time < self.loop_duration:
                    self.draw_file(dim)
                else:
                    print("in else")
                    # in order to loop back, wait for the next "play" msg
                    # from the routine
                    self.loop_file()

    def record_mic(self):
        self.canvas.delete("all")
        self.loaded = False
        self.draw_toolbar()
        audio = []
        self.is_recording = True
        self.draw_toolbar()
        try:
            # Wait for the expected lag time #
            # time.sleep(self.expected_lag)

            start_time = time.time()
            i = 0
            while time.time() - start_time < self.loop_duration:
                frame = self.recorder.read()
                audio.extend(frame)
                self.draw_while_recording(dim=self.ampl_c_width/(self.loop_duration*100), frame=frame, i=i)
                self.audio_time = time.time() - start_time
                self.draw_time_bar()
                i += 1
        finally:
            self.recorder.stop()
            with wave.open(self.recorded_file_path, 'w') as f:
                f.setparams((1, 2, 16000, self.frame_length, "NONE", "NONE"))
                f.writeframes(struct.pack("h" * len(audio), *audio))

            self.is_recording = False
            self.has_finished_recording = True
            self.draw_toolbar()
            time.sleep(2)
            self.has_finished_recording = False
            self.canvas.delete("all")
            self.reset_time()
            self.draw_toolbar()

    def draw_while_recording(self, dim, frame, i):
        amplitude = frame[0]

        new_max = self.c_height * 0.5
        new_min = 0
        amplitude_normalized = amplitude * (new_max - new_min) / (self.c_height + new_min)

        x = i * dim
        y = amplitude_normalized
        self.canvas.create_rectangle(x, self.c_height * 0.5 - y / 2,
                                     x + float(dim), self.c_height * 0.5 + y / 2, fill="#000000")
        self.canvas.update()  # Update the canvas to show the rectangle
        time.sleep(self.waiting_time / 1000)  # in seconds

    def reset_time(self):
        self.audio_time = 0.00
        self.discrete_time_instant = 0.00
        self.draw_time_bar()


def handle_osc_message(address: str, args: tuple, rap: RecorderAndPlayer):
    # print("5")
    if address == '/action':
        if args:
            # new_color = args[0]  # Assuming the color is the first argument
            # rap.received_msg(args[0])
            if args[0] == 'play':
                if not rap.has_already_received_play:
                    rap.has_already_received_play = True
                    rap.play_file_in_thread()
            else:
                rap.stop_file()
