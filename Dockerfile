# vim: set ft=dockerfile:
FROM alpine:latest
# Author with no obligation to maintain
LABEL author="Paul Tötterman <paul.totterman@iki.fi>"

COPY entrypoint.sh /entrypoint.sh
RUN apk --no-cache add \
    ca-certificates \
    curl \
    git \
    php7-bcmath \
    php7-curl \
    php7-fpm \
    php7-gd \
    php7-json \
    php7-ldap \
    php7-mbstring \
    php7-pcntl \
    php7-pdo_mysql \
    php7-session \
    php7-snmp \
    && chmod +x /entrypoint.sh \
    && curl -sSLo /racktables.tar.gz "https://github.com/RackTables/racktables/archive/$(git ls-remote --tags https://github.com/RackTables/racktables.git | tail -1 | cut -d\/ -f3).tar.gz" \
    && tar -xz -C /opt -f /racktables.tar.gz \
    && mv /opt/racktables-$(git ls-remote --tags https://github.com/RackTables/racktables.git | tail -1 | cut -d\/ -f3) /opt/racktables \
    && rm -f /racktables.tar.gz \
    && sed -i \
    -e 's|^listen =.*$|listen = 9000|' \
    /etc/php7/php-fpm.d/www.conf \
    && sed -i \
    -e 's|^;daemonize = .*|daemonize = no|' \
    /etc/php7/php-fpm.conf

RUN apk add git \
   && git clone https://github.com/collabnix/racktables-contribs \
   && cd racktables-contribs/extensions \
   && cp -r plugins/* /opt/racktables/plugins/

VOLUME /opt/racktables/wwwroot
EXPOSE 9000
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/php-fpm7"]
