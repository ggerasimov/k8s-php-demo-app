FROM node:lts-alpine as node_build
ENV PHPMYADMIN_VERSION=RELEASE_5_1_4
WORKDIR /app
RUN apk add --no-cache git && \
    git clone --depth=1 --branch ${PHPMYADMIN_VERSION} https://github.com/phpmyadmin/phpmyadmin.git /app && \
    rm -rf /app/.git && \
    yarn install --production

FROM composer:2.3.5 as composer_build
COPY --from=node_build /app/composer.json /app/composer.lock .
RUN docker-php-ext-install mysqli && composer update --no-dev

FROM busybox
COPY --chown=www-data --from=node_build /app/ /var/www/html/
COPY --chown=www-data --from=composer_build /app/vendor/ /var/www/html/vendor/
