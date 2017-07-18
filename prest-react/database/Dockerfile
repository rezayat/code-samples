FROM postgres:alpine

COPY create.sql /docker-entrypoint-initdb.d/create.sql
COPY pgjwt.sql /docker-entrypoint-initdb.d/pgjwt.sql

ADD . /extension
RUN cp -a /extension/extension/. /usr/local/share/postgresql/extension/
