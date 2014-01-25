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

width = map_data['width']
height = map_data['height']

print 'Dimensions {} x {}'.format(width, height)

grid = generate_grid(width, height)
