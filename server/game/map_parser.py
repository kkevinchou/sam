import json
from object_factory import ObjectFactory

class MapParser(object):
    def open_map(self, map_file):
        raw_json = ''
        with open(map_file) as f:
            for line in f:
                raw_json += line

        return json.loads(raw_json)

    def generate_grid(self, width, height):
        column = ['0' for y in range(height)]
        return [column[:] for x in range(width)]

    def print_grid(self, grid, width, height):
        for y in range(height):
            row = []
            for x in range(width):
                row.append(str(grid[x][y]).zfill(3))
            print ' '.join(row)

    def parse(self, map_file):
        map_data = self.open_map(map_file)

        width, height = map_data['width'], map_data['height']
        tiles = map_data['layers'][0]['data']
        objects = map_data['layers'][1]['objects']

        # for k, v in object_defs.iteritems():
        #     object_defs[int(k) + 1] = object_defs.pop(k)

        # for x in range(width):
        #     for y in range(height):
        #         grid[x][y] = object_defs[grid[x][y]]

        return width, height, tiles, objects

if __name__ == "__main__":
    MapParser().parse('maps/sample.json')
