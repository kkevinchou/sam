import time
from Queue import Queue

class Game(object):
    def __init__(self, fps):
        self.fps = fps

    def on_message(self, message):
        raise NotImplementedError()

    def update(self, delta):
        raise NotImplementedError()

    def render(self):
        raise NotImplementedError()

    def main(self):
        while True:
            self.update(0)
