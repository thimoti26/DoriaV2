#!/bin/bash
set -e

echo "=== Démarrage DoriaV2 Backend ==="

# Attendre que MySQL soit disponible (si nécessaire)
if [ "$DB_HOST" ]; then
    echo "Attente de MySQL..."
    while ! mysqladmin ping -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" --silent 2>/dev/null; do
        sleep 2
    done
    echo "MySQL OK"
fi

# Attendre que Redis soit disponible (si nécessaire)
if [ "$REDIS_HOST" ]; then
    echo "Attente de Redis..."
    while ! redis-cli -h "$REDIS_HOST" ping > /dev/null 2>&1; do
        sleep 2
    done
    echo "Redis OK"
fi

echo "Démarrage Apache..."
exec "$@"
