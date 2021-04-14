FROM php:7-alpine3.12

ENV COMPOSER_HOME /tmp

RUN set -eux; \
    apk add --no-cache \
    --virtual .build-deps \
    $PHPIZE_DEPS \
    libmemcached-dev \
    postgresql-dev \
    libpng-dev \
    icu-dev \
    zstd-dev \
    ; \
    \
    pecl install --configureoptions 'enable-apcu-debug="no"' APCu-5.1.19; \
    pecl install igbinary-3.1.6; \
    pecl install --configureoptions 'with-libmemcached-dir="no" with-zlib-dir="no" with-system-fastlz="no" enable-memcached-igbinary="yes" enable-memcached-msgpack="no" enable-memcached-json="yes" enable-memcached-protocol="no" enable-memcached-sasl="no" enable-memcached-session="no"' memcached-3.1.5; \
    pecl install --configureoptions 'enable-redis-igbinary="yes" enable-redis-lzf="yes" enable-redis-zstd="yes"' redis-5.3.3; \
    \
    docker-php-ext-install pdo pdo_pgsql bcmath gd intl; \
    \
    docker-php-ext-enable \
    apcu \
    igbinary \
    memcached \
    redis \
    ; \
    \
    runDeps="$( \
    scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
    | tr ',' '\n' \
    | sort -u \
    | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )"; \
    apk add --no-cache $runDeps; \
    \
    apk del --no-network .build-deps; \
    \
    # update pecl channel definitions https://github.com/docker-library/php/issues/443
    pecl update-channels; \
    rm -rf /tmp/pear ~/.pearrc; \
    \
    rm -rf /var/cache/apk/*; \
    \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer; \
    \
    php --version; \
    composer --version

WORKDIR /app
