import argparse
import sys
import unittest

import requests

from util.Docker import Docker


class CatalogueContainerTest(unittest.TestCase):
    TAG = "latest"
    container_name = 'catalogue'

    def __init__(self, methodName='runTest'):
        super(CatalogueContainerTest, self).__init__(methodName)
        self.ip = ""

    def setUp(self):
        command = ['docker', 'run',
                   '-d',
                   '--name', CatalogueContainerTest.container_name,
                   '-h', CatalogueContainerTest.container_name,
                   'weaveworksdemos/catalogue:' + self.TAG]
        Docker().execute(command)
        self.ip = Docker().get_container_ip(CatalogueContainerTest.container_name)

    def tearDown(self):
        Docker().kill_and_remove(CatalogueContainerTest.container_name)

    def test_catalogue_has_item_id(self):
        r = requests.get('http://' + self.ip + '/catalogue', timeout=5)
        data = r.json()
        self.assertIsNotNone(data[0]['id'])

    def test_catalogue_has_image(self):
        r = requests.get('http://' + self.ip + '/catalogue', timeout=5)
        data = r.json()
        for item in data:
            for imageUrl in item['imageUrl']:
                r = requests.get('http://' + self.ip + '/' + imageUrl, timeout=5)
                self.assertGreater(int(r.headers.get("Content-Length")), 0,
                                   msg="Issue with: " + imageUrl + ": " + r.headers.get("Content-Length"))
                self.assertEqual("image/jpeg", r.headers.get("Content-Type"),
                                 msg="Issue with: " + imageUrl + ": " + r.headers.get("Content-Type"))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--tag', default="latest", help='The tag of the image to use. (default: latest)')
    parser.add_argument('unittest_args', nargs='*')
    args = parser.parse_args()
    CatalogueContainerTest.TAG = args.tag
    # Now set the sys.argv to the unittest_args (leaving sys.argv[0] alone)
    sys.argv[1:] = args.unittest_args
    unittest.main()
