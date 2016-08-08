import argparse
import sys
import unittest
from util.Api import Api
from time import sleep

from util.Docker import Docker
from util.Dredd import Dredd

class AccountsContainerTest(unittest.TestCase):
    TAG = "latest"
    container_name = Docker().random_container_name('accounts')
    mongo_container_name = Docker().random_container_name('accounts-db')
    
    def __init__(self, methodName='runTest'):
        super(AccountsContainerTest, self).__init__(methodName)
        self.ip = ""

    def setUp(self):
        Docker().start_container(container_name=self.mongo_container_name, image="mongo", host="accounts-db")
        command = ['docker', 'run',
                   '-d',
                   '--name', AccountsContainerTest.container_name,
                   '-h', 'accounts',
                   '--link',
                   self.mongo_container_name,
                   'weaveworksdemos/accounts:' + self.TAG]
        Docker().execute(command)
        self.ip = Docker().get_container_ip(AccountsContainerTest.container_name)

    def tearDown(self):
        Docker().kill_and_remove(AccountsContainerTest.container_name)
        Docker().kill_and_remove(AccountsContainerTest.mongo_container_name)

    def test_api_validated(self):
        limit = 60
        while Api.noResponse('http://'+ self.ip +':80/addresses'):
            if limit == 0:
                self.fail("Couldn't get the API running")
            limit = limit - 1
            sleep(1)
        
        out = Dredd().test_against_endpoint("accounts/accounts.json", AccountsContainerTest.container_name, "http://accounts/", "mongodb://accounts-db:27017/data", self.mongo_container_name)
        self.assertGreater(out.find("0 failing"), -1)
        self.assertGreater(out.find("0 errors"), -1)
        print(out)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--tag', default="latest", help='The tag of the image to use. (default: latest)')
    parser.add_argument('unittest_args', nargs='*')
    args = parser.parse_args()
    AccountsContainerTest.TAG = args.tag
    # Now set the sys.argv to the unittest_args (leaving sys.argv[0] alone)
    sys.argv[1:] = args.unittest_args
    unittest.main()
