"""
This class is the father class of all instruments
its arguments will be implemented by its children
"""


class Instrument:

    def __init__(self, name):
        self.name = name
        # instruments may need to be initialized
        # before being used. Therefore, ready is set
        # to False. When the instrument has
        # been initialized, set it to True
        self.ready = False

    """
    Signal contains information needed
    by the specific instrument to play
    """
    def play(self, signal):
        pass

    def stop(self):
        pass
