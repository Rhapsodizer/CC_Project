from pythonosc import udp_client

ip_addr = "127.0.0.1"
port_SC = 57120 # towards supercollider
port_LI = 12000 # towards layer interaction sketch
port_DM = 12001 # towards drum machine
port_CH = 12002 # towards melody chat
oscSC = udp_client.SimpleUDPClient(ip_addr, port_SC)
oscPR = udp_client.SimpleUDPClient(ip_addr, port_LI)
oscDM = udp_client.SimpleUDPClient(ip_addr, port_DM)
oscCH = udp_client.SimpleUDPClient(ip_addr, port_CH)