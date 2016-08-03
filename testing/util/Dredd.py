from util.Docker import Docker
from util.Api import Api
import unittest

class Dredd:
    image = 'weaveworksdemos/openapi'
    def test_against_endpoint(self, json_spec, container_name, api_endpoint, mongo_endpoint_url, mongo_container_name):
        command = ['docker', 'run',
                   '-h', 'openapi',
                   '--name', 'openapi',
                   '--link', mongo_container_name,
                   '--link', container_name,
                   '--env', "MONGO_ENDPOINT={0}".format(mongo_endpoint_url),
                   Dredd.image,
                   "/usr/src/app/{0}".format(json_spec),
                   api_endpoint,
                   "-f",
                   "/usr/src/app/hooks.js"
        ]
        out = Docker().execute(command) 
        Docker().kill_and_remove('openapi')
        return out
