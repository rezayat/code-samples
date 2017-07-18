FROM bitnami/minideb:latest

RUN mkdir -p /srv/queries

COPY ./config.toml ./prest /srv/
COPY ./queries/ /srv/queries/

RUN chmod +x /srv/prest

CMD ["/srv/prest"]
