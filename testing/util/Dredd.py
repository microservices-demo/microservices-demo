from util.Docker import Docker
from util.Api import Api
import os
import unittest

class Dredd:
    image = 'weaveworksdemos/openapi'
    container_name = ''
    def test_against_endpoint(self, service, endpoint_container_name, api_endpoint, mongo_endpoint_url, mongo_container_name):
        self.container_name = Docker().random_container_name('openapi')
        command = ['docker', 'run',
                   '-h', 'openapi',
                   '--name', self.container_name,
                   '--link', mongo_container_name,
                   '--link', endpoint_container_name,
                   '--env', "MONGO_ENDPOINT={0}".format(mongo_endpoint_url),
                   '-v', "{0}:{1}".format(os.getcwd() + "/../openapi/specs", "/tmp/specs/"),
                   Dredd.image,
                   "/tmp/specs/{0}/{0}.json".format(service),
                   api_endpoint,
                   "-f",
                   "/tmp/specs/{0}/hooks.js".format(service)
        ]
        out = Docker().execute(command)
        Docker().kill_and_remove(self.container_name)
        return out
