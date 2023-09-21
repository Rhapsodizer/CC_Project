from pythonosc import udp_client
import firebase_admin
from firebase_admin import db
import os

# OSC definitions
ip_addr = "127.0.0.1"
port_SC = 57120 # towards supercollider
port_LI = 12000 # towards layer interaction sketch
port_DM = 12001 # towards drum machine
port_CH = 12002 # towards melody chat
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
def listenerU1(event):
    oscCH.send_message("/username", [1, event.data])
    print(event.data)

def listenerC1(event):
    oscCH.send_message("/char", [1, event.data])
    print(event.data)

def listenerU2(event):
    oscCH.send_message("/username", [2, event.data])
    
def listenerC2(event):
    oscCH.send_message("/char", [2, event.data])

db.reference('table/username1').listen(listenerU1)
db.reference('table/charStream1').listen(listenerC1)
db.reference('table/username2').listen(listenerU2)
db.reference('table/charStream2').listen(listenerC2)