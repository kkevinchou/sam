from lib.ecs.entity.entity import Entity
from lib.ecs.component.cudpnetworkplayer import CUDPNetworkPlayer

class Player(Entity):
    def __init__(self, x, y, player_id, socket, client_address):
    	super(Player, self).__init__()
        self.id = player_id
        self.x = x
        self.y = y

        self.add_component(CUDPNetworkPlayer(socket, client_address))

    def __eq__(self, other):
        if isinstance(other, Player):
            return other.id == self.id

        return False
