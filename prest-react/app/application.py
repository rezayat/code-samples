import jwt
import json
from flask import Flask, request, Response

app = Flask(__name__)
JWT_KEY = 'not_secret_at_all'

users = {
    "admin": {
        "userid": 1,
        "username": 'admin',
        "full_name": 'administrator',
        "password": '123456789',
    },
    "rawad": {
        "userid": 2,
        "username": 'rawad',
        "full_name": 'rawadov rakov',
        "password": '123456789',
    },
    "jawad": {
        "userid": 3,
        "username": 'jawad',
        "full_name": 'jawadov jakov',
        "password": '123456789',
    },
    "ziad": {
        "userid": 4,
        "username": 'ziad',
        "full_name": 'ziadov zikov',
        "password": '123456789',
    },
    "iyad": {
        "userid": 5,
        "username": 'iyad',
        "full_name": 'iyadov iykov',
        "password": '123456789',
    },
    "imad": {
        "userid": 5,
        "username": 'imad',
        "full_name": 'imadov imkov',
        "password": '123456789',
    },
    "jihad": {
        "userid": 5,
        "username": 'jihad',
        "full_name": 'jihadov jikov',
        "password": '123456789',
    },
}


@app.route('/')
def test_page():
    return 'Flask Successful'


@app.route('/login', methods=["POST"])
def login():
    json_dict = request.get_json(force=True)
    # print(json_dict)

    if not json_dict:
        print('no json dict')
        return Response(status=400)

    username = json_dict['username']
    password = json_dict['password']

    if not all([username, password]):
        print ('empty username or password')
        return Response(status=400)

    if username not in users or password != users[username]['password']:
        print ('username or password missmatch')
        return Response(status=401)

    data = {k: v for k, v in users[username].items() if k != 'password'}

    token = jwt.encode(data, JWT_KEY, algorithm='HS256')
    auth_text = str('bearer ' + token.decode('utf-8'))

    resp = Response(
        response=json.dumps(data, indent=4),
        status=200,
        mimetype="application/json")
    resp.headers["Authorization"] = auth_text
    return resp

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=4000)
