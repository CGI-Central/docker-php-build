ARG NODE_VERSION=24
ARG ALPINE_VERSION=3.22

FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION} AS node

FROM php:8.4-zts-alpine${ALPINE_VERSION} AS php

COPY --from=node /usr/lib /usr/lib
COPY --from=node /usr/local/lib /usr/local/lib
COPY --from=node /usr/local/include /usr/local/include
COPY --from=node /usr/local/bin /usr/local/bin

### BUILD it
### docker build -t docker-php-build https://raw.githubusercontent.com/alex-scott/hurrypress-phing/master/Dockerfile

# Prepare environment
RUN mkdir -p /opt && addgroup -g 1100 phing &&  adduser -h /opt/composer -s /bin/ash -g "Phing" -u 1100 -D -G phing phing

## Packages management
RUN apk update && \
    apk upgrade && \
    apk add --no-cache \
                    curl ca-certificates graphviz shadow \
                    git git-lfs patch bash tar openssh-client zip \
		            mysql-client \
                    python3 py3-pip && \
    curl -sSLf \
        -o /usr/local/bin/install-php-extensions \
        https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions && \
    chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions zip pdo_mysql && \
    rm -rf /var/cache/apk/* && rm /usr/local/bin/install-php-extensions


ENV PNPM_HOME=/pnpm 
ENV PATH=$PATH:/pnpm
RUN  mkdir /pnpm && chmod 777 /pnpm && npm install -g pnpm@latest-10

RUN  pnpm install -g sass && ln -s /usr/local/bin/sass /usr/bin/scss

RUN  cd /usr/bin/ && /usr/bin/wget https://getcomposer.org/installer -O - -q | php -- --quiet  --version=2.7.2 && \
	    mv /usr/bin/composer.phar /usr/bin/composer && ln -s /usr/bin/composer /composer.phar && \
	    mkdir -p /opt/composer/

RUN  test -f /usr/local/lib/php/Archive/Tar.php || pear install Archive_Tar

# Run environment variable, required files, etc.
ENV         PHING_UID=1100
ENV         PHING_GID=1100
ENV         PATH=$PATH:/opt/composer/vendor/bin

CMD         ["/usr/bin/php"]
