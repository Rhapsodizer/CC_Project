import tkinter as tk
from tkinter import ttk
from LoopStation.track import add_new_track
from Utils.error_manager import ErrorWindow
from Utils import osc_bridge
from Utils import utils
import subprocess


# todo: bpm/loop duration
"""
Main window manager
This window contains:
    - title
    - add new track
    - bpm/loop duration 
    - tracks
    - play/stop
"""

tracks = []
_bpm = 60
_steps = 12


def create_master_window():
    # Create the main window
    window = tk.Tk()
    window.title("Master")
    window.geometry("800x700")
    # Disable window resizing
    window.resizable(width=False, height=False)

    # the tracks
    # tracks = []

    # BPM
    bpm = tk.StringVar()
    bpm.set("60")
    # STEPS
    steps = tk.StringVar()
    steps.set("12")

    # Create the canvas
    c_width = 800
    c_height = 700
    canvas = tk.Canvas(window, width=c_width, height=c_height, bg="#505050")
    canvas.pack()

    # Master text
    master_text = canvas.create_text(c_width/2, 20, text="Master Loop", font=("Arial", 12))
    canvas.tag_raise(master_text)

    # Create new track object
    new_track_button = tk.Button(window, text="Add new Track", bg="#B4B4B4",
                                 command=lambda: add_new_track(
                                     window, canvas, tracks, int(bpm_box_var.get()), int(step_box_var.get())))
    new_track_button.place(x=40, y=40)
    new_track_button.lift()

    ###########################################################################################
    # BPM text
    bpm_text = canvas.create_text(302, 60, text="BPM:", font=("Arial", 12))
    canvas.tag_raise(bpm_text)

    # BPM box
    bpm_box_var = tk.StringVar()
    bpm_box_var.set("0")
    bpm_box = ttk.Spinbox(window, from_=0, to=200, textvariable=bpm_box_var, width=4)
    bpm_box.place(x=c_width/2-70, y=45)

    # Set bpm
    set_bpm_button = tk.Button(window, text="Set", bg="#B4B4B4",
                               command=lambda: on_bpm_set(bpm_box_var, bpm))
    set_bpm_button.place(x=c_width/2, y=40)
    set_bpm_button.lift()

    # Step text
    step_text = canvas.create_text(520, 60, text="Steps:", font=("Arial", 12))
    canvas.tag_raise(step_text)

    # Step box
    step_box_var = tk.StringVar()
    step_box_var.set("0")
    step_box = ttk.Spinbox(window, from_=0, to=32, textvariable=step_box_var, width=4)
    step_box.place(x=c_width/2+160, y=45)

    # Set steps
    set_step_button = tk.Button(window, text="Set", bg="#B4B4B4",
                                command=lambda: on_step_set(step_box_var, steps))
    set_step_button.place(x=c_width/2+230, y=40)
    set_step_button.lift()

    ###########################################################################################

    # Play, Pause, Stop
    [play, pause, stop] = utils.draw_play_pause_stop(canvas, c_width, c_height)
    canvas.tag_bind(play, "<Button-1>", play_clicked)
    canvas.tag_bind(pause[0], "<Button-1>", pause_clicked)
    canvas.tag_bind(pause[1], "<Button-1>", pause_clicked)
    canvas.tag_bind(pause[2], "<Button-1>", pause_clicked)
    canvas.tag_bind(stop, "<Button-1>", stop_clicked)

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

    osc_bridge.oscDM.send_message("/setBpm", int(curr_bpm.get()))
    osc_bridge.oscCH.send_message("/setBpm", int(curr_bpm.get()))


def on_step_set(step_box_var, curr_step):
    read_step = step_box_var.get()
    curr_step.set(read_step)
    print("Steps: ", int(curr_step.get()))

    osc_bridge.oscDM.send_message("/setSteps", int(curr_step.get()))
    osc_bridge.oscCH.send_message("/setSteps", int(curr_step.get()))


def play_clicked(event):
    print("play")
    print(event)
    global tracks
    global _bpm
    # bpm = int(_bpm.get())
    bpm = _bpm
    if bpm == 0:
        ErrorWindow("BPM Error", "Error: BPM = 0")
    elif not tracks:
        ErrorWindow("Empty Tracks Error", "Error: No Tracks")
    else:
        play_all_tracks()


def pause_clicked(event):
    print("pause")
    print(event)
    osc_bridge.oscDM.send_message("/pause", 0)
    osc_bridge.oscCH.send_message("/pause", 0)


def stop_clicked(event):
    print("stop")
    print(event)
    if not tracks:
        ErrorWindow("Empty Tracks Error", "Error: No Tracks")
    else:
        stop_all_tracks()


def play_all_tracks():
    # Send broadcast START PLAY trigger
    osc_bridge.oscDM.send_message("/play", 0)
    osc_bridge.oscCH.send_message("/play", 0)
    """ for t in tracks:
        if not t.instrument:
            error_window = ErrorWindow("No Instrument", "Error: No Instrument")
        elif not t.instrument.ready:
            error_window = ErrorWindow("Instrument not Ready", "Open the Instrument")
        else:
            t.instrument.play(bpm) """


def stop_all_tracks():
    # Send broadcast STOP trigger
    osc_bridge.oscDM.send_message("/stop", 0)
    osc_bridge.oscCH.send_message("/stop", 0)
    """ for t in tracks:
        if not t.instrument:
            error_window = ErrorWindow("No Instrument", "Error: No Instrument")
        elif not t.instrument.ready:
            error_window = ErrorWindow("Instrument not Ready", "Open the Instrument")
        else:
            t.instrument.stop() """


# Open layer interaction sketch
# processing_java_path = "/home/silvio/Documenti/Poli/processing42/processing-java"
# pde_file_path = "/home/silvio/Documenti/Poli/CC_Project/DM2"
# processing_java_path = "H:\Software\processing\processing-java"
# pde_file_path = "H:\Documenti\POLIMI\\2_1\CC\Project\GitHub\CC_Project\LayerInteraction"
processing_java_path = "processing-java"
pde_file_path = "/Users/rischo95/Documents/STUDIO/POLIMI/MAGISTRALE/SECONDO_ANNO/PRIMO_SEMESTRE/CREATIVE_PROGRAMMING_AND_COMPUTING/CC_Project/LayerInteraction"

pde_open = processing_java_path + " --sketch=" + pde_file_path + " --run " + str(_steps)
subprocess.Popen(pde_open, shell=True)


# TO DO
# trigger "nextstep" every time step, having bpm and number of steps
# at the end of the loop (last nexstep) trigger an osc message to pose the cursor at 0