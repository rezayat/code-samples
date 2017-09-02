import requests

API = 'http://172.16.149.136'
LOGIN = API + '/login'
INVOICE = API + '/api/invoice'

def test_client():
    r = requests.post(LOGIN, data={'username':'rawad', 
                                   'pass':'1234'})
    jwt = r.json()[0]['token']
    headers = {'Authorization': 'Bearer ' + jwt}
    r = requests.get(INVOICE, headers=headers)
    assert 'salesman' in r.json()[0]
