# import sys
# import os
# sys.path.append(os.getcwd())
# print sys.path

import json
from gevent import pywsgi
from geventwebsocket.handler import WebSocketHandler

class Receiver(object):
    def __init__(self, game):
        self.game = game

    def __call__(self, environ, start_response):
        websocket = environ['wsgi.websocket']
        player_id = self.game.on_client_connect(websocket)

        while True:
            recv_data = websocket.receive()

            if recv_data is None:
                break

            message_dict = json.loads(recv_data)
            message_dict['player_id'] = player_id
            self.game.on_message_received(message_dict)

        self.game.on_client_disconnect(player_id)

    def start(self):
        server = pywsgi.WSGIServer(("", 8000), self, handler_class=WebSocketHandler)
        server.serve_forever()
