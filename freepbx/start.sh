#!/bin/bash

# Attendre que MySQL soit prêt
echo "Attente de MySQL..."
while ! mysqladmin ping -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" --silent; do
    sleep 1
done

echo "MySQL est prêt, configuration de FreePBX..."

# Générer la configuration FreePBX
php /freepbx-config.php

# Créer la base de données FreePBX si elle n'existe pas
mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS asterisk;"
mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" -e "GRANT ALL PRIVILEGES ON asterisk.* TO '$DB_USER'@'%';"

# Attendre qu'Asterisk soit prêt
echo "Attente d'Asterisk..."
while ! nc -z $ASTERISK_HOST 5038; do
    sleep 1
done

echo "Asterisk est prêt, démarrage d'Apache..."

# Démarrer Apache en foreground
apache2ctl -D FOREGROUND
