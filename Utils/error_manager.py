import tkinter as tk


"""
This class creates a custom error window
"""


class ErrorWindow:
    def __init__(self, title, error_message):
        self.window = tk.Toplevel()
        self.title = title
        self.window.title(title)
        self.window.geometry("512x64")
        self.window.resizable(width=False, height=False)

        self.canvas = tk.Canvas(self.window, width=512, height=64, bg="red")
        self.canvas.place(x=0, y=0)

        self.error_message = error_message
        error_text = self.canvas.create_text(20, 32, text=error_message, font=("Arial", 12), anchor=tk.W)
        self.canvas.tag_raise(error_text)
