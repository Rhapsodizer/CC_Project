import firebase_admin
from firebase_admin import db
from pythonosc import udp_client

# Connect to firebase
credential = firebase_admin.credentials.Certificate('H:/Documenti/POLIMI/2_1/CC/Project/client/certificate.json') # Change path
default_app = firebase_admin.initialize_app(credential, {
	'databaseURL': 'https://creativeproject-12185-default-rtdb.europe-west1.firebasedatabase.app'
	})

# Create OSC client sender
ip_addr = "127.0.0.1"
port = 9000
client = udp_client.SimpleUDPClient(ip_addr, port)

# Listeners
def listenerColor(event):
    client.send_message("/table/color", event.data)
    print("Color: " + event.data)

def listenerNumber(event):
    client.send_message("/table/number", float(event.data))
    print(event.data)

def listenerPosX(event):
    print(event.data)
    
def listenerPosY(event):
    print(event.data)

db.reference('table/color').listen(listenerColor)
db.reference('table/number').listen(listenerNumber)
db.reference('table/posX').listen(listenerPosX)
db.reference('table/posY').listen(listenerPosY)