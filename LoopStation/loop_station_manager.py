import time

from LoopStation.track import create_new_track
from Utils.error_manager import ErrorWindow
import Utils.osc_bridge as osc
from Utils import utils
import os
import tkinter as tk
import subprocess
import sys
import threading

"""
Main window manager
"""


def create_loop_station_manager_window(root):
    lsm = LoopStationManager(root)
    lsm.draw_all()
    lsm.launch_interaction_layer()


class LoopStationManager:
    def __init__(self, root):
        self.window = root
        self.window.title("Loop Station Manager")
        self.window.geometry("800x700")
        self.window.resizable(width=False, height=False)
        self.c_width = 800
        self.c_height = 700
        self.canvas = tk.Canvas(self.window, width=self.c_width, height=self.c_height, bg="#505050")
        self.canvas.pack()
        self.tracks = []
        self.bpm = 120
        self.steps = 16
        self.bpm_is_valid = False
        self.steps_is_valid = False
        self.loop_duration = self.calculate_loop_duration
        self.ls_is_ready = False

    def draw_all(self):
        [up_bpm_triangle, down_bpm_triangle, up_steps_triangle, down_steps_triangle,
         bpm_valid_rect, steps_valid_rect, plus_add_track, play, pause, stop,
         safe_close, close_x1, close_x2] = utils.draw_all_ls(self)
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
        print(event)
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
        print(event)
        if self.bpm < 200:
            self.bpm += 1
        self.bpm_is_valid = False
        self.draw_all()

    def down_bpm(self, event):
        print(event)
        if self.bpm > 1:
            self.bpm -= 1
        self.bpm_is_valid = False
        self.draw_all()

    def up_steps(self, event):
        print(event)
        if self.steps < 32:
            self.steps += 1
        self.steps_is_valid = False
        self.draw_all()

    def down_steps(self, event):
        print(event)
        if self.steps > 1:
            self.steps -= 1
        self.steps_is_valid = False
        self.draw_all()

    def calculate_loop_duration(self):
        return 60 / self.bpm * self.steps

    def on_bpm_set(self, event):
        print(self.bpm)
        print(event)
        self.bpm_is_valid = True
        self.draw_all()
        osc.oscDM.send_message("/setBpm", self.bpm)
        osc.oscCH.send_message("/setBpm", self.bpm)

    def on_steps_set(self, event):
        print(self.steps)
        print(event)
        self.steps_is_valid = True
        self.draw_all()
        osc.oscDM.send_message("/setSteps", self.steps)
        osc.oscCH.send_message("/setSteps", self.steps)

    def play_clicked(self, event):
        print("play")
        print(event)
        if not self.bpm_is_valid or not self.steps_is_valid:
            ErrorWindow("BPM or Steps", "Error: BPM or Steps are not valid")
        elif not self.tracks:
            ErrorWindow("Empty Tracks Error", "Error: No Tracks")
        else:
            for tr in self.tracks:
                if not tr.instr_name:
                    ErrorWindow("No Instrument", "Error: No Instrument")
                    print("error")
                    self.ls_is_ready = False
                    break
                elif not tr.instrument_is_ready:
                    ErrorWindow("Instrument not set up", "Error: Use Settings to set up the instrument")
                    print("error")
                    self.ls_is_ready = False
                    break
                else:
                    self.ls_is_ready = True

            if self.ls_is_ready:
                play_all_thread = threading.Thread(target=self.play_all_tracks)
                play_all_thread.start()

    def pause_clicked(self, event):
        print(event)
        if not self.bpm_is_valid or not self.steps_is_valid:
            ErrorWindow("BPM or Steps", "Error: BPM or Steps are not valid")
        elif not self.tracks:
            ErrorWindow("Empty Tracks Error", "Error: No Tracks")
        else:
            for tr in self.tracks:
                if not tr.instr_name:
                    ErrorWindow("No Instrument", "Error: No Instrument")
                    print("error")
                    self.ls_is_ready = False
                    break
                elif not tr.instrument_is_ready:
                    ErrorWindow("Instrument not set up", "Error: Use Settings to set up the instrument")
                    print("error")
                    self.ls_is_ready = False
                    break
                else:
                    print("pause")

    def stop_clicked(self, event):
        print(event)
        if not self.bpm_is_valid or not self.steps_is_valid:
            ErrorWindow("BPM or Steps", "Error: BPM or Steps are not valid")
        elif not self.tracks:
            ErrorWindow("Empty Tracks Error", "Error: No Tracks")
        else:
            for tr in self.tracks:
                if not tr.instr_name:
                    ErrorWindow("No Instrument", "Error: No Instrument")
                    self.ls_is_ready = False
                    break
                elif not tr.instrument_is_ready:
                    ErrorWindow("Instrument not set up", "Error: Use Settings to set up the instrument")
                    self.ls_is_ready = False
                    break
                else:
                    self.ls_is_ready = False
            self.stop_all_tracks()

    def play_all_tracks(self):
        time_chunk = 60 / self.bpm
        cur_step = 0
        while cur_step < self.steps:
            for i, tr in enumerate(self.tracks):
                print(f"playing track {i}")
                tr.play_this()
            time.sleep(time_chunk)
            cur_step += 1
            if cur_step == self.steps:
                cur_step = 0  # loop

    def pause_all_tracks(self):
        for i, tr in enumerate(self.tracks):
            print(f"stopping track {i}")
            tr.pause_this()

    def stop_all_tracks(self):
        for i, tr in enumerate(self.tracks):
            print(f"stopping track {i}")
            tr.stop_this()

    def launch_interaction_layer(self):
        # Open layer interaction sketch
        # processing_java_path = "/home/silvio/Documenti/Poli/processing42/processing-java"
        # pde_file_path = "/home/silvio/Documenti/Poli/CC_Project/DM2"
        processing_java_path = "H:\Software\processing\processing-java"
        pde_file_path = "H:\Documenti\POLIMI\\2_1\CC\Project\GitHub\CC_Project\LayerInteraction"
        # processing_java_path = "processing-java"
        # pde_file_path = "/Users/rischo95/Documents/STUDIO/POLIMI/MAGISTRALE/SECONDO_ANNO/PRIMO_SEMESTRE/CREATIVE_PROGRAMMING_AND_COMPUTING/CC_Project/LayerInteraction"
        pde_open = processing_java_path + " --sketch=" + pde_file_path + " --run " + str(self.steps)
        subprocess.Popen(pde_open, shell=True)
        # todo move this paths in jason file

    def safe_close_clicked(self, event):
        osc.oscLI.send_message("/terminate", 0)
        osc.oscDM.send_message("/terminate", 0)
        osc.oscCH.send_message("/terminate", 0)

        print(event)
        utils.draw_shutdown_ls(self)
        # os.remove("Instruments/Recorder_and_Player/recorder_audio.wav")

    # todo
    # trigger "nextstep" every time step, having bpm and number of steps
    # at the end of the loop (last nexstep) trigger an osc message to pose the cursor at 0
