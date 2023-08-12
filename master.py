import loop_station_manager

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
Launch this script to open the main screen
"""
if __name__ == "__main__":
    loop_station_manager.create_master_window()

# todo: implement the stop button
# todo: implement the moving cursor under the drum machine
# todo: add new instruments
# todo: also check @track.open_instrument
