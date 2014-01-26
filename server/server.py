import json
import threading
import time
import SocketServer

from game.game import Game

class SamServer(SocketServer.UDPServer):
    def __init__(self, *args, **kwargs):
        self.initialized = True
        self.clients = {}
        self.game = Game(60)
        self.game_thread = threading.Thread(target=self.game.main)
        self.game_thread.daemon = True
        self.game_thread.start()
        self.next_player_id = 0
        SocketServer.UDPServer.__init__(self, *args, **kwargs)


class SocketHandler(SocketServer.BaseRequestHandler):
    """
    This class works similar to the TCP handler class, except that
    self.request consists of a pair of data and client socket, and since
    there is no connection the client address must be given explicitly
    when sending data back via sendto().
    """

    def handle(self):
        # print 'handle {}'.format(int(time.time()))
        clients = self.server.clients
        next_player_id = self.server.next_player_id
        game = self.server.game

        if self.client_address not in clients:
            clients[self.client_address] = next_player_id
            self.server.next_player_id += 1

        player_id = clients[self.client_address]

        data = self.request[0].strip()
        message = json.loads(data)
        message['player_id'] = player_id

        if message['action'] == 'player_connect':
            message['socket'] = self.request[1]
            message['client_address'] = self.client_address

        game.on_message(message)

if __name__ == '__main__':
    HOST, PORT = "127.0.0.1", 1234
    server = SamServer((HOST, PORT), SocketHandler)
    server.serve_forever()

# import SocketServer

# class MyUDPHandler(SocketServer.BaseRequestHandler):
#     """
#     This class works similar to the TCP handler class, except that
#     self.request consists of a pair of data and client socket, and since
#     there is no connection the client address must be given explicitly
#     when sending data back via sendto().
#     """

#     def handle(self):
#         data = self.request[0].strip()
#         socket = self.request[1]
#         print "{} wrote:".format(self.client_address[0])
#         print data
#         socket.sendto(data.upper(), self.client_address)

# if __name__ == "__main__":
#     HOST, PORT = "localhost", 8887
#     server = SocketServer.UDPServer((HOST, PORT), MyUDPHandler)
#     server.serve_forever()
