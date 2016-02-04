FROM nginx:1.7

MAINTAINER Maik Hummel <m@ikhummel.com>

WORKDIR /usr/local/taiga

# NginX Configuration
ADD *.conf /etc/nginx/
ADD mime.types /etc/nginx/mime.types

ADD upstream.conf.tpl 	upstream.conf
ADD conf.json 		conf.json
ADD conf.env 		conf.env
ADD start		start

RUN buildDeps='curl'; \
    set -x && \
    apt-get update && apt-get install -y $buildDeps --no-install-recommends && \
    apt-get install -y gettext-base --no-install-recommends && \

    # forward request and error logs to docker log collector
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    mkdir taiga-front-dist && \
    curl -sL 'https://github.com/taigaio/taiga-front-dist/tarball/stable' | tar xz -C taiga-front-dist --strip-components=1 && \
    cd taiga-front-dist && \

    # Handle case where distribution has files in arbitrary sub-directory
    tmpSource=`find dist -type d -name js | sed -r 's|/[^/]+$|/*|'` && \
    if [ "$tmpSource" != 'dist/*' ]; then mv $tmpSource dist/; fi && \

    # clean up
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    apt-get purge -y --auto-remove $buildDeps && \
    apt-get autoremove -y && \
    apt-get clean

EXPOSE 80 443

CMD /bin/bash /usr/local/taiga/start
