from threading import Thread
from Utils import utils
from pythonosc import dispatcher, osc_server
import tkinter as tk
from tkinter import filedialog
from PIL import Image, ImageTk
import random
from numpy import interp
import simpleaudio as sa
import numpy as np
from Utils.error_manager import ErrorWindow


def open_image_son_window(tr_parent):
    img_son = ImageSonification(tr_parent)

    # Create a dispatcher instance
    dispatcher_instance = dispatcher.Dispatcher()
    dispatcher_instance.map("/extract", lambda addr, *args: handle_osc_message(addr, args, img_son))

    # Start an OSC server to listen for messages
    server = osc_server.ThreadingOSCUDPServer(('127.0.0.1', tr_parent.port), dispatcher_instance)
    server_thread = Thread(target=server.serve_forever)
    server_thread.daemon = True
    server_thread.start()


class ImageSonification:
    def __init__(self, tr_parent):
        self.track_parent = tr_parent
        self.window = tk.Toplevel(self.track_parent.window)
        self.window.geometry("512x512")
        self.window.config(bg="#DCDCDC")
        self.window.title("Image Sonification")
        self.window.resizable(width=False, height=False)
        self.c_width = 512
        self.c_height = 512
        self.canvas = tk.Canvas(self.window, width=self.c_width, height=self.c_height, bg="#808080")
        self.canvas.place(x=0, y=0)
        self.img_sides = 300
        self.img_pos_x = self.c_width/2 - 151
        self.img_pos_y = self.c_height / 2 - 151
        self.image = None
        self.pil = None
        self.extracted = []
        self.curStep = 0
        self.major_scale_2oct = [0, 2, 4, 5, 7, 9, 11, 12, 14, 15, 17, 19, 21, 23]
        self.tonalities = ["C2", "C#/Db2", "D2", "D#/Eb2", "E2", "F2",
                           "F#/Gb2", "G2", "G#/Ab2", "A2", "A#/Bb2", "B2",
                           "C3", "C#/Db3", "D3", "D#/Eb3", "E3", "F3",
                           "F#/Gb3", "G3", "G#/Ab3", "A3", "A#/Bb3", "B3",
                           "C4"]
        self.fundamental_frequencies = [
            65.40639, 69.29566, 73.41619, 77.78175, 82.40689, 87.30706,
            92.49861, 97.99886, 103.8262, 110.0000, 116.5409, 123.4708,
            130.8128, 138.5913, 146.8324, 155.5635, 164.8138, 174.6141,
            184.9972, 195.9977, 207.6523, 220.0000, 233.0819, 246.9417,
            261.6256]
        self.curr_ton = 0
        self.ton = self.tonalities[self.curr_ton]
        self.ton_is_valid = False
        self.fund_freq = self.fundamental_frequencies[0]
        self.base_freq = 0
        self.duration = 60 / self.track_parent.ls_parent.bpm  # in secs
        self.harmonics_count = 10
        self.play_note_thread = None
        self.is_playing = False
        self.image_on_setup()
        self.draw_all_is()

    def draw_all_is(self):
        [plus, up_ton_triangle, down_ton_triangle, ton_valid_rect] = utils.draw_all_is(self)
        self.canvas.tag_bind(plus, "<Button-1>", self.load_image)
        self.canvas.tag_bind(up_ton_triangle, "<Button-1>", self.ton_up_clicked)
        self.canvas.tag_bind(down_ton_triangle, "<Button-1>", self.ton_down_clicked)
        self.canvas.tag_bind(ton_valid_rect, "<Button-1>", self.ton_valid_clicked)

    def ton_up_clicked(self, event):
        _ = event
        if not self.is_playing:
            if self.curr_ton < len(self.tonalities):
                self.curr_ton += 1
                self.ton = self.tonalities[self.curr_ton]
                self.fund_freq = self.fundamental_frequencies[self.curr_ton]
            self.ton_is_valid = False
            self.track_parent.instrument_is_ready = False
            self.track_parent.this_is_booked = False
            if self in self.track_parent.ls_parent.booked_tracks:
                index = self.track_parent.ls_parent.booked_tracks.index(self)
                self.track_parent.ls_parent.booked_tracks.pop(index)
            self.track_parent.draw_track()
            self.draw_all_is()

    def ton_down_clicked(self, event):
        _ = event
        if not self.is_playing:
            if self.curr_ton > 0:
                self.curr_ton -= 1
                self.ton = self.tonalities[self.curr_ton]
                self.fund_freq = self.fundamental_frequencies[self.curr_ton]
            self.ton_is_valid = False
            self.track_parent.instrument_is_ready = False
            self.track_parent.this_is_booked = False
            self.track_parent.draw_track()
            self.draw_all_is()

    def ton_valid_clicked(self, event):
        _ = event
        if not self.is_playing:
            self.ton_is_valid = True
            if self.image:
                self.track_parent.instrument_is_ready = True
            self.draw_all_is()

    def restore_picture(self):
        self.extracted = []
        self.play_note_thread = None
        self.draw_all_is()

    def image_on_setup(self):
        self.pil = Image.open("Instruments/Image_Sonification/elvispic.jpeg")
        self.pil = self.pil.resize((self.img_sides, self.img_sides))
        self.image = ImageTk.PhotoImage(self.pil)
        self.ton_is_valid = True
        self.track_parent.instrument_is_ready = True
        self.draw_all_is()

    def load_image(self, event):
        if not self.is_playing:
            self.pil = None
            self.image = None
            self.draw_all_is()
            _ = event

            file_path = filedialog.askopenfilename(
                parent=self.window,
                filetypes=[("Image Files", "*.png;*.jpg;*.jpeg;*.gif;*.bmp")])

            if file_path and self.ton_is_valid:
                self.pil = Image.open(file_path)
                self.pil = self.pil.resize((self.img_sides, self.img_sides))
                self.image = ImageTk.PhotoImage(self.pil)
                self.draw_all_is()
                self.track_parent.instrument_is_ready = True
            else:
                ErrorWindow("Tonality Error", "Set the tonality first")

    def get_random_pixel_color(self):
        if self.image and self.is_playing:
            random_x = random.randint(0, self.img_sides - 1)
            random_y = random.randint(0, self.img_sides - 1)
            self.extracted.append((self.img_pos_x + random_x, self.img_pos_y + random_y))
            self.draw_all_is()

            rgb_color = self.pil.getpixel((random_x, random_y))
            # print(f"Random Pixel at ({random_x}, {random_y}) - RGB: {rgb_color}")
            grey = int((rgb_color[0]+rgb_color[1]+rgb_color[2])/3)
            # print(grey)
            note_offset = int(interp(grey, [0, 255], [0, 24]))
            # print(note_offset)
            if note_offset in self.major_scale_2oct:
                # print("ok")
                self.base_freq = self.fund_freq * pow(2, note_offset/12)
                self.play_note_thread = Thread(target=self.play_note_given_value)
                self.play_note_thread.start()
            else:
                # print("out")
                self.play_note_thread = None

            self.curStep += 1

        if self.curStep == self.track_parent.ls_parent.steps - 1:
            self.curStep = 0
            self.extracted = []
            self.draw_all_is()

    def play_note_given_value(self):
        waveform = self.generate_harmonic_wave()
        waveform *= 32767  # Scale to 16-bit PCM format
        waveform = waveform.astype(np.int16)
        play_obj = sa.play_buffer(waveform, 1, 2, 44100)
        play_obj.wait_done()

    def generate_harmonic_wave(self):
        framerate = 44100
        t = np.linspace(0, self.duration, int(framerate * self.duration), endpoint=False)  # Time array

        # Generate the harmonic wave by summing sine waves for each harmonic
        harmonic_wave = np.zeros(len(t))
        for harmonic in range(1, self.harmonics_count + 1):
            harmonic_wave += (1 / harmonic) * np.sin(2 * np.pi * self.base_freq * harmonic * t)
        # Normalize the waveform to be in the range [-1, 1]
        harmonic_wave /= np.max(np.abs(harmonic_wave))
        harmonic_wave /= 5

        return harmonic_wave


def handle_osc_message(address: str, args: tuple, img_son):
    if address == '/extract':
        if args:
            if args[0] == 'step':
                img_son.is_playing = True
                img_son.get_random_pixel_color()
            if args[0] == 'stop':
                img_son.is_playing = False
                img_son.restore_picture()
            elif args[0] == 'destroy':
                img_son.window.destroy()
