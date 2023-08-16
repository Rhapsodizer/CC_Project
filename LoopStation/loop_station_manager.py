import tkinter as tk
from tkinter import ttk
from LoopStation.track import add_new_track
from Utils.error_manager import ErrorWindow


"""
Main window manager
This window contains:
    - title
    - add new track
    - bpm
    - tracks
    - play/stop
"""


def create_master_window():
    # Create the main window
    window = tk.Tk()
    window.title("Master")
    window.geometry("512x512")
    # Disable window resizing
    window.resizable(width=False, height=False)

    # the tracks
    tracks = []

    # BPM
    bpm = tk.StringVar()
    bpm.set("60")

    # Create the canvas
    canvas = tk.Canvas(window, width=512, height=512, bg="dodger blue")
    canvas.place(x=0, y=0)

    # Master text
    master_text = canvas.create_text(256, 20, text="Master Loop", font=("Arial", 12))
    canvas.tag_raise(master_text)

    # Create new track object
    new_track_button = tk.Button(window, text="Add new Track", bg="gold",
                                 command=lambda: add_new_track(window, canvas, tracks))
    new_track_button.place(x=40, y=40)
    new_track_button.lift()

    # BPM text
    bpm_text = canvas.create_text(302, 60, text="BPM:", font=("Arial", 12))
    canvas.tag_raise(bpm_text)

    # BPM box
    bpm_box_var = tk.StringVar()
    bpm_box_var.set("60")
    bpm_box = ttk.Spinbox(window, from_=0, to=200, textvariable=bpm_box_var, width=4)
    bpm_box.place(x=336, y=45)

    # Set bpm
    set_bpm_button = tk.Button(window, text="Set", bg="gold",
                               command=lambda: on_bpm_set(bpm_box_var, bpm))
    set_bpm_button.place(x=412, y=40)
    set_bpm_button.lift()

    # Play
    play_button = tk.Button(window, text="PLAY", bg="gold",
                            command=lambda: play_all_tracks(tracks, bpm))
    play_button.place(x=166, y=462)
    play_button.lift()

    # Stop
    stop_button = tk.Button(window, text="STOP", bg="gold",
                            command=lambda: stop_all_tracks(tracks))
    stop_button.place(x=276, y=462)
    stop_button.lift()

    # Window loop
    window.mainloop()


"""
functions:
    - on_bpm_set: save the new set bpm
    - play_all_tracks: checks that all the instruments have been initialized, then plays
    - stop_all_tracks: stops the execution of all tracks
"""


def on_bpm_set(bpm_box_var, curr_bpm):
    read_bpm = bpm_box_var.get()
    curr_bpm.set(read_bpm)
    print("BPM: ", int(curr_bpm.get()))


def play_all_tracks(tracks, _bpm):
    bpm = int(_bpm.get())
    if bpm == 0:
        error_window = ErrorWindow("BPM Error", "Error: BPM = 0")
    elif not tracks:
        error_window = ErrorWindow("Empty Tracks Error", "Error: No Tracks")
    else:
        for t in tracks:
            if not t.instrument:
                error_window = ErrorWindow("No Instrument", "Error: No Instrument")
            elif not t.instrument.ready:
                error_window = ErrorWindow("Instrument not Ready", "Open the Instrument")
            else:
                t.instrument.play(bpm)


def stop_all_tracks(tracks):
    if not tracks:
        error_window = ErrorWindow("Empty Tracks Error", "Error: No Tracks")
    else:
        for t in tracks:
            if not t.instrument:
                error_window = ErrorWindow("No Instrument", "Error: No Instrument")
            elif not t.instrument.ready:
                error_window = ErrorWindow("Instrument not Ready", "Open the Instrument")
            else:
                t.instrument.stop()
