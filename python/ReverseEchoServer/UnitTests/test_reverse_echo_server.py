import os
import socket
import subprocess
from time import sleep
from unittest import TestCase

from ReverseEchoServer import reverse_echo_server


class TestReverse_echo_server(TestCase):

    test_string = 'abcdefghijklmnopqrstuvwxyz'
    expected_string = 'zyxwvutsrqponmlkjihgfedcba'
    server_port = 9999
    server_address = 'localhost'


    def setUp(self):
        self.sock_server = reverse_echo_server(self.server_port)
        #Todo find a better way to start the server, mocking is an option, but this works for now.
        self.p_handle = subprocess.Popen(["python", os.path.abspath('./../ReverseEchoServer.py')])


    def tearDown(self):
        #Kill the reverse echo server.
       self.p_handle.kill()


    def test_reverse_string(self):
        self.assertEqual(self.sock_server.reverse_string(self.test_string), self.expected_string)


    def test_reverse_listener(self):

        self.sock_client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        #Todo find a better way to determine is port is open.
        sleep(2)
        self.sock_client.connect_ex((self.server_address, self.server_port))

        try:
            self.sock_client.sendall(self.test_string)

            # Check for response
            amount_recieved = 0
            amount_expected = len(self.test_string)

            while amount_recieved < amount_expected:
                self.received_data = self.sock_client.recv(1024)
                amount_recieved += len(self.received_data)

        finally:
            self.sock_client.close()


        self.assertEqual(self.received_data, self.expected_string)
