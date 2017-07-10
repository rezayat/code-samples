FROM golang:1.7-alpine

RUN apk update
RUN apk add curl git

RUN mkdir -p /go/src/github.com/nuveo/prest
COPY  ./ /go/src/github.com/nuveo/prest

WORKDIR /go/src/github.com/nuveo/prest

RUN go install
CMD ["prest"]