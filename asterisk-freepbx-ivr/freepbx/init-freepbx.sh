#!/bin/bash

# Wait for MySQL to be ready
echo "Waiting for MySQL to be ready..."
while ! mysqladmin ping -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; do
    sleep 1
done
echo "MySQL is ready!"

# Check if FreePBX is already installed
if [ ! -f "/var/www/html/install.php" ]; then
    echo "FreePBX appears to be installed. Starting Apache..."
else
    echo "Setting up FreePBX for first time..."
    
    # Create FreePBX database configuration
    cat > /var/www/html/install_amp_conf.php << EOF
<?php
\$amp_conf['AMPDBHOST'] = '$MYSQL_HOST';
\$amp_conf['AMPDBNAME'] = '$MYSQL_DATABASE';
\$amp_conf['AMPDBUSER'] = '$MYSQL_USER';
\$amp_conf['AMPDBPASS'] = '$MYSQL_PASSWORD';
\$amp_conf['AMPDBENGINE'] = 'mysql';
\$amp_conf['datasource'] = '';
EOF

    # Set proper permissions
    chown www-data:www-data /var/www/html/install_amp_conf.php
fi

# Start Apache in foreground
exec apache2-foreground
