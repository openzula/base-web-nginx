FROM nginx:stable
LABEL maintainer="alex@openzula.org"

EXPOSE 80 443

##
# General
##
RUN apt-get update
RUN apt-get install -y cron certbot python3-certbot-dns-route53

COPY ./bin/oz-start /usr/local/bin/oz-start
RUN chmod u+x /usr/local/bin/oz-start

##
# TLS (Let's Encrypt)
# @todo - Split this into a separate Docker container
##
RUN (crontab -l; echo "0 6 * * * /usr/local/bin/oz-sslmanager renew && /usr/sbin/service nginx reload") | crontab

RUN mkdir -p /etc/letsencrypt/live/ebcert

COPY ./config/ssl-cert-snakeoil.pem /etc/letsencrypt/live/ebcert/fullchain.pem
COPY ./config/ssl-cert-snakeoil.key /etc/letsencrypt/live/ebcert/privkey.pem

RUN chmod -R 0640 /etc/letsencrypt/live/ebcert/*.pem

COPY ./bin/oz-sslmanager /usr/local/bin/
RUN chmod u+x /usr/local/bin/oz-sslmanager

##
# Source files & config
##
COPY ./config/vhost.conf /etc/nginx/conf.d/default.conf.template
COPY ./src/ /var/www/public/

CMD /usr/local/bin/oz-start
