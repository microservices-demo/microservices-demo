from subprocess import Popen, PIPE
import re


# From http://blog.bordage.pro/avoid-docker-py/
class Docker:
    def kill_and_remove(self, ctr_name):
        for action in ('kill', 'rm'):
            command = ['docker', action, ctr_name]
            self.execute(command)

    def get_container_ip(self, ctr_name):
        command = ['docker', 'inspect',
                   '--format', '\'{{.NetworkSettings.IPAddress}}\'',
                   ctr_name]
        return re.sub(r'[^0-9.]*', '', self.execute(command))

    def execute(self, command):
        p = Popen(command, stdout=PIPE, stderr=PIPE)
        out = p.stdout.read()
        if p.wait() != 0:
            raise RuntimeError(p.stderr.read())
        p.stdout.close()
        p.stderr.close()
        return str(out, 'utf-8')
