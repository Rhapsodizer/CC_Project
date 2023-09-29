import sys
import time
import tkinter as tk
import math
# from Utils import osc_bridge
import Utils.osc_bridge as osc

"""
Misc functions:
"""


# def round_rectangle(canvas, x1, y1, x2, y2, radius, **kwargs):
def round_rectangle(canvas, x1, y1, x2, y2, radius, fill_color, outline_color):

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

    # return canvas.create_polygon(points, **kwargs, smooth=True, outline= )
    return canvas.create_polygon(points, fill=fill_color, smooth=True, outline=outline_color)


def create_hexagon(canvas, center_x, center_y, radius):
    # Calculate coordinates of hexagon vertices
    hexagon_vertices = []
    for i in range(6):
        angle_deg = 60 * i
        angle_rad = math.radians(angle_deg)
        x = center_x + radius * math.cos(angle_rad)
        y = center_y + radius * math.sin(angle_rad)
        hexagon_vertices.extend([x, y])
    hexagon = canvas.create_polygon(hexagon_vertices, fill='#606060', outline='black')
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


"""
Loop_station-related functions:
"""


def draw_all_ls(ls_obj):
    ls_obj.canvas.delete("all")
    # Master text
    ls_obj.canvas.create_text(ls_obj.c_width / 2, 20, text="Loop Station Manager", font=("Arial", 20))

    # elements
    [up_bpm_triangle, down_bpm_triangle, up_steps_triangle, down_steps_triangle,
     bpm_valid_rect, steps_valid_rect] = draw_bpm_steps_ls(ls_obj)
    draw_all_tracks_ls(ls_obj)
    plus_add_track = draw_plus_ls(ls_obj)
    [play, pause, stop] = draw_play_pause_stop_ls(ls_obj)
    [safe_close_button, close_x1, close_x2] = safe_close_ls(ls_obj)
    ls_obj.canvas.update()
    return [up_bpm_triangle, down_bpm_triangle, up_steps_triangle, down_steps_triangle,
            bpm_valid_rect, steps_valid_rect, plus_add_track, play, pause, stop,
            safe_close_button, close_x1, close_x2]


def draw_bpm_steps_ls(ls_obj):
    # trg
    height = 20
    side = 20

    # BPM
    draw_bpm_ls(ls_obj)
    x_set_bpm = ls_obj.c_width/2 - 65
    y_set_bpm = 70
    up_bpm_triangle = ls_obj.canvas.create_polygon(
        x_set_bpm, y_set_bpm - 2,
        x_set_bpm + side/2, y_set_bpm - height*0.866,
        x_set_bpm + side, y_set_bpm - 2,
        fill="#606060", outline="#000000")
    down_bpm_triangle = ls_obj.canvas.create_polygon(
        x_set_bpm, y_set_bpm + 2,
        x_set_bpm + side / 2, y_set_bpm + height * 0.866,
        x_set_bpm + side, y_set_bpm + 2,
        fill="#606060", outline="#000000")

    if ls_obj.bpm_is_valid:
        fill_bpm = "#006400"
    else:
        fill_bpm = "#8F0000"
    bpm_valid_rect = ls_obj.canvas.create_rectangle(
        x_set_bpm + side + 10, y_set_bpm - height/2,
        x_set_bpm + side*2 + 10, y_set_bpm + height/2,
        fill=fill_bpm, outline="#000000")

    # Steps
    x_set_steps = ls_obj.c_width / 2 + 130
    y_set_steps = 70
    draw_steps_ls(ls_obj)
    up_steps_triangle = ls_obj.canvas.create_polygon(
        x_set_steps, y_set_steps - 2,
        x_set_steps + side / 2, y_set_steps - height * 0.866,
        x_set_steps + side, y_set_steps - 2,
        fill="#606060", outline="#000000")
    down_steps_triangle = ls_obj.canvas.create_polygon(
        x_set_steps, y_set_bpm + 2,
        x_set_steps + side / 2, y_set_steps + height * 0.866,
        x_set_steps + side, y_set_steps + 2,
        fill="#606060", outline="#000000")

    if ls_obj.steps_is_valid:
        fill_steps = "#006400"
    else:
        fill_steps = "#8F0000"
    steps_valid_rect = ls_obj.canvas.create_rectangle(
        x_set_steps + side + 10, y_set_steps - height/2,
        x_set_steps + side*2 + 10, y_set_steps + height/2,
        fill=fill_steps, outline="#000000")

    return [up_bpm_triangle, down_bpm_triangle, up_steps_triangle, down_steps_triangle,
            bpm_valid_rect, steps_valid_rect]


