import argparse
import sys
import unittest
import requests

from util.Api import Api
from util.Dredd import Dredd
from util.Docker import Docker
from time import sleep

class CatalogueContainerTest(unittest.TestCase):
    TAG = "latest"
    container_name = 'catalogue'
    mysql_container_name = Docker().random_container_name('catalogue-db')
    def __init__(self, methodName='runTest'):
        super(CatalogueContainerTest, self).__init__(methodName)
        self.ip = ""

    def setUp(self):
        Docker().start_container(container_name=self.mysql_container_name, image="mysql", host=self.mysql_container_name, env=[("MYSQL_ROOT_PASSWORD", "abc123"), ("MYSQL_DATABASE", "catalogue")])
        # todo: a better way to ensure mysql is up
        sleep(15)
        command = ['docker', 'run',
                   '-d',
                   '--name', CatalogueContainerTest.container_name,
                   '--link', "{}:mysql".format(self.mysql_container_name),
                   '-h', CatalogueContainerTest.container_name,
                   'weaveworksdemos/catalogue:' + self.TAG]
        Docker().execute(command)
        self.ip = Docker().get_container_ip(CatalogueContainerTest.container_name)

    def tearDown(self):
        Docker().kill_and_remove(CatalogueContainerTest.container_name)
        Docker().kill_and_remove(CatalogueContainerTest.mysql_container_name)

    def test_catalogue_has_item_id(self):
        self.wait_or_fail('http://'+ self.ip +':80/catalogue')
        r = requests.get('http://' + self.ip + '/catalogue', timeout=5)
        data = r.json()
        self.assertIsNotNone(data[0]['id'])

    def test_catalogue_has_image(self):
        self.wait_or_fail('http://'+ self.ip +':80/catalogue')
        r = requests.get('http://' + self.ip + '/catalogue', timeout=5)
        data = r.json()
        for item in data:
            for imageUrl in item['imageUrl']:
                r = requests.get('http://' + self.ip + '/' + imageUrl, timeout=5)
                self.assertGreater(int(r.headers.get("Content-Length")), 0,
                                   msg="Issue with: " + imageUrl + ": " + r.headers.get("Content-Length"))
                self.assertEqual("image/jpeg", r.headers.get("Content-Type"),
                                 msg="Issue with: " + imageUrl + ": " + r.headers.get("Content-Type"))

    def test_api_validated(self):
        self.wait_or_fail('http://'+ self.ip +':80/catalogue')
        out = Dredd().test_against_endpoint("catalogue", "http://catalogue/", links=[self.container_name, "{}:mysql".format(self.mysql_container_name)])
        self.assertGreater(out.find("0 failing"), -1)
        self.assertGreater(out.find("0 errors"), -1)
        print(out)

    def wait_or_fail(self,endpoint, limit=20):
        while Api().noResponse(endpoint):
            if limit == 0:
                self.fail("Couldn't get the API running")
                limit = limit - 1
                sleep(1)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--tag', default="latest", help='The tag of the image to use. (default: latest)')
    parser.add_argument('unittest_args', nargs='*')
    args = parser.parse_args()
    CatalogueContainerTest.TAG = args.tag
    # Now set the sys.argv to the unittest_args (leaving sys.argv[0] alone)
    sys.argv[1:] = args.unittest_args
    unittest.main()
