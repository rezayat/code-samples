FROM postgres:9.5

RUN sed -i "s@#log_statement = 'none'@log_statement = 'all'@" /usr/share/postgresql/9.5/postgresql.conf.sample

RUN apt-get install postgresql-contrib-9.5

ADD 00_create.sql /docker-entrypoint-initdb.d
ADD 01_pgjwt.sql /docker-entrypoint-initdb.d

ADD . /extension

RUN ls
RUN cp /extension/extension/pgjwt--0.0.1.sql /extension/extension/pgjwt.control /usr/share/postgresql/9.5/extension/

