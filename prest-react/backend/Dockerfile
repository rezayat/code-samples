FROM golang:1.7-alpine

RUN mkdir -p /opt/go
COPY ./alpine_prest /usr/bin
# COPY ./config.toml /opt/go
ADD . /opt/go/

WORKDIR /opt/go

CMD ["alpine_prest"]
