import re
from subprocess import Popen, PIPE
from random import random

# From http://blog.bordage.pro/avoid-docker-py/
class Docker:
    def kill_and_remove(self, ctr_name):
        command = ['docker', 'rm', '-f', ctr_name]
        self.execute(command)

    def random_container_name(self, prefix):
        retstr = prefix + '-'
        for i in range(5):
            retstr += chr(int(round(random() * (122-97) + 97)))
        return retstr

    def get_container_ip(self, ctr_name):
        command = ['docker', 'inspect',
                   '--format', '\'{{.NetworkSettings.IPAddress}}\'',
                   ctr_name]
        return re.sub(r'[^0-9.]*', '', self.execute(command))

    def execute(self, command):
        print("Running: " + ' '.join(command))
        p = Popen(command, stdout=PIPE, stderr=PIPE)
        out = p.stdout.read()
        stderr = p.stderr.read()
        if p.wait() != 0:
            p.stdout.close()
            p.stderr.close()
            raise RuntimeError(str(stderr, 'utf-8'))
        p.stdout.close()
        p.stderr.close()
        return str(out, 'utf-8')

    def start_container(self, container_name="", image="", cmd="", host=""):
        command = ['docker', 'run', '-d', '-h', host, '--name', container_name, image]
        self.execute(command)
