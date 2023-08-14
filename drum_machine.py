import subprocess
import tkinter as tk
from drum_piece import DrumPiece
from instrument import Instrument
import osc_bridge

"""
This class defines the behavior of 
the Drum Machine instrument
"""

class DrumMachine(Instrument):

    def __init__(self, window, number_of_beats, number_of_subdivisions):
        super().__init__("Drum Machine")
        self.window = window
        self.window.resizable(width=False, height=False)
        self.canvas = tk.Canvas(self.window, width=1024, height=256)
        self.canvas.pack()

        self.number_of_beats = number_of_beats
        self.number_of_subdivisions = number_of_subdivisions
        self.number_of_notes = self.number_of_beats * self.number_of_subdivisions
        self.curr_note = 0

        # arrays for the drum pieces with their wav files
        self.hats = []
        self.hh_sound = 1 #"data/HH.wav"
        self.snares = []
        self.sd_sound = 2 #"data/SD.wav"
        self.kicks = []
        self.bd_sound = 3 #"data/BD.wav"

        # todo
        # self.pointer_player = None
        self.ready = False
        self.keep_playing = True
        

    def build_drums(self):
        """
        this function builds and shows the elements
        of the drum machine

        Each clickable square represents a note
        """
        dim = 20

        x_curr = dim
        y_offset = dim
        row = 1
        columns = self.number_of_notes

        # send dim to processing app
        DM2_PATH =  'H:/Software/processing/processing-java --sketch="H:\Documenti\POLIMI\\2_1\CC\Project\GitHub\CC_Project\DM2" --run ' + str(columns)
        subprocess.Popen(DM2_PATH)

        for c in range(columns):
            self.hats.append(DrumPiece(dim*c+x_curr, dim*row*0+y_offset, dim, "hat", c, self.canvas))
            self.snares.append(DrumPiece(dim*c+x_curr,  dim*row*2+y_offset, dim, "snare", c + columns, self.canvas))
            self.kicks.append(DrumPiece(dim*c+x_curr, dim*row*4+y_offset, dim, "kick", c + 2*columns, self.canvas))
            x_curr += dim

        # curr_height = 150
        # pointer_player_vertices = [dim, curr_height,
        #                            dim + dim // 2, curr_height - dim,
        #                            dim + dim, curr_height]
        # self.pointer_player = self.create_triangle_pointer(pointer_player_vertices)

    def play(self, bpm):
        # bpm to delta-time, milliseconds
        duration_of_a_note = int((60 / bpm) * 1000)
        self.window.after(duration_of_a_note,
                          self.play_and_move())
        self.curr_note += 1

        if self.curr_note == self.number_of_notes:
            # self.stop()
            self.curr_note = 0

        if self.keep_playing:
            self.play(bpm)

    def stop(self):
        self.keep_playing = False
        self.curr_note = 0

    def play_and_move(self):
        print(self.curr_note)
        step_size = 40

        if self.hats[self.curr_note].color == "green":
            osc_bridge.oscSC.send_message("/hat", 0)

        if self.snares[self.curr_note].color == "green":
            osc_bridge.oscSC.send_message("/kick", 0)

        if self.kicks[self.curr_note].color == "green":
            osc_bridge.oscSC.send_message("/kick", 0)
        # todo
        # self.move_pointer(step_size)

    # todo
    # def create_triangle_pointer(self, vertices):
    #     # Coordinates of the triangle
    #     x1, y1 = vertices[0], vertices[1]
    #     x2, y2 = vertices[2], vertices[3]
    #     x3, y3 = vertices[4], vertices[5]
    #
    #     # Draw the triangle on the canvas
    #     triangle_pointer = self.canvas.create_polygon(x1, y1, x2, y2, x3, y3, fill="black")
    #
    #     return triangle_pointer
    #
    # def move_pointer(self, step_size):
    #
    #     if self.curr_note == self.number_of_notes:
    #         # Bring the triangle back to the starting point
    #         self.canvas.move(self.pointer_player, -self.number_of_notes*step_size, 0)
    #     else:
    #         # Move the triangle to the right
    #         self.canvas.move(self.pointer_player, step_size, 0)