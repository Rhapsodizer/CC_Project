import time
from LoopStation.track import create_new_track
from Utils.error_manager import ErrorWindow
import Utils.osc_bridge as osc
from Utils import utils
import tkinter as tk
import subprocess
import threading
from PIL import Image, ImageTk

"""
Main window manager
"""


def create_loop_station_manager_window(root, u_paths):
    lsm = LoopStationManager(root, u_paths)
    lsm.draw_all()
    lsm.launch_interaction_layer()


class LoopStationManager:
    def __init__(self, root, u_paths):
        self.window = root
        self.window.title("E.L.V.I.S")
        self.window.geometry("800x700")
        self.window.resizable(width=False, height=False)
        self.c_width = 800
        self.c_height = 700
        self.canvas = tk.Canvas(self.window, width=self.c_width, height=self.c_height, bg="#808080")
        self.canvas.pack()
        self.tracks = []
        self.bpm = 120
        self.steps = 16
        self.bpm_is_valid = False
        self.steps_is_valid = False
        self.loop_duration = self.calculate_loop_duration
        self.time_chunk = 60 / self.bpm
        self.spaceship_is_running = False
        self.user_paths = u_paths
        self.pil = Image.open(u_paths[5])
        w, h = self.pil.size
        self.pil = self.pil.resize((w // 2, h // 2))
        self.image = ImageTk.PhotoImage(self.pil)
        self.booked_tracks = []
        self.stop_is_able = False
        self.play_is_able = False
        self.play_thread = None
        self.stop_thread = None
        self.play_all_booked_thread = None
        self.play_all_booked_thread_is_running = False
        self.stop_has_been_pressed = False
        self.book_all_is_active = False
        self.track_currently_playing = []

    def draw_all(self):
        [spaceship, up_bpm_triangle, down_bpm_triangle, up_steps_triangle, down_steps_triangle,
         bpm_valid_rect, steps_valid_rect, plus_add_track, play, stop,
         safe_close, close_x1, close_x2, book_all] = utils.draw_all_ls(self)
        self.canvas.tag_bind(spaceship, "<Button-1>", self.takeoff_land_spaceship)
        self.canvas.tag_bind(up_bpm_triangle, "<Button-1>", self.up_bpm)
        self.canvas.tag_bind(down_bpm_triangle, "<Button-1>", self.down_bpm)
        self.canvas.tag_bind(up_steps_triangle, "<Button-1>", self.up_steps)
        self.canvas.tag_bind(down_steps_triangle, "<Button-1>", self.down_steps)
        self.canvas.tag_bind(bpm_valid_rect, "<Button-1>", self.on_bpm_set)
        self.canvas.tag_bind(steps_valid_rect, "<Button-1>", self.on_steps_set)
        self.canvas.tag_bind(plus_add_track, "<Button-1>", self.add_track_clicked)
        self.canvas.tag_bind(play, "<Button-1>", self.play_clicked)
        self.canvas.tag_bind(stop, "<Button-1>", self.stop_clicked)
        self.canvas.tag_bind(safe_close, "<Button-1>", self.safe_close_clicked)
        self.canvas.tag_bind(close_x1, "<Button-1>", self.safe_close_clicked)
        self.canvas.tag_bind(close_x2, "<Button-1>", self.safe_close_clicked)
        if book_all:
            self.canvas.tag_bind(book_all, "<Button-1>", self.book_all_clicked)
        for t in self.tracks:
            t.draw_track()

    def add_track_clicked(self, event):
        _ = event
        if not self.track_currently_playing:
            if len(self.tracks) < 8:
                if self.bpm_is_valid and self.steps_is_valid:
                    tr = create_new_track(self)
                    self.tracks.append(tr)
                    self.draw_all()
                else:
                    ErrorWindow("BPM or Steps", "Error: BPM or Steps are not valid")
            else:
                ErrorWindow("Track Error", "Error: Maximum number of track reached")

    def book_all_clicked(self, event):
        if not self.track_currently_playing:
            if not self.book_all_is_active:
                self.book_all_is_active = True
                self.booked_tracks = []
                for t in self.tracks:
                    t.this_is_booked = False
                self.draw_all()
                for t in self.tracks:
                    t.book_this_clicked(event)
            else:
                self.book_all_is_active = False
                self.booked_tracks = []
            self.draw_all()

    def up_bpm(self, event):
        _ = event
        if not self.track_currently_playing:
            if self.bpm < 200:
                self.bpm += 1
            self.bpm_is_valid = False
            self.draw_all()

    def down_bpm(self, event):
        _ = event
        if not self.track_currently_playing:
            if self.bpm > 1:
                self.bpm -= 1
            self.bpm_is_valid = False
            self.draw_all()

    def up_steps(self, event):
        _ = event
        if not self.track_currently_playing:
            if self.steps < 16:
                self.steps += 1
            self.steps_is_valid = False
            self.draw_all()

    def down_steps(self, event):
        _ = event
        if not self.track_currently_playing:
            if self.steps > 1:
                self.steps -= 1
            self.steps_is_valid = False
            self.draw_all()

    def calculate_loop_duration(self):
        return 60 / self.bpm * self.steps

    def on_bpm_set(self, event):
        _ = event
        if not self.track_currently_playing:
            self.bpm_is_valid = True
            self.time_chunk = 60 / self.bpm
            for t in self.tracks:
                t.update_loop_duration()
            self.draw_all()
            osc.oscDM.send_message("/setBpm", self.bpm)
            osc.oscCH.send_message("/setBpm", self.bpm)

    def on_steps_set(self, event):
        _ = event
        if not self.track_currently_playing:
            self.steps_is_valid = True
            for t in self.tracks:
                t.update_loop_duration()
            self.draw_all()
            osc.oscDM.send_message("/setSteps", self.steps)
            osc.oscCH.send_message("/setSteps", self.steps)

    def play_clicked(self, event):
        _ = event
        print("in play clicked")
        if self.play_is_able:
            if not self.bpm_is_valid or not self.steps_is_valid:
                ErrorWindow("BPM or Steps", "Error: BPM or Steps are not valid")
            elif not self.tracks:
                ErrorWindow("Empty Tracks Error", "Error: No Tracks")
            elif not self.booked_tracks:
                ErrorWindow("Booked Tracks Error", "Error: No Tracks to play")
            else:
                print("play thread is running...")
                self.track_currently_playing = self.booked_tracks
                print(self.booked_tracks)
                self.play_is_able = False
                self.play_all_booked_thread_is_running = True
                # if not self.play_all_booked_thread:
                self.play_all_booked_thread = threading.Thread(target=self.play_all_booked_tracks)
                self.play_all_booked_thread.start()

    def play_all_booked_tracks(self):
        print("in play all booked")
        self.stop_is_able = True
        self.stop_has_been_pressed = False
        self.draw_all()
        if self.play_all_booked_thread_is_running and not self.stop_has_been_pressed:
            self.loop()

    def loop(self):
        if self.booked_tracks:
            print("in loop")
            for i, t in enumerate(self.booked_tracks):
                self.play_thread = threading.Thread(target=t.play_this)
                self.play_thread.start()
                self.play_thread = None
            if self.play_all_booked_thread_is_running and not self.stop_has_been_pressed:
                time.sleep(self.time_chunk)  # wait 60/bpm to send the next step message
                self.loop()

    def stop_clicked(self, event):
        _ = event
        if self.stop_is_able:
            print("stop has been pressed")
            self.stop_has_been_pressed = True
            self.stop_all_booked_tracks()

    def stop_all_booked_tracks(self):
        if self.play_all_booked_thread:
            self.play_all_booked_thread_is_running = False
            self.play_all_booked_thread = None
            # print(self.booked_tracks)

            while self.booked_tracks:
                t = self.booked_tracks[0]
                print("stopping track " + str(t))
                self.stop_thread = threading.Thread(target=t.stop_this)
                self.stop_thread.start()
                self.stop_thread = None
                self.booked_tracks = self.booked_tracks[1:]
            self.book_all_is_active = False
            self.play_thread = None
            self.booked_tracks = []
            self.track_currently_playing = []
            self.stop_is_able = False
            self.draw_all()

    def takeoff_land_spaceship(self, event):
        _ = event
        if not self.track_currently_playing:
            if self.spaceship_is_running:
                self.spaceship_is_running = False
                print("landing")
                osc.oscTA.send_message("/terminate", 0)
                osc.oscLI.send_message("/triggerAgent", 0)
            else:
                print("launching")
                self.spaceship_is_running = True
                osc.oscLI.send_message("/triggerAgent", 0)
                processing_java_path = self.user_paths[0]
                pde_file_path = self.user_paths[4]
                pde_open = processing_java_path + " --sketch=" + pde_file_path + " --run " + str(self.steps)
                subprocess.Popen(pde_open, shell=True)

    def launch_interaction_layer(self):
        processing_java_path = self.user_paths[0]
        pde_file_path = self.user_paths[1]
        pde_open = processing_java_path + " --sketch=" + pde_file_path + " --run " + str(self.steps)
        subprocess.Popen(pde_open, shell=True)

    def safe_close_clicked(self, event):
        _ = event
        time.sleep(0.001)
        utils.draw_shutdown_ls(self)
