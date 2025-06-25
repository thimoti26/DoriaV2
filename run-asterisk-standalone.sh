#!/bin/bash
echo "🎯 Démarrage Asterisk autonome..."

# Configuration minimale dans /tmp
mkdir -p /tmp/asterisk-config

cat > /tmp/asterisk-config/sip.conf << 'SIP_EOF'
[general]
context=default
udpbindaddr=0.0.0.0:5060
disallow=all
allow=ulaw

[osmo]
type=friend
secret=osmoosmo
host=dynamic
context=default
SIP_EOF

cat > /tmp/asterisk-config/extensions.conf << 'EXT_EOF'
[default]
exten => *43,1,Answer()
exten => *43,n,Echo()
exten => *43,n,Hangup()
EXT_EOF

# Démarrage conteneur simple
docker run -d \
    --name asterisk-standalone \
    --restart unless-stopped \
    -p 5060:5060/udp \
    -p 5038:5038 \
    -v /tmp/asterisk-config:/etc/asterisk:ro \
    ubuntu:20.04 \
    bash -c "apt-get update -qq && apt-get install -y asterisk && asterisk -f"

echo "✅ Asterisk démarré en mode autonome"
echo "📞 Test avec: nc -u localhost 5060"
