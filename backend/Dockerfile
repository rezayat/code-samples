FROM golang:1.7-alpine

RUN mkdir -p /opt/go
COPY ./prest /usr/bin
COPY ./config.toml /opt/go

WORKDIR /opt/go

CMD ["prest"]
