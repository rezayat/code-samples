FROM node:7.10.0
# FROM node:latest

# set working directory
RUN mkdir /usr/src/app
WORKDIR /usr/src/app
RUN mkdir /usr/src/app/build

# add `/usr/src/app/node_modules/.bin` to $PATH
ENV PATH /usr/src/app/node_modules/.bin:$PATH

# install and cache app dependencies
ADD package.json /usr/src/app/package.json
RUN npm install
RUN npm install -g serve

# add app
# add environment variables
ARG NODE_ENV
ARG REACT_APP_USERS_SERVICE_URL=/api/users_dev/public
ARG REACT_APP_AUTHORIZATION_URL=/app

ENV NODE_ENV=$NODE_ENV
ENV REACT_APP_USERS_SERVICE_URL=$REACT_APP_USERS_SERVICE_URL
ENV REACT_APP_AUTHORIZATION_URL=$REACT_APP_AUTHORIZATION_URL

ADD . /usr/src/app

# build react app
RUN npm run build

# serve react app
CMD serve -s build
