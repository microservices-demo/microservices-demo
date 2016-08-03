import requests

class Api:
    def noResponse(url):
        try:
            r = requests.get(url, timeout=5)
        except requests.exceptions.ConnectionError:
            return True
        return r.status_code > 299