def draw_bpm_ls(ls_obj):
    ls_obj.canvas.create_text(ls_obj.c_width / 2 - 180, 70,
                              text="BPM: " + str(ls_obj.bpm), font=("Arial", 12), anchor=tk.W)


def draw_steps_ls(ls_obj):
    ls_obj.canvas.create_text(ls_obj.c_width / 2 + 20, 70,
                              text="Steps: " + str(ls_obj.steps), font=("Arial", 12), anchor=tk.W)


def draw_all_tracks_ls(ls_obj):
    for tr in ls_obj.tracks:
        tr.draw_track()


def draw_plus_ls(ls_obj):
    # Draw plus icon
    offset_x = 100
    track_height = 50
    track_distance = 10
    offset_y = 100 + len(ls_obj.tracks) * (track_height + track_distance)
    plus_add_track = ls_obj.canvas.create_polygon(
        offset_x, offset_y + 15,
        offset_x + 10, offset_y + 15,
        offset_x + 10, offset_y + 5,
        offset_x + 30, offset_y + 5,
        offset_x + 30, offset_y + 15,
        offset_x + 40, offset_y + 15,
        offset_x + 40, offset_y + track_height - 15,
        offset_x + 30, offset_y + track_height - 15,
        offset_x + 30, offset_y + track_height - 5,
        offset_x + 10, offset_y + track_height - 5,
        offset_x + 10, offset_y + track_height - 15,
        offset_x, offset_y + track_height - 15,
        fill="#606060", outline="#000000"
        )

    return plus_add_track


def draw_play_pause_stop_ls(ls_obj):
    side = 50
    x_offset = 60
    y_offset = 30
    canvas = ls_obj.canvas
    width = ls_obj.c_width
    height = ls_obj.c_height

    # Draw play icon
    if ls_obj.play_is_able:
        play_c = "#606060"
    else:
        play_c = "#8F0000"
    play_triangle = canvas.create_polygon(width / 2 - side - x_offset * 0.866, height - side - y_offset,
                                          width / 2 - side - x_offset * 0.866 + side * 0.866,
                                          height - side / 2 - y_offset,
                                          width / 2 - side - x_offset * 0.866, height - y_offset,
                                          fill=play_c, outline="#000000")

    # Draw pause icon
    if ls_obj.pause_is_able:
        pause_c = "#606060"
    else:
        pause_c = "#8F0000"
    pr1 = canvas.create_rectangle(width / 2 - 20, height - side - y_offset,
                                  width / 2 - 5, height - y_offset,
                                  fill=pause_c, outline="#000000")
    pr2 = canvas.create_rectangle(width / 2 - 4, height - side - y_offset,
                                  width / 2 + 5, height - y_offset,
                                  fill="#808080", outline="#808080")
    pr3 = canvas.create_rectangle(width / 2 + 5, height - side - y_offset,
                                  width / 2 + 20, height - y_offset,
                                  fill=pause_c, outline="#000000")
    p = [pr1, pr2, pr3]

    # Draw stop icon
    if ls_obj.stop_is_able:
        stop_c = "#606060"
    else:
        stop_c = "#8F0000"
    stop_rectangle = canvas.create_rectangle(width / 2 + x_offset, height - side - y_offset,
                                             width / 2 + side + x_offset, height - y_offset,
                                             fill=stop_c, outline="#000000")

    return [play_triangle, p, stop_rectangle]


