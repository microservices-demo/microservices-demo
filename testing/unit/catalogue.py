import unittest

from util.Golang import Golang


class Catalogue(unittest.TestCase):
    container_name = 'catalogue'

    def test_go(self):
        Golang(Catalogue.container_name).test()


if __name__ == '__main__':
    unittest.main()
