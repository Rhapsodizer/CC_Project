from Utils import utils
import tkinter as tk
import subprocess
from Utils.error_manager import ErrorWindow
from threading import Thread
from Instruments.Recorder_and_Player.recorder_and_player import open_rap_window


def add_new_track(window, canvas, tracks, bpm, steps):
    """
    This function creates a new track object,
    if possible, then
    adds it to the list of tracks
    """
    track_height = 50
    if bpm == 0 or steps == 0:
        ErrorWindow("Setup Error", "Error: Set bpm and steps first!")
    else:
        if len(tracks) < 8:
            y_offset = len(tracks) * (track_height + 10)
            tr = Track(window, canvas, steps, instrument=None, pos_x=20, pos_y=y_offset + 100, height=track_height)
            tr.draw_track()
            tracks.append(tr)
        else:
            ErrorWindow("Track Error", "Error: Max # of tracks")


"""
This class defines the track element
"""


class Track:
    def __init__(self, window, canvas, steps, instrument, pos_x, pos_y, height):
        self.window = window
        self.canvas = canvas
        self.steps = steps
        self.instrument = instrument
        self.pos_x = pos_x
        self.pos_y = pos_y
        self.length = self.window.winfo_width()-40
        self.height = height
        self.color = "#B4B4B4"
        self.instr_name = None

    def plus_clicked(self, event):
        print("plus")
        self.choose_instrument(event)

    def settings_clicked(self, event):
        print("settings")
        print(event)
        self.open_instrument()

    def play_this_clicked(self, event):
        print(event)
        # self.play_this()

    def stop_this_clicked(self, event):
        print(event)
        # self.stop_this()

    def draw_track(self):
        [play_this_trg, stop_this_rect, settings_hexagon, settings_circle, plus_rect] = utils.draw_track_elements(self)
        self.canvas.tag_bind(play_this_trg, "<Button-1>", self.play_this)
        self.canvas.tag_bind(stop_this_rect, "<Button-1>", self.stop_this)
        self.canvas.tag_bind(settings_hexagon, "<Button-1>", self.settings_clicked)
        self.canvas.tag_bind(settings_circle, "<Button-1>", self.settings_clicked)
        self.canvas.tag_bind(plus_rect, "<Button-1>", self.plus_clicked)

    def choose_instrument(self, event):
        """
        upon clicking on open_choose_instrument,
        a window containing the list of
        available instrument opens up
        """
        print(event)
        listbox_window = tk.Toplevel()
        listbox_window.title("Instrument Selection")
        listbox_window.geometry("200x100")

        def on_listbox_select(event2):
            print(event2)
            selected_index = instruments_listbox.curselection()
            if selected_index:
                instrument_name = instruments_listbox.get(selected_index[0])
                self.instr_name = instrument_name
                self.draw_track()
                listbox_window.destroy()

        instruments_listbox = tk.Listbox(listbox_window, selectmode=tk.SINGLE)
        instruments_listbox.pack(expand=True, fill=tk.BOTH)

        instrument_list = ["Drum Machine", "Melody Chat", "Rec & Play", "Midi Keyboard"]
        for instr in instrument_list:
            instruments_listbox.insert(tk.END, instr)

        instruments_listbox.bind('<<ListboxSelect>>', on_listbox_select)

    def open_instrument(self):
        """
        upon clicking on open_instrument_button,
        a window specific for the instrument pops up
        this creates/opens/instantiate the instrument
        """
        if self.instr_name is None:
            ErrorWindow("Track Error", "No instrument selected")
        else:
            if self.instr_name == "Drum Machine":
                # processing_java_path = "/home/silvio/Documenti/Poli/processing42/processing-java"
                # pde_file_path = "/home/silvio/Documenti/Poli/CC_Project/DM2"
                # processing_java_path = "H:\Software\processing\processing-java"
                # pde_file_path = "H:\Documenti\POLIMI\\2_1\CC\Project\GitHub\CC_Project\Instruments\MDM_MinimalisticDrumMachine"
                processing_java_path = "processing-java"
                pde_file_path = "/Users/rischo95/Documents/STUDIO/POLIMI/MAGISTRALE/SECONDO_ANNO/PRIMO_SEMESTRE/CREATIVE_PROGRAMMING_AND_COMPUTING/CC_Project/Instruments/MDM_MinimalisticDrumMachine"


                pde_open = processing_java_path + " --sketch=" + pde_file_path + " --run " + str(self.steps)
                subprocess.Popen(pde_open, shell=True)
            if self.instr_name == "Melody Chat":
                # processing_java_path = "/home/silvio/Documenti/Poli/processing42/processing-java"
                # pde_file_path = "/home/silvio/Documenti/Poli/CC_Project/DM2"
                # processing_java_path = "H:\Software\processing\processing-java"
                # pde_file_path = "H:\Documenti\POLIMI\\2_1\CC\Project\GitHub\CC_Project\Instruments\Chat"
                processing_java_path = "processing-java"
                pde_file_path = "/Users/rischo95/Documents/STUDIO/POLIMI/MAGISTRALE/SECONDO_ANNO/PRIMO_SEMESTRE/CREATIVE_PROGRAMMING_AND_COMPUTING/CC_Project/Instruments/Chat"

                pde_open = processing_java_path + " --sketch=" + pde_file_path + " --run " + str(self.steps)
                subprocess.Popen(pde_open, shell=True)

            if self.instr_name == "Rec & Play":
                rap_thread = Thread(target=open_rap_window(self.window))
                # todo: calculate loop duration
                # rap_thread = Thread(target=open_rap_window(self.window), args=[loop_duration])
                rap_thread.start()

    def play_this(self):
        print("playing this track alone. disable play on all the others")

    def stop_this(self):
        print("stop playing this track. unlocking all the others")
