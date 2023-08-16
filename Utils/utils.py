import tkinter as tk
from Instruments.drum_machine import DrumMachine


"""
This file contains useful functions:
    - round_rectangle
    - create_rectangle_with_centered_text
    - create_instrument: this function creates the actual instrument
            object given the name as string
"""

def round_rectangle(canvas, x1, y1, x2, y2, radius, **kwargs):

    points = [x1 + radius, y1,
              x1 + radius, y1,
              x2 - radius, y1,
              x2 - radius, y1,
              x2, y1,
              x2, y1 + radius,
              x2, y1 + radius,
              x2, y2 - radius,
              x2, y2 - radius,
              x2, y2,
              x2 - radius, y2,
              x2 - radius, y2,
              x1 + radius, y2,
              x1 + radius, y2,
              x1, y2,
              x1, y2 - radius,
              x1, y2 - radius,
              x1, y1 + radius,
              x1, y1 + radius,
              x1, y1]

    return canvas.create_polygon(points, **kwargs, smooth=True)


def create_rectangle_with_centered_text(canvas, text, text_color, text_dim, x1, y1, x2, y2, rectangle_color):
    canvas.create_rectangle(x1, y1, x2, y2, fill=rectangle_color)

    # Calculate the center of the rectangle
    center_x = (x1 + x2) // 2
    center_y = (y1 + y2) // 2

    canvas.create_text(center_x, center_y, text=text, fill=text_color, font=("Arial", text_dim))


def create_instrument(instrument_name, parameters):
    if instrument_name == "Drum Machine":
        # Create a new window
        # window = tk.Toplevel()
        window = tk.Tk()
        window.title("Drum Machine")
        window.geometry("1024x256")
        # Disable window resizing
        window.resizable(width=False, height=False)

        # Instantiate the Drum Machine
        num_of_beats = parameters[0]
        num_of_subdivisions = parameters[1]
        dm = DrumMachine(window, num_of_beats, num_of_subdivisions)
        dm.build_drums()
        return dm
    else:
        print("NOT (yet) IMPLEMENTED")
