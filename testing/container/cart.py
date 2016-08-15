import argparse
import sys
import unittest
from util.Api import Api
from time import sleep

from util.Docker import Docker
from util.Dredd import Dredd

class CartContainerTest(unittest.TestCase):
    TAG = "latest"
    container_name = Docker().random_container_name('cart')
    mongo_container_name = Docker().random_container_name('cart-db')
    def __init__(self, methodName='runTest'):
        super(CartContainerTest, self).__init__(methodName)
        self.ip = ""
        
    def setUp(self):
        Docker().start_container(container_name=self.mongo_container_name, image="mongo", host="cart-db")
        command = ['docker', 'run',
                   '-d',
                   '--name', CartContainerTest.container_name,
                   '-h', 'cart',
                   '--link',
                   CartContainerTest.mongo_container_name,
                   'weaveworksdemos/cart:' + self.TAG]
        Docker().execute(command)
        self.ip = Docker().get_container_ip(CartContainerTest.container_name)

    def tearDown(self):
        Docker().kill_and_remove(CartContainerTest.container_name)
        Docker().kill_and_remove(CartContainerTest.mongo_container_name)

    def test_api_validated(self):
        limit = 60
        while Api().noResponse('http://'+ self.ip +':80/carts/579f21ae98684924944651bf'):
            if limit == 0:
                self.fail("Couldn't get the API running")
            limit = limit - 1
            sleep(1)
        
        out = Dredd().test_against_endpoint("carts", "http://cart/", links=[self.mongo_container_name, self.container_name], env=[("MONGO_ENDPOINT", "mongodb://cart-db:27017/data")])
        self.assertGreater(out.find("0 failing"), -1)
        self.assertGreater(out.find("0 errors"), -1)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--tag', default="latest", help='The tag of the image to use. (default: latest)')
    parser.add_argument('unittest_args', nargs='*')
    args = parser.parse_args()
    CartContainerTest.TAG = args.tag
    # Now set the sys.argv to the unittest_args (leaving sys.argv[0] alone)
    sys.argv[1:] = args.unittest_args
    unittest.main()
