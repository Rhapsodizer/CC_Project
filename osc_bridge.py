from pythonosc import udp_client

ip_addr = "127.0.0.1"
port_SC = 57120
port_PR = 12000
oscSC = udp_client.SimpleUDPClient(ip_addr, port_SC)
oscPR = udp_client.SimpleUDPClient(ip_addr, port_PR)