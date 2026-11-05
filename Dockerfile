ARG PHP_VERSION=8.5
ARG NODE_VERSION=26
ARG ALPINE_VERSION=3.24

### docker build -t docker-php-build .

FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION} AS node

FROM php:${PHP_VERSION}-cli-alpine${ALPINE_VERSION}

ARG PNPM_VERSION=12.16.1

RUN         apk add --no-cache \
                    curl ca-certificates \
                    git git-lfs patch bash tar unzip zip openssh-client \
                    mariadb mariadb-client openssl \
                    python3 py3-pip \
                    libstdc++ libgcc

COPY --from=mlocati/php-extension-installer:2 /usr/bin/install-php-extensions /usr/local/bin/

# Am_Setup::PHP_EXTENSIONS not in the base image + optional ones used by core and plugins
RUN         install-php-extensions bcmath gd gmp intl mysqli pdo_mysql soap zip \
            && rm /usr/local/bin/install-php-extensions \
            && echo 'memory_limit=-1' > "$PHP_INI_DIR/conf.d/memory.ini"

COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node /usr/local/include/node /usr/local/include/node
RUN         ln -s ../lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
            && ln -s ../lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

RUN         npm install -g pnpm@${PNPM_VERSION} sass \
            && npm cache clean --force \
            && ln -s /usr/local/bin/sass /usr/bin/scss

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

COPY        --chmod=755 mysql-start /usr/local/bin/mysql-start

# MariaDB 11.4+ clients require TLS by default; build/test DB servers have none
RUN         printf '[client]\nskip-ssl\n' > /etc/my.cnf.d/zz-client-no-ssl.cnf

CMD         ["/usr/local/bin/php"]
