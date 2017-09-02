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

- click on login button
- click on invoice button

note: the data is storred using local browser storage, so there may be a need to clear history and reopen browser to flush it.

4. testing

Can be done using shell scripts

```
$ ./scripts/test.sh
```

or using pytest

```
$ pytest
```
`
