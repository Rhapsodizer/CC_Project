import threading
import time

from Utils import utils
import tkinter as tk
import subprocess
from Utils.error_manager import ErrorWindow
from threading import Thread
from Instruments.Recorder_and_Player.recorder_and_player import open_rap_window
import Utils.osc_bridge as osc
from pythonosc import udp_client


def create_new_track(ls):
    num_tracks = len(ls.tracks)
    track_height = 50
    track_distance = 10
    track_offset_x = 20
    y_offset = num_tracks * (track_height + track_distance)
    tr = Track(ls, pos_x=track_offset_x, pos_y=y_offset + 100, track_height=track_height)
    return tr


"""
This class defines the track element
"""


class Track:
    def __init__(self, loop_station_parent, pos_x, pos_y, track_height):
        self.ls_parent = loop_station_parent
        self.window = loop_station_parent.window
        self.canvas = loop_station_parent.canvas
        self.steps = loop_station_parent.steps
        self.instrument_is_ready = False
        self.pos_x = pos_x
        self.pos_y = pos_y
        self.length = self.window.winfo_width() - 40
        self.height = track_height
        self.color = "#B4B4B4"
        self.instr_name = None
        self.play_this_thread = None
        self.play_this_thread_is_running = False
        self.stop_this_has_been_pressed = False
        self.this_play_is_able = False
        self.this_stop_is_able = False
        self.postman = udp_client.SimpleUDPClient("127.0.0.1", 5006)

    def draw_track(self):
        [play_this_trg, stop_this_rect, settings_hexagon, settings_circle, plus_rect,
         remove_button, remove_x1, remove_x2] = utils.draw_track_elements_tr(self)
        self.canvas.tag_bind(play_this_trg, "<Button-1>", self.play_this_clicked)
        self.canvas.tag_bind(stop_this_rect, "<Button-1>", self.stop_this_clicked)
        self.canvas.tag_bind(settings_hexagon, "<Button-1>", self.settings_clicked)
        self.canvas.tag_bind(settings_circle, "<Button-1>", self.settings_clicked)
        self.canvas.tag_bind(plus_rect, "<Button-1>", self.plus_clicked)
        self.canvas.tag_bind(remove_button, "<Button-1>", self.remove_clicked)
        self.canvas.tag_bind(remove_x1, "<Button-1>", self.remove_clicked)
        self.canvas.tag_bind(remove_x2, "<Button-1>", self.remove_clicked)

    def play_this_clicked(self, event):
        _ = event
        self.stop_this_has_been_pressed = False
        if self.this_play_is_able:
            if self.instrument_is_ready:
                self.this_play_is_able = False
                self.this_stop_is_able = True
                self.ls_parent.play_is_able = False
                self.ls_parent.pause_is_able = False
                self.ls_parent.stop_is_able = False
                for tr in self.ls_parent.tracks:
                    if tr is not self:
                        tr.disable_all_this()
                self.draw_track()
                self.ls_parent.draw_all()
                self.play_this_thread_is_running = True
                self.play_this_thread = threading.Thread(target=self.play_this, args=["this"])
                self.play_this_thread.start()
            elif self.instr_name is None:
                ErrorWindow("No Instrument", "Error: No Instrument")
            else:
                ErrorWindow("Instrument not set up", "Error: Use Settings to set up the instrument")

    def stop_this_clicked(self, event):
        _ = event
        if self.this_stop_is_able:
            if self.instrument_is_ready:
                self.this_play_is_able = True
                self.this_stop_is_able = False
                self.ls_parent.play_is_able = True
                self.ls_parent.pause_is_able = False
                self.ls_parent.stop_is_able = False
                for tr in self.ls_parent.tracks:
                    if tr is not self:
                        tr.enable_all_this()
                self.draw_track()
                self.ls_parent.draw_all()
                self.stop_this_has_been_pressed = True
                self.stop_this()
            elif self.instr_name is None:
                ErrorWindow("No Instrument", "Error: No Instrument")
            else:
                ErrorWindow("Instrument not set up", "Error: Use Settings to set up the instrument")

    def plus_clicked(self, event):
        self.ls_parent.stop_all_tracks()
        self.choose_instrument(event)

    def settings_clicked(self, event):
        _ = event
        self.setup_instrument()

    def remove_clicked(self, event):
        _ = event
        self.destroy()

    def choose_instrument(self, event):
        """
        upon clicking on open_choose_instrument,
        a window containing the list of
        available instrument opens up
        """
        _ = event
        self.this_play_is_able = True
        self.ls_parent.stop_all_tracks()

        listbox_window = tk.Toplevel()
        listbox_window.title("Instrument Selection")
        listbox_window.geometry("300x150")

        def on_listbox_select(event2):
            _ = event2
            selected_index = instruments_listbox.curselection()
            if selected_index:
                instrument_name = instruments_listbox.get(selected_index[0])
                self.instr_name = instrument_name
                self.draw_track()
                listbox_window.destroy()
                time.sleep(0.5)
                self.setup_instrument()

        instruments_listbox = tk.Listbox(listbox_window, selectmode=tk.SINGLE)
        instruments_listbox.pack(expand=True, fill=tk.BOTH)

        instrument_list = ["Drum Machine", "Melody Chat", "Rec & Play", "Space Ship"]
        for instr in instrument_list:
            instruments_listbox.insert(tk.END, instr)

        instruments_listbox.bind('<<ListboxSelect>>', on_listbox_select)

    def setup_instrument(self):
        """
        upon clicking on open_instrument_button,
        a window specific for the instrument pops up.
        This creates/opens/instantiate the instrument
        """
        current_paths = self.ls_parent.user_paths

        if self.instr_name is None:
            ErrorWindow("Track Error", "No instrument selected")
        else:
            if self.instr_name == "Drum Machine":
                self.instrument_is_ready = True
                processing_java_path = current_paths[0]
                pde_file_path = current_paths[2]
                pde_open = processing_java_path + " --sketch=" + pde_file_path + " --run " + str(self.steps)
                subprocess.Popen(pde_open, shell=True)
            if self.instr_name == "Melody Chat":
                self.instrument_is_ready = True
                processing_java_path = current_paths[0]
                pde_file_path = current_paths[3]
                pde_open = processing_java_path + " --sketch=" + pde_file_path + " --run " + str(self.steps)
                subprocess.Popen(pde_open, shell=True)
            if self.instr_name == "Rec & Play":
                rap_thread = Thread(target=open_rap_window,
                                    args=[self])
                rap_thread.start()

    def play_this(self, caller):
        print("3")
        cur_step = 0
        if caller == "this":
            while self.play_this_thread_is_running or self.ls_parent.play_all_thread_is_running:
                while not self.stop_this_has_been_pressed:
                    print("3.5")
                    # Send START PLAY trigger
                    if self.instr_name == "Drum Machine":
                        osc.oscDM.send_message("/play", 0)
                    elif self.instr_name == "Melody Chat":
                        osc.oscCH.send_message("/play", 0)
                    elif self.instr_name == "Rec & Play":
                        print("4")
                        self.postman.send_message('/action', 'play')

                    time.sleep(self.ls_parent.time_chunk)
                    cur_step += 1
                    if cur_step == self.steps:
                        cur_step = 0  # loop
        else:
            print("3.7")
            # Send START PLAY trigger
            if self.instr_name == "Drum Machine":
                osc.oscDM.send_message("/play", 0)
            elif self.instr_name == "Melody Chat":
                osc.oscCH.send_message("/play", 0)
            elif self.instr_name == "Rec & Play":
                self.postman.send_message('/action', 'play')

    def pause_this(self):
        """
        Only available for *all tracks* not this alone
        """
        if self.instrument_is_ready:
            # Send broadcast PAUSE trigger
            osc.oscDM.send_message("/pause", 0)
            osc.oscDM.send_message("/pause", 0)
        elif self.instr_name is None:
            ErrorWindow("No Instrument", "Error: No Instrument")
        else:
            ErrorWindow("Instrument not set up", "Error: Use Settings to set up the instrument")

    def stop_this(self):
        if self.play_this_thread or self.ls_parent.play_all_thread:
            self.play_this_thread_is_running = False
            self.play_this_thread.join()
            print("Play_this thread stopped and destroyed.")
            self.play_this_thread = None
            # Send STOP trigger
            if self.instr_name == "Drum Machine":
                osc.oscDM.send_message("/stop", 0)
            elif self.instr_name == "Melody Chat":
                osc.oscCH.send_message("/stop", 0)
            elif self.instr_name == "Rec & Play":
                self.postman.send_message('/action', 'stop')

    def destroy(self):
        # Send trigger to exit target applet
        if self.instr_name == "Drum Machine":
            osc.oscDM.send_message("/terminate", 0)
        elif self.instr_name == "Melody Chat":
            osc.oscCH.send_message("/terminate", 0)

        tr_dist = 10
        if self in self.ls_parent.tracks:
            index = self.ls_parent.tracks.index(self)
            self.ls_parent.tracks.pop(index)
            # self.ls_parent.tracks.remove(self)
            for i, tr in enumerate(self.ls_parent.tracks):
                if i >= index:
                    tr.pos_y = tr.pos_y - (self.height + tr_dist)
            self.ls_parent.draw_all()
        del self

    def disable_all_this(self):
        self.this_play_is_able = False
        self.this_stop_is_able = False
        self.stop_this_has_been_pressed = False
        self.draw_track()

    def enable_all_this(self):
        self.this_play_is_able = True
        self.this_stop_is_able = False
        self.stop_this_has_been_pressed = True
        self.draw_track()
