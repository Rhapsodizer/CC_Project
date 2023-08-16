from Utils import osc_bridge

"""
This class defines the single element of the
single piece of the drum machine

it is shown as a clickable square that
can be toggled red/green (inactive/active)
"""


class DrumPiece:
    def __init__(self, pos_x, pos_y, dim, dp_type, dp_id, canvas):
        self.pos_x = pos_x
        self.pos_y = pos_y
        self.dim = dim
        self.id = dp_id  # array starts at 0
        self.type = dp_type
        self.color = "red"
        self.canvas = canvas
        self.note = self.canvas.create_rectangle(
                self.pos_x, self.pos_y, self.pos_x+self.dim, self.pos_y+self.dim, fill=self.color)
        self.canvas.tag_bind(self.note, '<Button-1>', self.toggle)

    def toggle(self, event):
        print(event)
        new_color = "red" if self.color != "red" else "green"
        self.canvas.itemconfig(self.note, fill=new_color)
        self.color = new_color
        #self.play_wav()
        if self.color == "green":
            osc_bridge.oscSC.send_message("/" + self.type, 0)
            osc_bridge.oscPR.send_message("/" + self.type + "/on", self.id)
        else:
            osc_bridge.oscPR.send_message("/" + self.type + "/off", self.id)
    
    """
    def play_wav(self):
        # Play the WAV file using simpleaudio
        wave_obj = sa.WaveObject.from_wave_file(self.wav_file)
        play_obj = wave_obj.play()
        print(play_obj)
    """
