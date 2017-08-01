FROM node:alpine

# set working directory
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
RUN mkdir /usr/src/app/build

# add `/usr/src/app/node_modules/.bin` to $PATH
ENV PATH /usr/src/app/node_modules/.bin:$PATH

# install and cache app dependencies
ADD package.json /usr/src/app/package.json
RUN npm install
RUN npm install -g serve

# add environment variables

ARG NODE_ENV=development
ARG REACT_API_URL=/api
ARG REACT_AUTHORIZATION_URL=/rpc

ENV NODE_ENV=$NODE_ENV
ENV REACT_API_URL=$REACT_API_URL
ENV REACT_AUTHORIZATION_URL=$REACT_AUTHORIZATION_URL

ADD . /usr/src/app

# build react app
RUN npm run build

# serve react app
CMD serve -s build
