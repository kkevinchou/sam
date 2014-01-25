def get_min_max_x_y(points):
    x_values = [x for x, y in points]
    y_values = [y for x, y in points]

    min_x = min(x_values)
    max_x = max(x_values)
    min_y = min(y_values)
    max_y = max(y_values)

    return min_x, max_x, min_y, max_y

class Rect(object):
    def __init__(self, x, y, points):
        self.x = x
        self.y = y
        self.points = points

    def intersects(self, other):
        self_offset_points = []

        self_world_points = [(x + self.x, y + self.y) for x, y in self.points]
        other_world_points = [(x + other.x, y + other.y) for x, y in other.points]

        self_min_x, self_max_x, self_min_y, self_max_y = get_min_max_x_y(self_world_points)
        other_min_x, other_max_x, other_min_y, other_max_y = get_min_max_x_y(other_world_points)

        return not (self_min_x > other_max_x or self_max_x < other_min_x or self_min_y > other_max_y or self_max_y < other_min_y)
