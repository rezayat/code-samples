# postgrest-elm

An extension of an earlier proof-of-concept `postgrest-rls` which uses the elm language instead of the react framework.

Note the url is hard-coded at present in:

- src/Config.hs
- scripts/test.sh
- tests/test_jwt.py

to 'http://172.16.149.136'. Obviously this should be changed

## Installation

If you are developing locally on ubuntu 16.04 LTS

```
$ ./scripts/install.sh
```

Build the docker stack

```
$ docker-compose build
```

## Usage

1. set up the stack

```
$ docker-compose up -d
```

2. build the elm app

```
$ make clean
$ make
```

3. Open browser from `public/index.html`


3. testing

```
$ ./scripts/test.sh
```
