FROM debian:stable-slim
LABEL maintainer="docker@llamaq.com"

RUN apt-get update && apt-get install -y curl nginx nginx-extras apache2-utils

VOLUME /opt/webdav
VOLUME /opt/config
EXPOSE 80

ENV PUID=1000 PGID=1000
ENV HT_USER='' HT_PASS=''

COPY default.conf /etc/nginx/conf.d/default.conf
RUN rm /etc/nginx/sites-enabled/*

COPY entrypoint.sh /
RUN chmod +x entrypoint.sh

HEALTHCHECK CMD curl --fail http://localhost:81/healthcheck || exit 1
CMD /entrypoint.sh
