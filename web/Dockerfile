FROM php:8.2-apache

# Installation des dépendances
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    zip \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Configuration des extensions PHP
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql mysqli

# Activation des modules Apache
RUN a2enmod rewrite headers

# Configuration Apache
RUN echo '<Directory /var/www/html>' >> /etc/apache2/apache2.conf \
    && echo '  AllowOverride All' >> /etc/apache2/apache2.conf \
    && echo '</Directory>' >> /etc/apache2/apache2.conf

# Création des répertoires de base
RUN mkdir -p /var/www/html/svi-admin/uploads \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Configuration du virtual host pour l'interface SVI Admin
RUN echo '<VirtualHost *:80>' > /etc/apache2/sites-available/svi-admin.conf \
    && echo '    DocumentRoot /var/www/html' >> /etc/apache2/sites-available/svi-admin.conf \
    && echo '    <Directory /var/www/html>' >> /etc/apache2/sites-available/svi-admin.conf \
    && echo '        DirectoryIndex index.html index.php' >> /etc/apache2/sites-available/svi-admin.conf \
    && echo '        Options Indexes FollowSymLinks' >> /etc/apache2/sites-available/svi-admin.conf \
    && echo '        AllowOverride All' >> /etc/apache2/sites-available/svi-admin.conf \
    && echo '        Require all granted' >> /etc/apache2/sites-available/svi-admin.conf \
    && echo '    </Directory>' >> /etc/apache2/sites-available/svi-admin.conf \
    && echo '</VirtualHost>' >> /etc/apache2/sites-available/svi-admin.conf

# Activation du site
RUN a2ensite svi-admin

# Script d'initialisation pour les permissions
RUN echo '#!/bin/bash' > /docker-entrypoint.sh \
    && echo 'set -e' >> /docker-entrypoint.sh \
    && echo '' >> /docker-entrypoint.sh \
    && echo '# Mise à jour des permissions' >> /docker-entrypoint.sh \
    && echo 'chown -R www-data:www-data /var/www/html' >> /docker-entrypoint.sh \
    && echo 'chmod -R 755 /var/www/html' >> /docker-entrypoint.sh \
    && echo 'chmod -R 775 /var/www/html/svi-admin/uploads' >> /docker-entrypoint.sh \
    && echo '' >> /docker-entrypoint.sh \
    && echo '# Création du fichier de redirection si nécessaire' >> /docker-entrypoint.sh \
    && echo 'if [ ! -f /var/www/html/index.php ]; then' >> /docker-entrypoint.sh \
    && echo '    echo "<?php header(\"Location: /svi-admin/\"); exit; ?>" > /var/www/html/index.php' >> /docker-entrypoint.sh \
    && echo 'fi' >> /docker-entrypoint.sh \
    && echo '' >> /docker-entrypoint.sh \
    && echo '# Démarrage d'\''Apache' >> /docker-entrypoint.sh \
    && echo 'exec apache2-foreground' >> /docker-entrypoint.sh \
    && chmod +x /docker-entrypoint.sh

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

EXPOSE 80

CMD ["/docker-entrypoint.sh"]
