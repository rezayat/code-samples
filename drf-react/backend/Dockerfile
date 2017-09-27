FROM python:alpine3.6

ENV PYTHONUNBUFFERED 1

RUN apk add --no-cache --virtual .build-deps \
        build-base \
        python-dev \
        postgresql-dev \
        libev-dev \
     && apk add --no-cache \
        libstdc++ \
        libev \
        libpq \
        zlib \
        pcre \
        openssl \
        uwsgi-python3

ADD ./requirements.txt /app/requirements.txt

RUN pip install -r /app/requirements.txt

ADD ./ /app
