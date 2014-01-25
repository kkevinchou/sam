import json

from component import Component

class CNetworkPlayer(Component):
    component_id = 'CNetworkPlayer'

    def __init__(self, socket):
        self.socket = socket

    def send_message(self, message):
        message_json = json.dumps(message)
        self.socket.send(message_json)
