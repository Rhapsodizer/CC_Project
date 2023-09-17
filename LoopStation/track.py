from Utils import utils
import tkinter as tk
import subprocess
from Utils.error_manager import ErrorWindow


def add_new_track(window, canvas, tracks):
    """
    This function creates a new track object,
    if possible, then
    adds it to the list of tracks
    """
    track_height = 50
    y_offset = len(tracks) * (track_height + 10)

    if len(tracks) < 6:
        tr = Track(window, canvas, instrument=None, pos_x=20, pos_y=y_offset + 100, height=track_height)
        tracks.append(tr)
    else:
        error_window = ErrorWindow("Track Error", "Error: Max # of tracks")


"""
This class defines the track element
"""


class Track:
    def __init__(self, window, canvas, instrument, pos_x, pos_y, height):
        self.window = window
        self.canvas = canvas
        self.instrument = instrument
        self.pos_x = pos_x
        self.pos_y = pos_y
        self.length = self.window.winfo_width()-40
        self.height = height
        self.color = "gold"

        # visual defines how the track element is shown
        self.visual = utils.round_rectangle(canvas,
                                            self.pos_x, self.pos_y,
                                            self.pos_x + self.length, self.pos_y + self.height,
                                            radius=20, fill=self.color)

        self.chosen_instrument_text = "Choose"
        # choose_rect is just a rectangle containing chosen_instrument_text
        self.choose_rect = utils.create_rectangle_with_centered_text(
            canvas, self.chosen_instrument_text, "black", 10, self.window.winfo_width() // 2 - 40,
            self.pos_y+5, self.window.winfo_width() // 2 + 40, self.pos_y+self.height-5, "snow3")

        self.has_been_chosen_color = "red"
        # open_choose_instrument is a clickable rectangle
        # when clicked, it lets the user choose the instrument
        self.open_choose_instrument = canvas.create_rectangle(
            self.window.winfo_width() // 2 + 40, self.pos_y+5, self.window.winfo_width() // 2 + 60,
            self.pos_y+self.height-5, fill=self.has_been_chosen_color)
        self.canvas.tag_bind(self.open_choose_instrument, '<Button-1>', self.choose_instrument)

        self.instr_name = "---"
        # track_name is just the printed name of the selected instrument
        self.track_name = canvas.create_text(pos_x + 80, pos_y + self.height//2,
                                             text=self.instr_name, font=("Arial", 12))

        # open_instrument_button lets the user open (create)
        # the window to modify the chosen instrument
        self.open_instrument_button = tk.Button(window, text="Open Instr", command=self.open_instrument,
                                                bg="snow3", height=1)
        self.open_instrument_button.place(x=self.window.winfo_width() // 2 + 80, y=self.pos_y+5)

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

                new_chosen_color = "red" if self.has_been_chosen_color != "red" else "green"
                self.canvas.itemconfig(self.open_choose_instrument, fill=new_chosen_color)
                self.has_been_chosen_color = new_chosen_color

                # new_chosen_ok = "Choose" if self.chosen_instrument_text != "Choose" else "OK"
                # self.canvas.item config(self.choose_rect, text=new_chosen_ok) (item config is a single word)
                # self.chosen_instrument_text = new_chosen_ok

                new_name = "---" if self.instr_name != "---" else instrument_name
                self.canvas.itemconfig(self.track_name, text=new_name)
                self.instr_name = new_name

                listbox_window.destroy()

        instruments_listbox = tk.Listbox(listbox_window, selectmode=tk.SINGLE)
        instruments_listbox.pack(expand=True, fill=tk.BOTH)

        instrument_list = ["Drum Machine", "Microphone", "Midi Keyboard"]
        for instr in instrument_list:
            instruments_listbox.insert(tk.END, instr)

        instruments_listbox.bind('<<ListboxSelect>>', on_listbox_select)

    def open_instrument(self):
        """
        upon clicking on open_instrument_button,
        a window specific for the instrument pops up
        this creates/opens/instantiate the instrument
        """
        # todo: make this a switch construct
        if self.instr_name == "---":
            error_window = ErrorWindow("Track Error", "No instrument selected")
        else:
            """ # if self.instrument_name == "Drum Machine":
            # this case assumes "Drum Machine"
            parameters = [4, 4]
            self.instrument = utils.create_instrument(self.instr_name, parameters)
            self.instrument.ready = True
            # print(self.instrument) """
            if self.instr_name == "Drum Machine":
                #processing_java_path = "/home/silvio/Documenti/Poli/processing42/processing-java"
                #pde_file_path = "/home/silvio/Documenti/Poli/CC_Project/DM2"
                processing_java_path = "H:\Software\processing\processing-java"
                pde_file_path = "H:\Documenti\POLIMI\\2_1\CC\Project\GitHub\CC_Project\Instruments\MDM_MinimalisticDrumMachine"
                # ...
                # ...

                pde_open = processing_java_path + " --sketch=" + pde_file_path + " --run "
                subprocess.Popen(pde_open, shell=True)
