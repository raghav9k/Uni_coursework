import time
from socket import *

pings = 0

#Send ping 10 times 
while pings < 11:  

    #Create a UDP socket
    clientSocket = socket(AF_INET, SOCK_DGRAM)

    #Set a timeout value of 1 second
    clientSocket.settimeout(1)

    message = "ping %d %f"%(pings,time.time())

    addr = ('10.0.0.1', 1932)
    start = time.time()
    clientSocket.sendto(message, addr)
    print(addr)
    try:
        data, server = clientSocket.recvfrom(1024)
        end = time.time()
        elapsed = end - start
        print ("%s %f %f"% (data,end,elapsed))       
        
    except timeout:
        print ('REQUEST TIMED OUT')

    pings = pings + 1
