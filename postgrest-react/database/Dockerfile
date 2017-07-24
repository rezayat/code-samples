FROM postgres:9.5.7-alpine

ADD . /extension
RUN cp -a /extension/extension/. /usr/local/share/postgresql/extension/
