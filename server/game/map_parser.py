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
        grid = self.generate_grid(width, height)

        map_data_index = 0
        for y in range(height):
            for x in range(width):
                grid[x][y] = map_data['layers'][0]['data'][map_data_index]
                map_data_index += 1

        object_defs = map_data['tilesets'][0]['tileproperties']

        for k, v in object_defs.iteritems():
            object_defs[int(k) + 1] = object_defs.pop(k)

        # for x in range(width):
        #     for y in range(height):
        #         grid[x][y] = object_defs[grid[x][y]]

        return width, height, grid, object_defs

if __name__ == "__main__":
    MapParser().parse('maps/sample.json')
