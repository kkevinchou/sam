import time
import os
from Queue import Queue
from ecs.entity.player import Player
from lib.game import Game as BaseGame
from map_parser import MapParser

from lib.ecs.component.cudpnetworkplayer import CUDPNetworkPlayer

class Game(BaseGame):
    maps = [
        os.path.join(os.path.dirname(os.path.realpath(__file__)), 'maps', 'sample.json'),
    ]

    def __init__(self, fps):
        super(Game, self).__init__(fps)
        self.in_messages = Queue()
        self.players = {}
        self.map_parser = MapParser()
        self.current_map = 0

    def on_message(self, message):
        message['timestamp'] = time.time()

        if 'player_id' in message:
            print '[Player {}] Received message: {}'.format(message['player_id'], message)

        self.in_messages.put(message)

    def _safe_get_in_message(self):
        try:
            message = self.in_messages.get(block=False)
        except:
            message = None

        return message

    def update(self, delta):
        current_timestamp = time.time()
        message = self._safe_get_in_message()
        
        # TODO: requeue a message that is not None but does not fulfill the timestamp requirement
        while message is not None:
            self.handle_message(message)
            message = self._safe_get_in_message()

    def construct_init_message(self, player_id):
        width, height, grid, object_defs = self.map_parser.parse(self.maps[self.current_map])
        message = {
            'action': 'init',
            'player_tag': player_id,
            'width': width,
            'height': height,
            'data': grid,
            'definitions': object_defs,
        }
        return message

    def send_map_init_message(self):
        for player in self.players.values():
            network_component = player.get_component(CUDPNetworkPlayer.component_id)
            network_component.send_message(self.construct_init_message(player.id))

    def handle_message(self, message):
        if message['action'] == 'player_connect':
            player = Player(
                1,
                1,
                message['player_id'],
                message['socket'],
                message['client_address'],
            )
            self.players[player.id] = player

            if len(self.players) == 1:
                self.send_map_init_message()
        else:
            for player in self.players.values():
                network_component = player.get_component(CUDPNetworkPlayer.component_id)
                network_component.send_message(message)

    def render(self):
        pass
