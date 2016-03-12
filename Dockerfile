FROM alpine:3.3

MAINTAINER Maik Hummel <m@ikhummel.com>

ENV TAIGA_VERSION=1.10.0

WORKDIR /usr/local/taiga

COPY *.conf mime.types /etc/nginx/
COPY upstream.conf conf.json conf.env start /opt/

RUN buildDeps='curl tar'; \
    apk add --no-cache $buildDeps && \
    apk add --no-cache gettext nginx bash && \

    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \

    adduser -S www-data && \
    chown -R www-data:www-data /var/lib/nginx && \

    chmod +x /opt/start && \
    mkdir taiga-front-dist && \
    curl -sL "https://github.com/taigaio/taiga-front-dist/archive/$TAIGA_VERSION-stable.tar.gz" | tar xz -C taiga-front-dist --strip-components=1 && \

    apk del $buildDeps

EXPOSE 80 443

CMD /opt/start
