import time
import random
from Utils import utils
import tkinter as tk
import subprocess
from Utils.error_manager import ErrorWindow
from threading import Thread
from Instruments.Recorder_and_Player.recorder_and_player import open_rap_window
from Instruments.Image_Sonification.image_sonification import open_image_son_window
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
        self.this_is_booked = False
        self.port = random.randint(4000, 5000)
        self.postman = udp_client.SimpleUDPClient("127.0.0.1", self.port)
        self.port2 = random.randint(3000, 4000)
        self.postwoman = udp_client.SimpleUDPClient("127.0.0.1", self.port2)

    def draw_track(self):
        [book_this, settings_hexagon, settings_circle, plus_rect,
         remove_button, remove_x1, remove_x2] = utils.draw_track_elements_tr(self)
        self.canvas.tag_bind(book_this, "<Button-1>", self.book_this_clicked)
        self.canvas.tag_bind(settings_hexagon, "<Button-1>", self.settings_clicked)
        self.canvas.tag_bind(settings_circle, "<Button-1>", self.settings_clicked)
        self.canvas.tag_bind(plus_rect, "<Button-1>", self.plus_clicked)
        self.canvas.tag_bind(remove_button, "<Button-1>", self.remove_clicked)
        self.canvas.tag_bind(remove_x1, "<Button-1>", self.remove_clicked)
        self.canvas.tag_bind(remove_x2, "<Button-1>", self.remove_clicked)
        if not self.this_is_booked and self in self.ls_parent.booked_tracks:
            index = self.ls_parent.booked_tracks.index(self)
            self.ls_parent.booked_tracks.pop(index)
            self.ls_parent.draw_all()

    def book_this_clicked(self, event):
        _ = event
        if not self.ls_parent.track_currently_playing:
            if self.instr_name:
                if self.instrument_is_ready:
                    if self.this_is_booked:
                        self.this_is_booked = False
                        if self in self.ls_parent.booked_tracks:
                            index = self.ls_parent.booked_tracks.index(self)
                            self.ls_parent.booked_tracks.pop(index)
                    else:
                        if self not in self.ls_parent.booked_tracks:
                            self.this_is_booked = True
                            self.ls_parent.booked_tracks.append(self)
                        else:
                            index = self.ls_parent.booked_tracks.index(self)
                            self.ls_parent.booked_tracks.pop(index)
                    self.ls_parent.draw_all()
                elif self in self.ls_parent.booked_tracks:
                    index = self.ls_parent.booked_tracks.index(self)
                    self.ls_parent.booked_tracks.pop(index)
                else:
                    ErrorWindow("Instrument not set up", "Error: Use Settings to set up the instrument")
            else:
                ErrorWindow("No Instrument", "Error: No Instrument")

    def plus_clicked(self, event):
        if not self.ls_parent.track_currently_playing:
            if not self.instr_name:
                self.choose_instrument(event)

    def settings_clicked(self, event):
        _ = event
        if not self.ls_parent.track_currently_playing:
            self.setup_instrument()

    def remove_clicked(self, event):
        _ = event
        if not self.ls_parent.track_currently_playing:
            self.destroy()

    def choose_instrument(self, event):
        _ = event
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

        instrument_list = ["Drum Machine", "Melody Chat", "Rec & Play", "Image Sonification"]
        for instr in instrument_list:
            instruments_listbox.insert(tk.END, instr)

        instruments_listbox.bind('<<ListboxSelect>>', on_listbox_select)

    def setup_instrument(self):
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
            if self.instr_name == "Image Sonification":
                img_son_thread = Thread(target=open_image_son_window,
                                        args=[self])
                img_son_thread.start()

    def play_this(self):
        print("sending messages to " + str(self))
        # self.ls_parent.track_currently_playing.append(self)
        # Send START PLAY trigger
        if self.instr_name == "Drum Machine":
            osc.oscDM.send_message("/playStep", 0)
        elif self.instr_name == "Melody Chat":
            osc.oscSC.send_message("/playStep", 0)
        elif self.instr_name == "Rec & Play":
            self.postman.send_message('/action', 'play')
        elif self.instr_name == "Image Sonification":
            self.postman.send_message('/extract', 'step')

    def stop_this(self):
        # Send STOP trigger
        if self.instr_name == "Drum Machine":
            osc.oscDM.send_message("/stop", 0)
        elif self.instr_name == "Melody Chat":
            osc.oscSC.send_message("/stop", 0)
        elif self.instr_name == "Rec & Play":
            self.postman.send_message('/action', 'stop')
        elif self.instr_name == "Image Sonification":
            self.postman.send_message('/extract', 'stop')

        if self in self.ls_parent.track_currently_playing:
            index = self.ls_parent.track_currently_playing.index(self)
            self.ls_parent.track_currently_playing.pop(index)

        self.this_is_booked = False

    def destroy(self):
        # Send trigger to exit target applet
        if self.instr_name == "Drum Machine":
            osc.oscDM.send_message("/terminate", 0)
        elif self.instr_name == "Melody Chat":
            osc.oscCH.send_message("/terminate", 0)
        elif self.instr_name == "Rec & Play":
            self.postman.send_message('/action', 'destroy')
        elif self.instr_name == "Image Sonification":
            self.postman.send_message('/extract', 'destroy')

        tr_dist = 10
        if self in self.ls_parent.tracks:
            index = self.ls_parent.tracks.index(self)
            self.ls_parent.tracks.pop(index)
            for i, tr in enumerate(self.ls_parent.tracks):
                if i >= index:
                    tr.pos_y = tr.pos_y - (self.height + tr_dist)
            self.ls_parent.draw_all()
        del self
