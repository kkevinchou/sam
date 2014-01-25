import json

def open_map(file):
    raw_json = ''
    with open('sample.json') as f:
        for line in f:
            raw_json += line

    return json.loads(raw_json)

def generate_grid(width, height):
    column = ['0' for y in range(height)]
    return [column[:] for x in range(width)]

map_data = open_map('sample.json')

width, height = map_data['width'], map_data['height']

print 'Dimensions {} x {}'.format(width, height)

grid = generate_grid(width, height)

map_data_index = 0
for y in range(height):
    for x in range(width):
        grid[x][y] = data[map_data_index]
        map_data_index += 1

for x in range(width):
    for y in range(height):
        grid[x][y]
