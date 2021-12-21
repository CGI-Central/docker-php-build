FROM        node:14-alpine3.13
MAINTAINER  Alex Scott <alex@cgi-central.net>

### BUILD it 
### docker build -t docker-php-build https://raw.githubusercontent.com/alex-scott/hurrypress-phing/master/Dockerfile

# Prepare environment
RUN         mkdir -p /opt
RUN         addgroup -g 1100 phing
RUN         adduser -h /opt/composer -s /bin/ash -g "Phing" -u 1100 -D -G phing phing

# Packages management
RUN         apk update && \
            apk upgrade && \
            # Install packages
            apk add --no-cache \
                    ca-certificates graphviz shadow \
                    git git-lfs patch bash tar openssh-client zip \
                    npm \
		    mysql-client \
                    php7-pear \
                    php7-zip \
                    php7-cli \
                    php7-ctype \
                    php7-curl \
                    php7-dom \
                    php7-json \
                    php7-mbstring \
                    php7-openssl \
                    php7-pdo_sqlite \
                    php7-phar \
                    php7-simplexml \
                    php7-tokenizer \
                    php7-xml \
                    php7-session \
                    php7-pdo_mysql \
                    php7-xmlwriter && \
            # clean
            rm -rf /var/cache/apk/*


RUN apk add --no-cache \
        python3 \
        py3-pip \
    && pip3 install --upgrade pip \
    && pip3 install --no-cache-dir \
        awscli \
    && rm -rf /var/cache/apk/*

RUN aws --version   # Just to make sure its installed alright

RUN         npm install -g sass
### xxx

RUN         ln -s /usr/bin/sass /usr/bin/scss

RUN         /usr/bin/wget https://getcomposer.org/installer -O - -q | php -- --quiet  --version=1.10.24

RUN         mkdir -p /opt/composer/

RUN         pear install Archive_Tar

# RUN         git lfs install

# Run environment variable, required files, etc.
ENV         PHING_UID  1100
ENV         PHING_GID  1100
ENV         PATH=$PATH:/opt/composer/vendor/bin

CMD         ["/usr/bin/php"]
