import time
import os
from Queue import Queue
from ecs.entity.player import Player
from lib.game import Game as BaseGame
from map_parser import MapParser

from lib.ecs.component.cudpnetworkplayer import CUDPNetworkPlayer

NUM_WAIT_PLAYERS = 1

class Game(BaseGame):
    maps = [
        os.path.join(os.path.dirname(os.path.realpath(__file__)), 'maps', 'level1c.json'),
    ]

    def __init__(self, fps):
        super(Game, self).__init__(fps)
        self.in_messages = Queue()
        self.players = {}
        self.map_parser = MapParser()
        self.current_map = 0
        self.light_player = None
        self.dark_player = None

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

    def process_objects(self, objects):
        next_obj_id = 1000

        processed_objects = []
        for obj in objects:
            processed_object = {
                'kind': obj['type'],
                'x': obj['x'] + int(obj['width'] / 2),
                'y': obj['y'] + int(obj['height'] / 2),
            }

            if processed_object['kind'] == 'light_player':
                processed_object['tag'] = self.light_player
            elif processed_object['kind'] == 'dark_player':
                processed_object['tag'] = self.dark_player
            else:
                processed_object['tag'] = next_obj_id
                next_obj_id += 1

            processed_object.update(obj['properties'])
            processed_objects.append(processed_object)

        return processed_objects

    def construct_init_message(self, map_index):
        width, height, tiles, objects = self.map_parser.parse(self.maps[map_index])
        objects = self.process_objects(objects)

        message = {
            'action': 'init',
            'width': width,
            'height': height,
            'tiles': tiles,
            'objects': objects,
        }
        return message

    def send_map_init_message(self, map_index):
        init_message = self.construct_init_message(map_index)

        for player in self.players.values():
            init_message['player_tag'] = player.id
            network_component = player.get_component(CUDPNetworkPlayer.component_id)
            network_component.send_message(init_message)

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

            if self.light_player is None:
                self.light_player = player.id
            elif self.dark_player is None:
                self.dark_player = player.id

            if len(self.players) == NUM_WAIT_PLAYERS:
                self.send_map_init_message(self.current_map)
        elif message['action'] == 'change_map':
            if message['player_id'] != self.light_player:
                print 'NON-LIGHT PLAYER TRIED TO CHANGE MAP'
                return

            direction = message['direction']
            index = message.get('index', None)

            if direction == 'next':
                self.current_map += 1
                self.current_map = min(self.current_map, len(self.maps) - 1)
            elif direction == 'previous':
                self.current_map -= 1
                self.current_map = max(self.current_map, 0)

            if index is not None and index > -1 and index < len(self.maps):
                self.current_map = index

            self.send_map_init_message(sefl.current_map)
        else:
            for player in self.players.values():
                network_component = player.get_component(CUDPNetworkPlayer.component_id)
                network_component.send_message(message)

    def render(self):
        pass
