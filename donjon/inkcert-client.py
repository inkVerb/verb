#!/usr/bin/python
# inkVerbDragon, verb.ink

# Server login client to connect to server port on 4444
# Based on Python tutorial docs

import socket
 
HOST = '127.0.0.1'    	# Remote host, testing uses localhost
PORT = 4444            # The same port used on the server
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((HOST, PORT))
s.send('I want to ink.')
data = s.recv(1024)
s.close()
print 'Received', repr(data)
