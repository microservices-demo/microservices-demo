import os
import unittest
from os.path import expanduser

from util.Docker import Docker


class JavaServices(unittest.TestCase):
    def test_maven(self):
        script_dir = os.path.dirname(os.path.realpath(__file__))
        code_dir = script_dir + "/../../sockshop"
        home = expanduser("~")
        command = ['docker', 'run', '--rm', '-v', home + '/.m2:/root/.m2', '-v', code_dir + ':/usr/src/mymaven', '-w',
                   '/usr/src/mymaven', 'maven:3.2-jdk-8', 'mvn', 'test']
        Docker().execute(command)


if __name__ == '__main__':
    unittest.main()
