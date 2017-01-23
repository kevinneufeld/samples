import socket
import sys


class reverse_echo_server:

    #constructor
    def __init__(self, port):
        self.server_address = ('localhost', port)
        return

    def reverse_string(self, a_string):
        return a_string[::-1]

    def start_listener(self):
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        print >>sys.stderr, 'Starting up on %s port %s' % self.server_address

        self.sock.bind(self.server_address)

        self.sock.listen(1)

        while True:
            # Wait for connections
            print >>sys.stderr, 'Waiting for a connection'
            connection, client_address = self.sock.accept()

            try:
                print >>sys.stderr, 'connection from', client_address
                while True:
                    data = connection.recv(1024)
                    print >>sys.stderr, 'recieved "%s"' % data
                    if data:
                        rev_data = self.reverse_string(data)
                        print >> sys.stderr, 'sending data back to client: %s' % rev_data

                        connection.sendall(rev_data)
                    else:
                        print >> sys.stderr, 'no more data from', client_address
                        break
            finally:
                # cleanup connection
                connection.close()

    def stop_listener(self):
        self.sock.shutdown()
        self.sock.close()
        return

if __name__ == '__main__':
    server_sock = reverse_echo_server(9999)
    server_sock.start_listener()
