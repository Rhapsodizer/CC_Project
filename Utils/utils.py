import tkinter as tk
from Instruments.drum_machine import DrumMachine
import math

"""
This file contains useful functions:
    - round_rectangle
    - create_hexagon
    - create_circle
    draw_play_pause_stop
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


def create_hexagon(canvas, center_x, center_y, radius):
    # Calculate coordinates of hexagon vertices
    hexagon_vertices = []
    for i in range(6):
        angle_deg = 60 * i
        angle_rad = math.radians(angle_deg)
        x = center_x + radius * math.cos(angle_rad)
        y = center_y + radius * math.sin(angle_rad)
        hexagon_vertices.extend([x, y])
    hexagon = canvas.create_polygon(hexagon_vertices, fill='#8C8C8C', outline='black')
    # Draw the hexagon
    return hexagon


def create_circle(canvas, center_x, center_y, radius):
    # Calculate coordinates of the circle bounding box
    x1 = center_x - radius
    y1 = center_y - radius
    x2 = center_x + radius
    y2 = center_y + radius

    # Draw the circle
    circle = canvas.create_oval(x1, y1, x2, y2, fill='#B4B4B4', outline='black')

    return circle


def draw_play_pause_stop(canvas, width, height):
    side = 60
    x_offset = 60
    y_offset = 30

    # Draw play icon
    play_triangle = canvas.create_polygon(width/2 - side - x_offset*0.866, height - side - y_offset,
                                          width/2 - side - x_offset*0.866 + side*0.866, height - side/2 - y_offset,
                                          width/2 - side - x_offset*0.866, height - y_offset,
                                          fill="#8C8C8C", outline="#000000")

    # Draw pause icon
    pr1 = canvas.create_rectangle(width / 2 - 30, height - side - y_offset,
                                  width / 2 - 5, height - y_offset,
                                  fill="#8C8C8C", outline="#000000")
    pr2 = canvas.create_rectangle(width / 2 - 4, height - side - y_offset,
                                  width / 2 + 5, height - y_offset,
                                  fill="#505050", outline="#505050")
    pr3 = canvas.create_rectangle(width / 2 + 5, height - side - y_offset,
                                  width / 2 + 30, height - y_offset,
                                  fill="#8C8C8C", outline="#000000")
    p = [pr1, pr2, pr3]

    # Draw stop icon
    stop_rectangle = canvas.create_rectangle(width/2 + x_offset, height - side - y_offset,
                                             width/2 + side + x_offset, height - y_offset,
                                             fill="#8C8C8C", outline="#000000")

    return [play_triangle, p, stop_rectangle]


def draw_track_elements(track_object):
    # Draw rect container
    round_rectangle(track_object.canvas,
                    track_object.pos_x, track_object.pos_y,
                    track_object.pos_x + track_object.length, track_object.pos_y + track_object.height,
                    radius=20, fill=track_object.color)

    if track_object.instr_name is None:
        track_object.canvas.create_text(track_object.pos_x + 20, track_object.pos_y + 25,
                                        text="Empty track", font=("Arial", 12), anchor=tk.W)
    else:
        track_object.canvas.create_text(track_object.pos_x + 20, track_object.pos_y + 25,
                                        text=track_object.instr_name, font=("Arial", 12), anchor=tk.W)

    hex_center_x = track_object.canvas.winfo_width() * 2 / 3 + 70
    hex_center_y = track_object.pos_y + track_object.height / 2
    hex_radius = 22
    circle_radius = 10
    # Draw settings icon (hexagon)
    settings_hexagon = create_hexagon(track_object.canvas, hex_center_x, hex_center_y, hex_radius)
    settings_circle = create_circle(track_object.canvas, hex_center_x, hex_center_y, circle_radius)

    # Draw plus icon
    horiz_plus = hex_center_x + 40
    plus_rect = track_object.canvas.create_polygon(horiz_plus, track_object.pos_y + 15,
                                                   horiz_plus + 10, track_object.pos_y + 15,
                                                   horiz_plus + 10, track_object.pos_y + 5,
                                                   horiz_plus + 30, track_object.pos_y + 5,
                                                   horiz_plus + 30, track_object.pos_y + 15,
                                                   horiz_plus + 40, track_object.pos_y + 15,
                                                   horiz_plus + 40, track_object.pos_y + track_object.height - 15,
                                                   horiz_plus + 30, track_object.pos_y + track_object.height - 15,
                                                   horiz_plus + 30, track_object.pos_y + track_object.height - 5,
                                                   horiz_plus + 10, track_object.pos_y + track_object.height - 5,
                                                   horiz_plus + 10, track_object.pos_y + track_object.height - 15,
                                                   horiz_plus, track_object.pos_y + track_object.height - 15,
                                                   fill="#8C8C8C", outline="#000000"
                                                   )

    return [settings_hexagon, settings_circle, plus_rect]


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
