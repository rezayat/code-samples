FROM blitznote/debootstrap-amd64:16.04

ENV POSTGREST_VER 0.4.2.0

RUN curl -o pg.tar.xz -L https://github.com/begriffs/postgrest/releases/download/v${POSTGREST_VER}/postgrest-${POSTGREST_VER}-ubuntu.tar.xz \
 && tar xvf pg.tar.xz -C /srv \
 && rm pg.tar.xz \
 ## install required libraries
 && apt-get update && apt-get --no-install-recommends install -y \
    libpq5 \
    libgmp10 \
 && apt-get clean \
 && apt-get autoclean \
 && apt-get -y autoremove \
 && rm -rf ${HOME}/.cache /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["/srv/postgrest","/srv/config.toml"]
