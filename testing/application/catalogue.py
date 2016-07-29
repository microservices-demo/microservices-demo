import argparse
import sys
import unittest
from time import sleep

import requests

from util.Docker import Docker


def noResponse(url):
    try:
        r = requests.get(url, timeout=5)
    except requests.exceptions.ConnectionError:
        return True
    return r.status_code > 299


class CatalogueApplicationTest(unittest.TestCase):
    TAG = "latest"
    container_name = 'catalogue'

    def __init__(self, methodName='runTest'):
        super(CatalogueApplicationTest, self).__init__(methodName)
        self.ip = ""
        self.front_end_ip = ""
        self.docker = Docker()

    def setUp(self):
        command = ['docker', 'run',
                   '-d',
                   '--name', CatalogueApplicationTest.container_name,
                   '-h', CatalogueApplicationTest.container_name,
                   'weaveworksdemos/catalogue:' + self.TAG]
        self.docker.execute(command)
        self.ip = self.docker.get_container_ip(CatalogueApplicationTest.container_name)
        command = ['docker', 'run',
                   '-d',
                   '--link', 'catalogue',
                   '--name', "front-end",
                   '-h', "front-end",
                   'weaveworksdemos/front-end:' + self.TAG]
        self.docker.execute(command)
        self.front_end_ip = self.docker.get_container_ip("front-end")
        while noResponse('http://' + self.front_end_ip + ':8079'):
            sleep(1)

    def tearDown(self):
        self.docker.kill_and_remove("front-end")
        self.docker.kill_and_remove(CatalogueApplicationTest.container_name)

    def test_catalogue_has_image(self):
        r = requests.get('http://' + self.front_end_ip + ':8079/catalogue', timeout=5)
        data = r.json()
        for item in data:
            for imageUrl in item['imageUrl']:
                r = requests.get('http://' + self.front_end_ip + ':8079' + imageUrl, timeout=5)
                self.assertLess(r.status_code, 299, msg=str(r.status_code) + ": error getting " + imageUrl)
                self.assertGreater(int(r.headers.get("Content-Length")), 0,
                                   msg="Issue with: " + imageUrl + ": " + r.headers.get("Content-Length"))
                self.assertEqual("image/jpeg", r.headers.get("Content-Type"),
                                 msg="Issue with: " + imageUrl + ": " + r.headers.get("Content-Type"))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--tag', default="latest", help='The tag of the image to use. (default: latest)')
    parser.add_argument('unittest_args', nargs='*')
    args = parser.parse_args()
    CatalogueApplicationTest.TAG = args.tag
    # Now set the sys.argv to the unittest_args (leaving sys.argv[0] alone)
    sys.argv[1:] = args.unittest_args
    unittest.main()
