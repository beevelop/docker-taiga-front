FROM nginx:1.7

MAINTAINER Maik Hummel <m@ikhummel.com>

# Install Git
RUN apt-get update -qq && apt-get install -y curl gettext-base && rm -rf /var/lib/apt/lists/*

# NginX Configuration
ADD nginx.conf /etc/nginx/nginx.conf
ADD mime.types /etc/nginx/mime.types
ADD web-http.conf /etc/nginx/web-http.conf
ADD web-https.conf /etc/nginx/web-https.conf

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

WORKDIR /usr/local/taiga

# Install taiga-front-dist
RUN \
  mkdir taiga-front-dist && \
  curl -sL 'https://github.com/taigaio/taiga-front-dist/tarball/stable' | tar xz -C taiga-front-dist --strip-components=1 && \
  cd taiga-front-dist

# Configuration and Start scripts
ADD ./conf.json conf.json
ADD ./upstream.conf upstream.conf
ADD ./conf.env conf.env
ADD ./start start
RUN chmod +x conf.env start

EXPOSE 80 443

CMD ["/usr/local/taiga/start"]
