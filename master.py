"""
                                   G   __
E nhanced                          \\  ,,)_
L ooper  with                       \'-\( /
V isual                               \ | ,\\
I nteraction and                       \|_/\\
S onification                          / _ '.D
                                      / / \ |
                                     /_\  /_\\
                                    '-    '-

"""
import tkinter as tk
from LoopStation.loop_station_manager import create_loop_station_manager_window
from Utils.user import User

"""
Structure:
    |----------------|                |-------|
    |  Loop Station  |_._._._th_._._._| Instr | + + + +
    |----------------|        :       |-------|       +        |--------|
             +                |                       +        |   SC   |
             +                :       |-------|       +        |--------|
             +                |_._._._| Proc. |       +             +
             +                        |-------|       +             +
             +                            +           +             +
             +       |-----|              +           +             +
             + + + + | OSC |+ + + + + + + + + msg + + + + + + + + + +
                     |-----| 
"""


"""
Launch this script to open the main screen
"""


if __name__ == "__main__":
    root = tk.Tk()
    user = User("SA")  # SA, AG, RM
    create_loop_station_manager_window(root, user.get_user_paths())
    root.mainloop()


"""
to install tkinter:
https://www.tcl.tk/software/tcltk/
(you may need to use admin privileges)
then, pip install tkinter

to install simpleaudio:
if you get this error:
ERROR: Could not build wheels for simpleaudio, which is required to install pyproject.toml-based projects
do:
sudo apt install portaudio19-dev
then, pip install simpleaudio
"""
