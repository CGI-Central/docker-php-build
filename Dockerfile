FROM php:7.4-zts-alpine3.16
MAINTAINER  Alex Scott <alex@cgi-central.net>

### BUILD it 
### docker build -t docker-php-build https://raw.githubusercontent.com/alex-scott/hurrypress-phing/master/Dockerfile

# Prepare environment
RUN         mkdir -p /opt
RUN         addgroup -g 1100 phing
RUN         adduser -h /opt/composer -s /bin/ash -g "Phing" -u 1100 -D -G phing phing

## Packages management
RUN         apk update && \
            apk upgrade && \
            apk add --no-cache \
                    curl ca-certificates graphviz shadow \
                    git git-lfs patch bash tar openssh-client zip \
                    npm nodejs-current \
		            mysql-client \
                    python3 py3-pip

RUN curl -sSLf \
        -o /usr/local/bin/install-php-extensions \
        https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions && \
    chmod +x /usr/local/bin/install-php-extensions


RUN install-php-extensions zip pdo_mysql

# clean
RUN rm -rf /var/cache/apk/* && rm /usr/local/bin/install-php-extensions


RUN pip3 install --upgrade pip \
   && pip3 install --no-cache-dir awscli \
    && rm -rf /var/cache/apk/*

RUN aws --version   # Just to make sure its installed alright

RUN         npm install -g npm@8.19.4

RUN         npm install -g sass

RUN         ln -s /usr/local/bin/sass /usr/bin/scss

RUN         cd /usr/bin/ && /usr/bin/wget https://getcomposer.org/installer -O - -q | php -- --quiet  --version=2.7.2

RUN         mv /usr/bin/composer.phar /usr/bin/composer && ln -s /usr/bin/composer /composer.phar

RUN         mkdir -p /opt/composer/

RUN         test -f  /usr/local/lib/php/Archive/Tar.php || pear install Archive_Tar

# Run environment variable, required files, etc.
ENV         PHING_UID  1100
ENV         PHING_GID  1100
ENV         PATH=$PATH:/opt/composer/vendor/bin

CMD         ["/usr/bin/php"]
