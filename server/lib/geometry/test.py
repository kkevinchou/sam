from rect import Rect

a_points = [(0, 0), (-1, 0), (-1, -1), (0, -1)]
b_points = [(0, 0), (-1, 0), (-1, -1), (0, -1)]

a_rect = Rect(0, 0, a_points)
b_rect = Rect(1, 0ls
    , b_points)

print a_rect.intersects(b_rect)
