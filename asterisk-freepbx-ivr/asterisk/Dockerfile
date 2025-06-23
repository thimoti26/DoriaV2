FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y \
    wget \
    build-essential \
    git \
    subversion \
    libxml2-dev \
    libncurses5-dev \
    libsqlite3-dev \
    libssl-dev \
    libjansson-dev \
    libedit-dev \
    libcurl4-openssl-dev \
    libnewt-dev \
    libogg-dev \
    libvorbis-dev \
    libspandsp-dev \
    libiksemel-dev \
    libsqlite3-dev \
    uuid-dev \
    libspeex-dev \
    libspeexdsp-dev \
    && apt-get clean

# Create asterisk user
RUN groupadd -r asterisk && useradd -r -g asterisk asterisk

WORKDIR /usr/src

RUN wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-18-current.tar.gz && \
    tar -xzf asterisk-18-current.tar.gz && \
    rm asterisk-18-current.tar.gz

# Debug: Check what directories were created
RUN ls -la /usr/src/

# Find the actual asterisk directory
RUN find /usr/src -name "asterisk*" -type d

# Get the actual directory name and work with it
RUN ASTERISK_DIR=$(find /usr/src -name "asterisk*" -type d | head -1) && \
    echo "Working with directory: $ASTERISK_DIR" && \
    cd "$ASTERISK_DIR" && \
    ls -la && \
    ./configure --with-pjproject-bundled && \
    make menuselect.makeopts && \
    menuselect/menuselect --disable BUILD_NATIVE && \
    make && \
    make install && \
    make config && \
    ldconfig

WORKDIR /

RUN rm -rf /usr/src/asterisk-18*

# Set proper ownership
RUN chown -R asterisk:asterisk /var/lib/asterisk && \
    chown -R asterisk:asterisk /var/log/asterisk && \
    chown -R asterisk:asterisk /var/spool/asterisk && \
    chown -R asterisk:asterisk /etc/asterisk

COPY config/ /etc/asterisk/
COPY sounds/ /var/lib/asterisk/sounds/

# Fix permissions again after copy
RUN chown -R asterisk:asterisk /etc/asterisk && \
    chown -R asterisk:asterisk /var/lib/asterisk/sounds

EXPOSE 5060/udp
EXPOSE 5060/tcp  
EXPOSE 10000-20000/udp

USER asterisk

CMD ["asterisk", "-f", "-vvv"]