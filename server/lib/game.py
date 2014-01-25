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
        max_frame_time = 0.25
        fixed_update_dt = 0.01
        accumulated_time = 0
        current_time = time.time()
        last_render_time = 0
        sec_per_render = 1 / float(self.fps)

        while True:
            new_time = time.time()
            frame_time = new_time - current_time
            current_time = new_time

            if frame_time >= max_frame_time:
                frame_time = max_frame_time

            accumulated_time += frame_time

            while accumulated_time >= fixed_update_dt:
                accumulated_time -= fixed_update_dt
                self.update(fixed_update_dt)

            if current_time - last_render_time > sec_per_render:
                last_render_time = current_time
                self.render()
