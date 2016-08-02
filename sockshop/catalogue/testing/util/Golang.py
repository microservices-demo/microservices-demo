import os

from util.Docker import Docker


class Golang():
    def __init__(self, container_dir, options=''):
        self.container_dir = container_dir
        self.options = options

    def test(self):
        script_dir = os.path.dirname(os.path.realpath(__file__))
        code_dir = script_dir + "/../../"

        test_container_name = self.container_dir + '-test'
        docker = Docker()
        docker.execute(['docker', 'build', '-t', test_container_name, code_dir])
        docker.execute(['docker', 'run', '--rm', test_container_name, 'go', 'test', '-test.v', self.options,
                        'github.com/weaveworks/weaveDemo/' + self.container_dir])
