FROM php:7.4-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    nano \
    unzip \
    mariadb-client \
    sox \
    mpg123 \
    && docker-php-ext-install mysqli pdo pdo_mysql \
    && a2enmod rewrite

# Install Node.js (required for FreePBX)
RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash - \
    && apt-get install -y nodejs

# Download and install FreePBX
WORKDIR /usr/src
RUN wget http://mirror.freepbx.org/modules/packages/freepbx/freepbx-15.0-latest.tgz \
    && tar -xzf freepbx-15.0-latest.tgz \
    && mv freepbx /var/www/html/

# Set working directory
WORKDIR /var/www/html

# Create FreePBX configuration file
COPY freepbx.conf /etc/apache2/sites-available/freepbx.conf
RUN a2dissite 000-default \
    && a2ensite freepbx

# Create directories and set permissions
RUN mkdir -p /var/lib/asterisk/sounds \
    && mkdir -p /var/log/asterisk \
    && mkdir -p /var/spool/asterisk \
    && chown -R www-data:www-data /var/www/html \
    && chown -R www-data:www-data /var/lib/asterisk \
    && chown -R www-data:www-data /var/log/asterisk \
    && chown -R www-data:www-data /var/spool/asterisk

# Copy initialization script
COPY init-freepbx.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init-freepbx.sh

EXPOSE 80

CMD ["/usr/local/bin/init-freepbx.sh"]