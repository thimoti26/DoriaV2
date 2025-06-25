FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Installation Apache, PHP et dépendances FreePBX
RUN apt-get update && apt-get install -y \
    apache2 \
    mysql-client \
    php8.1 \
    php8.1-curl \
    php8.1-cli \
    php8.1-mysql \
    php8.1-gd \
    php8.1-mbstring \
    php8.1-intl \
    php8.1-xml \
    php8.1-zip \
    php8.1-bcmath \
    libapache2-mod-php8.1 \
    wget \
    unzip \
    nodejs \
    npm \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Configuration Apache
RUN a2enmod rewrite
COPY apache-freepbx.conf /etc/apache2/sites-available/000-default.conf

# Installer FreePBX dependencies
RUN apt-get update && apt-get install -y \
    git \
    sox \
    mpg123 \
    sqlite3 \
    uuid \
    && rm -rf /var/lib/apt/lists/*

# Créer le répertoire pour FreePBX
RUN mkdir -p /var/www/html && \
    chown -R www-data:www-data /var/www/html

# Configuration PHP pour FreePBX
RUN echo "memory_limit = 256M" >> /etc/php/8.1/apache2/php.ini && \
    echo "upload_max_filesize = 128M" >> /etc/php/8.1/apache2/php.ini && \
    echo "post_max_size = 128M" >> /etc/php/8.1/apache2/php.ini && \
    echo "max_execution_time = 300" >> /etc/php/8.1/apache2/php.ini

# Télécharger et installer FreePBX
WORKDIR /usr/src
RUN git clone https://github.com/FreePBX/framework.git freepbx && \
    cd freepbx && \
    cp -r * /var/www/html/ && \
    chown -R www-data:www-data /var/www/html

# Script de démarrage et configuration
COPY start.sh /start.sh
COPY freepbx-config.php /freepbx-config.php
RUN chmod +x /start.sh

EXPOSE 80

CMD ["/start.sh"]
