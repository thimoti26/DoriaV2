FROM ubuntu:22.04

# Éviter les prompts interactifs
ENV DEBIAN_FRONTEND=noninteractive

# Installation des dépendances
RUN apt-get update && apt-get install -y \
    wget \
    build-essential \
    libssl-dev \
    libncurses5-dev \
    libnewt-dev \
    libxml2-dev \
    linux-headers-generic \
    libsqlite3-dev \
    uuid-dev \
    libjansson-dev \
    libedit-dev \
    sox \
    mpg123 \
    mysql-client \
    unixodbc \
    unixodbc-dev \
    odbcinst \
    subversion \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Install MySQL ODBC Connector using Ubuntu repositories (compatible with current OpenSSL)
RUN apt-get update && apt-get install -y \
    libodbc1 \
    odbcinst1debian2 \
    odbc-mariadb \
    && rm -rf /var/lib/apt/lists/*

# Télécharger et installer Asterisk
WORKDIR /usr/src
RUN wget https://downloads.asterisk.org/pub/telephony/asterisk/asterisk-20-current.tar.gz && \
    tar -xzf asterisk-20-current.tar.gz && \
    rm asterisk-20-current.tar.gz && \
    ASTERISK_DIR=$(ls -1d asterisk-20*/ | head -1 | sed 's|/$||') && \
    echo "Found Asterisk directory: $ASTERISK_DIR" && \
    cd "$ASTERISK_DIR" && \
    contrib/scripts/get_mp3_source.sh && \
    ./configure --with-jansson-bundled && \
    make menuselect.makeopts && \
    menuselect/menuselect --disable BUILD_NATIVE . && \
    make && \
    make install && \
    make samples && \
    make config && \
    ldconfig

# Créer l'utilisateur asterisk et les répertoires nécessaires
RUN useradd -m asterisk && \
    mkdir -p /var/run/asterisk /var/log/asterisk /var/spool/asterisk && \
    chown -R asterisk:asterisk /etc/asterisk /var/lib/asterisk /var/log/asterisk /var/spool/asterisk /var/run/asterisk /usr/lib/asterisk

# Configuration de base (après make samples pour éviter l'écrasement)
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
