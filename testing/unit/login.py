import unittest

from util.Golang import Golang


class Login(unittest.TestCase):
    container_name = 'login'

    def test_go(self):
        Golang(Login.container_name).test()


if __name__ == '__main__':
    unittest.main()
