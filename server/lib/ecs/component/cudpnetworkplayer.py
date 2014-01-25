import json

from component import Component

class CUDPNetworkPlayer(Component):
    component_id = 'CUDPNetworkPlayer'

    def __init__(self, socket, client_address):
        self.socket = socket
        self.client_address = client_address

    def send_message(self, message):
        message_json = json.dumps(message)
        self.socket.sendto(message_json, self.client_address)
