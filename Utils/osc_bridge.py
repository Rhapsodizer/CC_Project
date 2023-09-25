from pythonosc import udp_client
import firebase_admin
from firebase_admin import db
import os

# OSC definitions
ip_addr = "127.0.0.1"
port_SC = 57120  # towards supercollider
port_LI = 12000  # towards layer interaction sketch
port_DM = 12001  # towards drum machine
port_CH = 12002  # towards melody chat
oscSC = udp_client.SimpleUDPClient(ip_addr, port_SC)
oscPR = udp_client.SimpleUDPClient(ip_addr, port_LI)
oscDM = udp_client.SimpleUDPClient(ip_addr, port_DM)
oscCH = udp_client.SimpleUDPClient(ip_addr, port_CH)


# Connect to firebase
dirname = os.path.dirname(__file__)
filename = os.path.join(dirname, './certificate.json')
credential = firebase_admin.credentials.Certificate(filename)
default_app = firebase_admin.initialize_app(credential, {
    'databaseURL': 'https://creativeproject-12185-default-rtdb.europe-west1.firebasedatabase.app'
    })


# Listeners
def listener_un1(event):
    oscCH.send_message("/username", [1, event.data])


def listener_cs1(event):
    oscCH.send_message("/char", [1, event.data])


def listener_un2(event):
    oscCH.send_message("/username", [2, event.data])


def listener_cs2(event):
    oscCH.send_message("/char", [2, event.data])


# Bind listeners
un1 = db.reference('table/username1').listen(listener_un1)
cs1 = db.reference('table/charStream1').listen(listener_cs1)
un2 = db.reference('table/username2').listen(listener_un2)
cs2 = db.reference('table/charStream2').listen(listener_cs2)


# Free listeners on closing
def cleanup():
    global un1, cs1, un2, cs2
    un1.close()
    cs1.close()
    un2.close()
    cs2.close()