def safe_close_ls(ls_obj):
    x_offset = 40
    y_offset = 40
    half_diagonal = 30

    canvas = ls_obj.canvas
    width = ls_obj.c_width
    # Draw close icon
    safe_close_button = canvas.create_polygon(
        width - x_offset - half_diagonal, y_offset,
        width - x_offset, y_offset - half_diagonal,
        width - x_offset + half_diagonal, y_offset,
        width - x_offset, y_offset + half_diagonal,
        fill="#800000", outline="#000000")

    close_x1 = canvas.create_polygon(
        width - x_offset - half_diagonal / 3 - 1, y_offset - half_diagonal / 3 + 1,
        width - x_offset - half_diagonal / 3 + 1, y_offset - half_diagonal / 3 - 1,
        width - x_offset + half_diagonal / 3 + 1, y_offset + half_diagonal / 3 - 1,
        width - x_offset + half_diagonal / 3 - 1, y_offset + half_diagonal / 3 + 1,
        fill="#000000", outline="#000000")

    close_x2 = canvas.create_polygon(
        width - x_offset + half_diagonal / 3 - 1, y_offset - half_diagonal / 3 - 1,
        width - x_offset + half_diagonal / 3 + 1, y_offset - half_diagonal / 3 + 1,
        width - x_offset - half_diagonal / 3 + 1, y_offset + half_diagonal / 3 + 1,
        width - x_offset - half_diagonal / 3 - 1, y_offset + half_diagonal / 3 - 1,
        fill="#000000", outline="#000000")

    return [safe_close_button, close_x1, close_x2]


def draw_shutdown_ls(ls_obj):
    ls_obj.stop_all_tracks()
    time.sleep(0.001)
    osc.oscCH.send_message("/terminate", 0)
    osc.oscDM.send_message("/terminate", 0)
    ls_obj.tracks = None
    ls_obj.canvas.delete("all")
    ls_obj.canvas.update()
    ls_obj.canvas.config(bg="#808080")
    ls_obj.canvas.create_text(40, ls_obj.c_height / 2,
                              text="Shutting down, please wait. . .", font=("Arial", 20), anchor=tk.W)
    ls_obj.canvas.update()
    time.sleep(0.001)
    osc.cleanup()
    print("done.")
    sys.exit(0)


"""
Track-related functions:
"""


def draw_track_elements_tr(track_obj):
    side = 30
    x_offset = 20
    y_offset = 10
    # Draw rect container
    round_rectangle(track_obj.canvas,
                    track_obj.pos_x, track_obj.pos_y,
                    track_obj.pos_x + track_obj.length, track_obj.pos_y + track_obj.height,
                    radius=20, fill_color=track_obj.color, outline_color=track_obj.color)

    # Draw play_this icon
    if track_obj.this_play_is_able:
        play_c = "#606060"
    else:
        play_c = "#8F0000"
    play_this_trg = track_obj.canvas.create_polygon(
        track_obj.length / 2 - side * 0.866, track_obj.pos_y + track_obj.height - side - y_offset,
        track_obj.length / 2 - side * 0.866 + side * 0.866,
        track_obj.pos_y + track_obj.height - side / 2 - y_offset,
        track_obj.length / 2 - side * 0.866, track_obj.pos_y + track_obj.height - y_offset,
        fill=play_c, outline="#000000")

    # Draw stop_this icon
    if track_obj.this_stop_is_able:
        stop_c = "#606060"
    else:
        stop_c = "#8F0000"
    stop_this_rect = track_obj.canvas.create_rectangle(
        track_obj.length / 2 + x_offset, track_obj.pos_y + track_obj.height - side - y_offset,
        track_obj.length / 2 + side + x_offset, track_obj.pos_y + track_obj.height - y_offset,
        fill=stop_c, outline="#000000")

    if track_obj.instr_name is None:
        track_obj.canvas.create_text(track_obj.pos_x + 20, track_obj.pos_y + 25,
                                     text="Empty track", font=("Arial", 12), fill="#505050", anchor=tk.W)
    else:
        track_obj.canvas.create_text(track_obj.pos_x + 20, track_obj.pos_y + 25,
                                     text=track_obj.instr_name, font=("Arial", 12), anchor=tk.W)

    hex_center_x = track_obj.canvas.winfo_width() * 2 / 3 + 70
    hex_center_y = track_obj.pos_y + track_obj.height / 2
    hex_radius = 22
    circle_radius = 10
    # Draw settings icon (hexagon)
    settings_hexagon = create_hexagon(track_obj.canvas, hex_center_x, hex_center_y, hex_radius)
    settings_circle = create_circle(track_obj.canvas, hex_center_x, hex_center_y, circle_radius)

    # Draw plus icon
    horiz_plus = hex_center_x + 40
    plus_rect = track_obj.canvas.create_polygon(horiz_plus, track_obj.pos_y + 15,
                                                horiz_plus + 10, track_obj.pos_y + 15,
                                                horiz_plus + 10, track_obj.pos_y + 5,
                                                horiz_plus + 30, track_obj.pos_y + 5,
                                                horiz_plus + 30, track_obj.pos_y + 15,
                                                horiz_plus + 40, track_obj.pos_y + 15,
                                                horiz_plus + 40, track_obj.pos_y + track_obj.height - 15,
                                                horiz_plus + 30, track_obj.pos_y + track_obj.height - 15,
                                                horiz_plus + 30, track_obj.pos_y + track_obj.height - 5,
                                                horiz_plus + 10, track_obj.pos_y + track_obj.height - 5,
                                                horiz_plus + 10, track_obj.pos_y + track_obj.height - 15,
                                                horiz_plus, track_obj.pos_y + track_obj.height - 15,
                                                fill="#606060", outline="#000000")

    # Draw Remove icon
    x_offset = 80
    y_offset = track_obj.pos_y + track_obj.height/2
    half_diagonal = 20
    width = track_obj.canvas.winfo_width()
    # Draw close icon
    remove_button = track_obj.canvas.create_polygon(
        width - x_offset - half_diagonal, y_offset,
        width - x_offset, y_offset - half_diagonal,
        width - x_offset + half_diagonal, y_offset,
        width - x_offset, y_offset + half_diagonal,
        fill="#606060", outline="#000000")

    remove_x1 = track_obj.canvas.create_polygon(
        width - x_offset - half_diagonal / 3 - 1, y_offset - half_diagonal / 3 + 1,
        width - x_offset - half_diagonal / 3 + 1, y_offset - half_diagonal / 3 - 1,
        width - x_offset + half_diagonal / 3 + 1, y_offset + half_diagonal / 3 - 1,
        width - x_offset + half_diagonal / 3 - 1, y_offset + half_diagonal / 3 + 1,
        fill="#000000", outline="#000000")

    remove_x2 = track_obj.canvas.create_polygon(
        width - x_offset + half_diagonal / 3 - 1, y_offset - half_diagonal / 3 - 1,
        width - x_offset + half_diagonal / 3 + 1, y_offset - half_diagonal / 3 + 1,
        width - x_offset - half_diagonal / 3 + 1, y_offset + half_diagonal / 3 + 1,
        width - x_offset - half_diagonal / 3 - 1, y_offset + half_diagonal / 3 - 1,
        fill="#000000", outline="#000000")

    return [play_this_trg, stop_this_rect, settings_hexagon, settings_circle, plus_rect,
            remove_button, remove_x1, remove_x2]


