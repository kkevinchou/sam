class ObjectFactory(object):
    @staticmethod
    def construct_object(self, object_definition):
        obj_type = object_definition['type']

