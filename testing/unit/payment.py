import unittest

from util.Golang import Golang


class Payment(unittest.TestCase):
    container_name = 'payment'

    def test_go(self):
        Golang(Payment.container_name).test()


if __name__ == '__main__':
    unittest.main()
