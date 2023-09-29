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
import tkinter as tk
from tkinter import filedialog
from PIL import Image, ImageTk
import random
from numpy import interp


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
        self.window.title("Recorder and Player")
        self.window.resizable(width=False, height=False)
        self.image = None
        self.pil = None
        # Create buttons
        self.load_button = tk.Button(self.window, text="Load Image", command=self.load_image)
        self.load_button.pack(pady=10)

        self.random_color_button = tk.Button(self.window, text="Get Random Pixel Color",
                                             command=self.get_random_pixel_color)
        self.random_color_button.pack(pady=10)

    def load_image(self):
        file_path = filedialog.askopenfilename(filetypes=[("Image Files", "*.png;*.jpg;*.jpeg;*.gif;*.bmp"),
                                                          ("PNG Files", "*.png"),
                                                          ("JPEG Files", "*.jpg;*.jpeg"),
                                                          ("GIF Files", "*.gif"),
                                                          ("BMP Files", "*.bmp")])
        if file_path:
            # Load the image using PIL
            self.pil = Image.open(file_path)
            width, height = self.pil.size
            self.pil = self.pil.resize((width // 10, height // 10))
            self.image = ImageTk.PhotoImage(self.pil)
            # Display the image in a label
            label = tk.Label(self.window, image=self.image)
            label.place(x=50, y=150)
            self.track_parent.instrument_is_ready = True

    def get_random_pixel_color(self):
        if self.image:
            # Get the width and height of the image
            width, height = self.image.width(), self.image.height()

            # Generate random coordinates
            random_x = random.randint(0, width - 1)
            random_y = random.randint(0, height - 1)

            # Get the RGB color of the random pixel
            rgb_color = self.pil.getpixel((random_x, random_y))
            for w in range(-10, 10):
                for e in range(-10, 10):
                    if 0 < random_x + w < width and 0 < random_y + e < height:
                        self.pil.putpixel((random_x + w, random_y + e), (0, 0, 0))
            self.image = ImageTk.PhotoImage(self.pil)
            # Display the image in a label
            label = tk.Label(self.window, image=self.image)
            label.place(x=50, y=150)

            print(f"Random Pixel at ({random_x}, {random_y}) - RGB: {rgb_color}")
            grey = int((rgb_color[0]+rgb_color[1]+rgb_color[2])/3)
            print(grey)
            note = int(interp(grey, [0, 255], [0, 24]))
            print(note)


def handle_osc_message(address: str, args: tuple, img_son):
    if address == '/extract':
        if args:
            if args[0] == 'start_routine':
                img_son.get_random_pixel_color()
            elif args[0] == 'destroy':
                img_son.window.destroy()
