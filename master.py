from LoopStation import loop_station_manager

"""
Launch this script to open the main screen
"""
if __name__ == "__main__":
    loop_station_manager.create_master_window()

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

"""
colors: 0   - #000000 - "black"
        80  - #505050
        140 - #8C8C8C
        180 - #B4B4B4
        220 - #DCDCDC
        255 - #FFFFFF - "white"
"""
