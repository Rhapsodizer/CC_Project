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
        self.play_all_thread = None
        self.play_all_thread_is_running = False
        self.stop_has_been_pressed = False
        self.play_is_able = False
        self.pause_is_able = False
        self.stop_is_able = False
        self.spaceship_is_running = False
        self.user_paths = u_paths
        self.pil = Image.open(u_paths[5])
        w, h = self.pil.size
        self.pil = self.pil.resize((w // 2, h // 2))
        self.image = ImageTk.PhotoImage(self.pil)

    def draw_all(self):
        [spaceship, up_bpm_triangle, down_bpm_triangle, up_steps_triangle, down_steps_triangle,
         bpm_valid_rect, steps_valid_rect, plus_add_track, play, pause, stop,
         safe_close, close_x1, close_x2] = utils.draw_all_ls(self)
        self.canvas.tag_bind(spaceship, "<Button-1>", self.takeoff_land_spaceship)
        self.canvas.tag_bind(up_bpm_triangle, "<Button-1>", self.up_bpm)
        self.canvas.tag_bind(down_bpm_triangle, "<Button-1>", self.down_bpm)
        self.canvas.tag_bind(up_steps_triangle, "<Button-1>", self.up_steps)
        self.canvas.tag_bind(down_steps_triangle, "<Button-1>", self.down_steps)
        self.canvas.tag_bind(bpm_valid_rect, "<Button-1>", self.on_bpm_set)
        self.canvas.tag_bind(steps_valid_rect, "<Button-1>", self.on_steps_set)
        self.canvas.tag_bind(plus_add_track, "<Button-1>", self.add_track_clicked)
        self.canvas.tag_bind(play, "<Button-1>", self.play_clicked)
        self.canvas.tag_bind(pause[0], "<Button-1>", self.pause_clicked)
        self.canvas.tag_bind(pause[1], "<Button-1>", self.pause_clicked)
        self.canvas.tag_bind(pause[2], "<Button-1>", self.pause_clicked)
        self.canvas.tag_bind(stop, "<Button-1>", self.stop_clicked)
        self.canvas.tag_bind(safe_close, "<Button-1>", self.safe_close_clicked)
        self.canvas.tag_bind(close_x1, "<Button-1>", self.safe_close_clicked)
        self.canvas.tag_bind(close_x2, "<Button-1>", self.safe_close_clicked)

    def add_track_clicked(self, event):
        _ = event
        if len(self.tracks) < 8:
            if self.bpm_is_valid and self.steps_is_valid:
                tr = create_new_track(self)
                self.tracks.append(tr)
                self.draw_all()
            else:
                ErrorWindow("BPM or Steps", "Error: BPM or Steps are not valid")
        else:
            ErrorWindow("Track Error", "Error: Maximum number of track reached")

    def up_bpm(self, event):
        _ = event
        if self.bpm < 200:
            self.bpm += 1
        self.bpm_is_valid = False
        self.draw_all()

    def down_bpm(self, event):
        _ = event
        if self.bpm > 1:
            self.bpm -= 1
        self.bpm_is_valid = False
        self.draw_all()

    def up_steps(self, event):
        _ = event
        if self.steps < 32:
            self.steps += 1
        self.steps_is_valid = False
        self.draw_all()

    def down_steps(self, event):
        _ = event
        if self.steps > 1:
            self.steps -= 1
        self.steps_is_valid = False
        self.draw_all()

    def calculate_loop_duration(self):
        return 60 / self.bpm * self.steps

    def on_bpm_set(self, event):
        _ = event
        self.bpm_is_valid = True
        self.time_chunk = 60 / self.bpm
        self.draw_all()
        osc.oscDM.send_message("/setBpm", self.bpm)
        osc.oscCH.send_message("/setBpm", self.bpm)

    def on_steps_set(self, event):
        _ = event
        self.steps_is_valid = True
        self.draw_all()
        osc.oscDM.send_message("/setSteps", self.steps)
        osc.oscCH.send_message("/setSteps", self.steps)

    def play_clicked(self, event):
        _ = event
        ready = False
        if not self.bpm_is_valid or not self.steps_is_valid:
            ErrorWindow("BPM or Steps", "Error: BPM or Steps are not valid")
        elif not self.tracks:
            ErrorWindow("Empty Tracks Error", "Error: No Tracks")
        else:
            for tr in self.tracks:
                if not tr.instr_name:
                    ErrorWindow("No Instrument", "Error: No Instrument")
                    ready = False
                    break
                elif not tr.instrument_is_ready:
                    ErrorWindow("Instrument not set up", "Error: Use Settings to set up the instrument")
                    ready = False
                    break
                else:
                    ready = True
            if ready:
                self.disable_all()
                self.stop_has_been_pressed = False
                print("play thread is running...")
                self.play_all_thread_is_running = True
                self.play_all_thread = threading.Thread(target=self.play_all_tracks)
                self.play_all_thread.start()

    def pause_clicked(self, event):
        _ = event
        if not self.bpm_is_valid or not self.steps_is_valid:
            ErrorWindow("BPM or Steps", "Error: BPM or Steps are not valid")
        elif not self.tracks:
            ErrorWindow("Empty Tracks Error", "Error: No Tracks")
        else:
            for tr in self.tracks:
                if not tr.instr_name:
                    ErrorWindow("No Instrument", "Error: No Instrument")
                    break
                elif not tr.instrument_is_ready:
                    ErrorWindow("Instrument not set up", "Error: Use Settings to set up the instrument")
                    break
                else:
                    print("pause")

    def stop_clicked(self, event):
        _ = event
        if not self.bpm_is_valid or not self.steps_is_valid:
            ErrorWindow("BPM or Steps", "Error: BPM or Steps are not valid")
        elif not self.tracks:
            ErrorWindow("Empty Tracks Error", "Error: No Tracks")
        else:
            for tr in self.tracks:
                if not tr.instr_name:
                    ErrorWindow("No Instrument", "Error: No Instrument")
                    break
                elif not tr.instrument_is_ready:
                    ErrorWindow("Instrument not set up", "Error: Use Settings to set up the instrument")
                    break
                else:
                    self.stop_has_been_pressed = True
                    print("stop has been pressed")
                    self.stop_all_tracks()

    def play_all_tracks(self):
        cur_step = 0
        # while self.play_all_thread_is_running:
        if self.play_all_thread_is_running:
            print("1")
            while not self.stop_has_been_pressed:
                for i, tr in enumerate(self.tracks):
                    tr.play_this("lsm")
                    print("2")
                time.sleep(self.time_chunk)
                cur_step += 1
                if cur_step == self.steps:
                    cur_step = 0  # loop

    def pause_all_tracks(self):
        for i, tr in enumerate(self.tracks):
            print(f"stopping track {i}")
            tr.pause_this()

    def stop_all_tracks(self):
        if self.play_all_thread:
            for i, tr in enumerate(self.tracks):
                print(f"stopping track {i}")
                tr.stop_this()
            self.play_all_thread_is_running = False
            self.play_all_thread.join()
            print("Play thread stopped and destroyed.")
            self.play_all_thread = None
            self.enable_all()

    def takeoff_land_spaceship(self, event):
        _ = event
        if self.spaceship_is_running:
            self.spaceship_is_running = False
            print("landing")
            osc.oscTA.send_message("/terminate", 0)
        else:
            print("launching")
            self.spaceship_is_running = True
            processing_java_path = self.user_paths[0]
            pde_file_path = self.user_paths[4]
            pde_open = processing_java_path + " --sketch=" + pde_file_path + " --run " + str(self.steps)
            subprocess.Popen(pde_open, shell=True)

    def launch_interaction_layer(self):
        processing_java_path = self.user_paths[0]
        pde_file_path = self.user_paths[1]
        pde_open = processing_java_path + " --sketch=" + pde_file_path + " --run " + str(self.steps)
        subprocess.Popen(pde_open, shell=True)

    def disable_all(self):
        self.play_is_able = False
        self.pause_is_able = True
        self.stop_is_able = True
        for tr in self.tracks:
            tr.disable_all_this()
        self.draw_all()

    def enable_all(self):
        self.play_is_able = True
        self.pause_is_able = False
        self.stop_is_able = False
        for tr in self.tracks:
            tr.enable_all_this()
        self.draw_all()

    def safe_close_clicked(self, event):
        _ = event

        osc.oscLI.send_message("/terminate", 0)
        osc.oscDM.send_message("/terminate", 0)
        osc.oscCH.send_message("/terminate", 0)
        time.sleep(0.001)
        utils.draw_shutdown_ls(self)
        # os.remove("Instruments/Recorder_and_Player/recorder_audio.wav")
