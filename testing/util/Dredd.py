from util.Docker import Docker
from util.Api import Api
import unittest

class Dredd:
    image = 'weaveworksdemos/openapi'
    container_name = ''
    def test_against_endpoint(self, json_spec, endpoint_container_name, api_endpoint, mongo_endpoint_url, mongo_container_name):
        self.container_name = Docker().random_container_name('openapi')
        command = ['docker', 'run',
                   '-h', 'openapi',
                   '--name', self.container_name,
                   '--link', mongo_container_name,
                   '--link', endpoint_container_name,
                   '--env', "MONGO_ENDPOINT={0}".format(mongo_endpoint_url),
                   Dredd.image,
                   "/usr/src/app/{0}".format(json_spec),
                   api_endpoint,
                   "-f",
                   "/usr/src/app/hooks.js"
        ]
        out = Docker().execute(command)
        Docker().kill_and_remove(self.container_name)
        return out
