FROM bitnami/minideb:latest

RUN mkdir -p /srv/queries

ADD ./prest /srv/prest

# COPY ./config.toml ./prest /srv/
# COPY ./queries/ /srv/queries/

RUN chmod +x /srv/prest

CMD ["/srv/prest"]
