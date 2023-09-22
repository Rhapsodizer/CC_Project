from tkinter import filedialog
import os
import pygame
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


def open_rap_window(using_root):  # todo: add loop_duration as parameter
    rap_window = tk.Toplevel(using_root)
    rap_window.geometry("1024x512")
    rap_window.config(bg="#DCDCDC")
    rap_window.resizable(width=False, height=False)
    rap = RecorderAndPlayer(rap_window)
    rap.draw_all()
    rap.set_loop_duration(5)


class RecorderAndPlayer:
    def __init__(self, window):
        # super().__init__("Rec and Play")
        self.window = window
        self.c_width = 1024
        self.c_tb_height = 200
        self.c_height = 256
        self.toolbar_canvas = tk.Canvas(self.window, width=self.c_width, height=self.c_tb_height, bg="#DCDCDC")
        self.toolbar_canvas.place(x=0, y=0)
        self.canvas = tk.Canvas(self.window, width=self.c_width, height=self.c_height, bg="#B4B4B4")
        self.canvas.place(x=0, y=256)
        self.loop_duration = 0  # in seconds
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
        self.audio_data = []
        self.show_audio_data = []
        self.is_playing = False
        self.is_recording = False
        self.has_finished_recording = False
        self.recorder = None
        # self.expected_lag = 0.5
        dirname = os.path.dirname(__file__)
        print(dirname)
        self.recorded_filename = "recorded_audio.wav"
        self.recorded_file_path = os.path.join(dirname, "./recorded_audio.wav")
        self.frame_length = 256
        self.tc_height = 52
        self.tc_width = 256
        self.time_canvas = tk.Canvas(self.window, width=self.tc_width, height=self.tc_height, bg="#B4B4B4")
        self.time_canvas.place(x=self.c_width/2 - self.tc_width/2, y=201)
        self.audio_time = 0.0
        self.zero_time = 0.0
        # Initialize pygame for audio playback
        pygame.mixer.init()

    def plus_clicked(self, event):
        # print("plus")
        self.audio_data = []
        self.show_audio_data = []
        self.loaded = False
        self.reset_time()
        self.draw_all()
        self.choose_file(event)

    def record_clicked(self, event):
        print(event)
        self.audio_data = []
        self.show_audio_data = []
        self.loaded = False
        self.reset_time()
        self.recorder = PvRecorder(device_index=-1, frame_length=self.frame_length)
        self.recorder.start()
        thread = Thread(target=self.record_mic)
        thread.start()

    def set_loop_duration(self, new_loop_duration_in_seconds):
        self.loop_duration = new_loop_duration_in_seconds
        # print(self.loop_duration)

    def draw_toolbar(self):
        [record_rect, record_circle, plus, p, s] = utils.draw_toolbar(self)
        self.toolbar_canvas.tag_bind(record_rect, "<Button-1>", self.record_clicked)
        self.toolbar_canvas.tag_bind(record_circle, "<Button-1>", self.record_clicked)
        self.toolbar_canvas.tag_bind(plus, "<Button-1>", self.plus_clicked)
        self.toolbar_canvas.tag_bind(p, "<Button-1>", self.pf)
        self.toolbar_canvas.tag_bind(s, "<Button-1>", self.sf)

    def draw_time_bar(self):
        utils.draw_time_bar(self)

    def draw_visual(self):
        self.canvas.delete("all")
        if self.loaded:
            # self.canvas.delete("all")
            duration_time_in_ms = int(self.loop_duration * 1000)
            # cut the audio segment so that lasts N seconds, where N is given by the spinbox
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
        self.reset_time()
        print(event)
        self.audio_file = filedialog.askopenfilename(
            parent=self.window,
            filetypes=[("MP3 Files", "*.mp3"), ("WAV Files", "*.wav")])
        if self.audio_file:
            audio_segment = AudioSegment.from_mp3(self.audio_file)
            self.values_of_audio_segment = audio_segment.get_array_of_samples()
            self.file_title = os.path.basename(self.audio_file)
            # self.file_name = file_title
            self.loaded = True
            self.draw_all()

    def pf(self, event):
        self.play_file_in_thread()

    def sf(self, event):
        self.stop_file()

    def play_audio(self):
        pygame.mixer.music.load(self.audio_file)
        pygame.mixer.music.play()

    def stop_file(self):
        pygame.mixer.music.stop()
        self.is_playing = False
        self.reset_time()
        self.visualize_amplitude()

    def loop_file(self):
        self.stop_file()
        self.play_file_in_thread()

    def visualize_amplitude(self):
        if len(self.audio_data) > 0:
            # print(len(self.audio_data))
            dim = self.c_width / len(self.audio_data)

            max_amplitude = np.max(self.audio_data)
            min_amplitude = np.min(self.audio_data)

            new_max = self.c_height * 0.5
            new_min = 0
            audio_data_normalized = []
            for i, amplitude in enumerate(self.audio_data):
                audio_data_normalized.append((self.audio_data[i] - min_amplitude) * (new_max - new_min) /
                                             (max_amplitude - min_amplitude) + new_min)

            for i, amplitude in enumerate(audio_data_normalized):
                x = i * dim
                y = amplitude
                self.canvas.create_rectangle(x, self.c_height * 0.5 - y / 2,
                                             x + float(dim), self.c_height * 0.5 + y / 2, fill="#8C8C8C")

            self.show_audio_data = audio_data_normalized
        else:
            print("setup error")
            # todo window error

    def play_file_in_thread(self):
        self.reset_time()
        self.zero_time = time.time()
        if len(self.show_audio_data) > 0:
            dim = self.c_width / len(self.show_audio_data)
            if self.audio_file != "":
                self.is_playing = True

                audio_thread = threading.Thread(target=self.play_audio)
                audio_thread.start()

                display_thread = threading.Thread(target=self.draw_file,
                                                  args=(dim, 0))
                display_thread.start()
        else:
            print("setup error")
            # todo window error

    def draw_file(self, dim, i):
        if i < len(self.show_audio_data) and self.is_playing:
            amplitude = self.show_audio_data[i]
            x = i * dim
            y = amplitude
            self.canvas.create_rectangle(x, self.c_height * 0.5 - y / 2,
                                         x + float(dim), self.c_height * 0.5 + y / 2, fill="#000000")
            self.canvas.update()  # Update the canvas to show the rectangle

            time.sleep(self.waiting_time / 1000)  # in seconds
            self.audio_time = time.time() - self.zero_time
            self.draw_time_bar()

            self.draw_file(dim, i + 1)
        elif self.is_playing:
            self.loop_file()

    def record_mic(self):
        self.canvas.delete("all")
        self.loaded = False
        self.draw_toolbar()
        # print("Recording started...")
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
                self.draw_while_recording(dim=self.c_width/(self.loop_duration*100), frame=frame, i=i)
                self.audio_time = time.time() - start_time
                self.draw_time_bar()
                i += 1
        finally:
            self.recorder.stop()
            with wave.open(self.recorded_file_path, 'w') as f:
                f.setparams((1, 2, 16000, self.frame_length, "NONE", "NONE"))
                f.writeframes(struct.pack("h" * len(audio), *audio))

            # print("Recording saved as", self.recorded_file_path)
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
        self.audio_time = 0.0
        self.draw_time_bar()