"""
R&P-related functions:
"""


def handle_osc_message_rap(unused_addr, args):
    _ = unused_addr
    print(args)
    return args


def draw_toolbar_rap(rap_obj):
    # Draw rect container
    round_rectangle(rap_obj.toolbar_canvas,
                    rap_obj.toolbar_pos_x,
                    rap_obj.toolbar_pos_y,
                    rap_obj.toolbar_pos_x + rap_obj.toolbar_length,
                    rap_obj.toolbar_pos_y + rap_obj.toolbar_height,
                    radius=20, fill_color=rap_obj.toolbar_color, outline_color="#000000")

    rect_side = 60
    rect_nw_x = rap_obj.c_width/2 - 80
    rect_nw_y = rap_obj.toolbar_pos_y + 5
    circle_radius = 20
    # Draw record icon
    rec_rectangle = rap_obj.toolbar_canvas.create_rectangle(
        rect_nw_x, rect_nw_y,
        rect_nw_x + rect_side, rap_obj.toolbar_height/2 - 5,
        fill="#8C8C8C", outline="#000000")
    rec_circle = create_circle(rap_obj.toolbar_canvas, rect_nw_x + rect_side/2,
                               rect_nw_y + rect_side/2, circle_radius)
    if rap_obj.is_recording:
        rap_obj.toolbar_canvas.itemconfig(rec_circle, fill="#8F0000")
    else:
        rap_obj.toolbar_canvas.itemconfig(rec_circle, fill="#000000")

    # Draw plus icon
    horiz_plus = rap_obj.c_width/2 + 40
    plus_rect = rap_obj.toolbar_canvas.create_polygon(
        horiz_plus,      rap_obj.toolbar_pos_y + rect_side/2 - 10,
        horiz_plus + 15, rap_obj.toolbar_pos_y + rect_side/2 - 10,
        horiz_plus + 15, rap_obj.toolbar_pos_y + 5,
        horiz_plus + 45, rap_obj.toolbar_pos_y + 5,
        horiz_plus + 45, rap_obj.toolbar_pos_y + rect_side/2 - 10,
        horiz_plus + 60, rap_obj.toolbar_pos_y + rect_side/2 - 10,
        horiz_plus + 60, rap_obj.toolbar_pos_y + rect_side/2 + 20,
        horiz_plus + 45, rap_obj.toolbar_pos_y + rect_side/2 + 20,
        horiz_plus + 45, rap_obj.toolbar_pos_y + rect_side/2 + 35,
        horiz_plus + 15, rap_obj.toolbar_pos_y + rect_side/2 + 35,
        horiz_plus + 15, rap_obj.toolbar_pos_y + rect_side/2 + 20,
        horiz_plus,      rap_obj.toolbar_pos_y + rect_side/2 + 20,
        fill="#8C8C8C", outline="#000000"
        )

    if not rap_obj.loaded and not rap_obj.is_recording and not rap_obj.has_finished_recording:
        rap_obj.toolbar_canvas.create_text(rap_obj.toolbar_pos_x + 60, rap_obj.toolbar_pos_y + 100,
                                           text="No file selected", font=("Arial", 12), anchor=tk.W)
    elif rap_obj.loaded:
        rap_obj.toolbar_canvas.create_text(
            rap_obj.toolbar_pos_x + 60, rap_obj.toolbar_pos_y + 100,
            text="File name = " + rap_obj.file_title, font=("Arial", 12), anchor=tk.W)
    elif rap_obj.is_recording:
        rap_obj.toolbar_canvas.create_text(rap_obj.toolbar_pos_x + 60, rap_obj.toolbar_pos_y + 100,
                                           text="Recording for " + str(rap_obj.loop_duration) + " seconds",
                                           font=("Arial", 12), anchor=tk.W)
    elif rap_obj.has_finished_recording:
        rap_obj.toolbar_canvas.create_text(rap_obj.toolbar_pos_x + 60, rap_obj.toolbar_pos_y + 100,
                                           text="Saving recording as: " + str(rap_obj.recorded_filename),
                                           font=("Arial", 12), anchor=tk.W)

    # Draw Remove icon
    x_offset = rap_obj.toolbar_pos_x + 30
    y_offset = rap_obj.toolbar_pos_y + 100
    half_diagonal = 20
    # Draw close icon
    remove_button = rap_obj.toolbar_canvas.create_polygon(
        x_offset - half_diagonal, y_offset,
        x_offset, y_offset - half_diagonal,
        x_offset + half_diagonal, y_offset,
        x_offset, y_offset + half_diagonal,
        fill="#606060", outline="#000000")

    remove_x1 = rap_obj.toolbar_canvas.create_polygon(
        x_offset - half_diagonal / 3 - 1, y_offset - half_diagonal / 3 + 1,
        x_offset - half_diagonal / 3 + 1, y_offset - half_diagonal / 3 - 1,
        x_offset + half_diagonal / 3 + 1, y_offset + half_diagonal / 3 - 1,
        x_offset + half_diagonal / 3 - 1, y_offset + half_diagonal / 3 + 1,
        fill="#000000", outline="#000000")

    remove_x2 = rap_obj.toolbar_canvas.create_polygon(
        x_offset + half_diagonal / 3 - 1, y_offset - half_diagonal / 3 - 1,
        x_offset + half_diagonal / 3 + 1, y_offset - half_diagonal / 3 + 1,
        x_offset - half_diagonal / 3 + 1, y_offset + half_diagonal / 3 + 1,
        x_offset - half_diagonal / 3 - 1, y_offset + half_diagonal / 3 - 1,
        fill="#000000", outline="#000000")

    return [rec_rectangle, rec_circle, plus_rect, remove_button, remove_x1, remove_x2]


def draw_time_bar_rap(rap_obj):
    rap_obj.time_canvas.delete("all")
    # Draw rect container
    round_rectangle(rap_obj.time_canvas,
                    5, 5,
                    rap_obj.tc_width - 5, rap_obj.tc_height - 5,
                    radius=20, fill_color=rap_obj.toolbar_color, outline_color="#000000")
    rap_obj.time_canvas.create_text(rap_obj.tc_width/2, rap_obj.tc_height/2,
                                    text="{:.2f}".format(rap_obj.audio_time) + " / " + str(rap_obj.loop_duration),
                                    font=("Arial", 12))
