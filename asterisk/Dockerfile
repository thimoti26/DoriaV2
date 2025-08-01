FROM asterisk/asterisk:20.11.2

# Installer les dépendances pour MySQL
USER root
RUN apt-get update && apt-get install -y \
    libodbc1 \
    odbcinst1debian2 \
    odbc-mariadb \
    mysql-client \
    && rm -rf /var/lib/apt/lists/*

# Configuration de base
COPY config/ /etc/asterisk/
COPY config/odbc.ini /etc/odbc.ini

# Copy custom sound files for IVR
COPY sounds/ /var/lib/asterisk/sounds/

# S'assurer que les permissions sont correctes après la copie
RUN chown -R asterisk:asterisk /etc/asterisk && \
    chown -R asterisk:asterisk /var/lib/asterisk/sounds

# Configuration ODBC (utiliser le driver MariaDB compatible)
RUN echo "[MariaDB]" > /etc/odbcinst.ini && \
    echo "Description = MariaDB ODBC 3.1 Driver" >> /etc/odbcinst.ini && \
    echo "Driver = /usr/lib/aarch64-linux-gnu/odbc/libmaodbc.so" >> /etc/odbcinst.ini && \
    echo "FileUsage = 1" >> /etc/odbcinst.ini

EXPOSE 5060/udp 5060/tcp 5038 10000-10100/udp

USER asterisk
CMD ["/usr/sbin/asterisk", "-f", "-U", "asterisk", "-G", "asterisk"]
