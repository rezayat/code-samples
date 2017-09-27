FROM node:alpine

WORKDIR /usr/src/app
RUN mkdir -p /usr/src/app/build

ENV PATH /usr/src/app/node_modules/.bin:$PATH

ADD package.json /usr/src/app/package.json
RUN npm install
RUN npm install -g serve

ADD . /usr/src/app

RUN npm run build
