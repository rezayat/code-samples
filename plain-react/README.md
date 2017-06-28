# django-react

An adaptation of [Flask-React](https://testdriven.io) project's Part 1 and Part 2 using Django in place of Flask.

# How to run

```
$ docker-compose build
$ docker-compose up
$ python -m webbrowser http://localhost
```

# Infrastructure

The current configuration allows for a containerized application that uses the following architecture:

```
    Webserver(Nginx)
        == Reverse Proxy =>
            :80/ ==> Frontend:9000 (Pushstate Server)
            :80/users ==> Backend:5000 (Gunicorn)
                ==> Db:5432 (Postgres)
```
