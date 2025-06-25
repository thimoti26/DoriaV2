#!/bin/bash

echo "🚀 Démarrage du conteneur Asterisk simplifié..."

# Nettoyer les anciens conteneurs
echo "🧹 Nettoyage..."
docker rm -f asterisk test-asterisk 2>/dev/null || true

# Créer un conteneur Asterisk minimal
echo "📦 Création du conteneur..."
docker run -d \
    --name asterisk \
    --restart unless-stopped \
    -p 5060:5060/udp \
    -p 5038:5038 \
    -p 10000-10010:10000-10010/udp \
    ubuntu:20.04 \
    bash -c "
    echo 'Installation d'\''Asterisk...' &&
    apt-get update -qq &&
    DEBIAN_FRONTEND=noninteractive apt-get install -y asterisk asterisk-core-sounds-en &&
    echo 'Configuration minimale...' &&
    echo '[general]' > /etc/asterisk/sip.conf &&
    echo 'context=default' >> /etc/asterisk/sip.conf &&
    echo 'udpbindaddr=0.0.0.0:5060' >> /etc/asterisk/sip.conf &&
    echo 'disallow=all' >> /etc/asterisk/sip.conf &&
    echo 'allow=ulaw' >> /etc/asterisk/sip.conf &&
    echo '[osmo]' >> /etc/asterisk/sip.conf &&
    echo 'type=friend' >> /etc/asterisk/sip.conf &&
    echo 'secret=osmoosmo' >> /etc/asterisk/sip.conf &&
    echo 'host=dynamic' >> /etc/asterisk/sip.conf &&
    echo 'context=default' >> /etc/asterisk/sip.conf &&
    echo '[default]' > /etc/asterisk/extensions.conf &&
    echo 'exten => *43,1,Answer()' >> /etc/asterisk/extensions.conf &&
    echo 'exten => *43,n,Echo()' >> /etc/asterisk/extensions.conf &&
    echo 'exten => *43,n,Hangup()' >> /etc/asterisk/extensions.conf &&
    echo 'Démarrage d'\''Asterisk...' &&
    asterisk -f -vvv
    "

echo "⏳ Attente du démarrage..."
sleep 5

# Vérifier l'état
if docker ps | grep -q asterisk; then
    echo "✅ Asterisk démarré avec succès !"
    echo "📞 Port SIP: 5060/UDP"
    echo "🔧 Extension: osmo/osmoosmo"
    echo ""
    echo "📋 Logs Asterisk:"
    docker logs asterisk | tail -5
else
    echo "❌ Échec du démarrage"
    echo "📋 Logs d'erreur:"
    docker logs asterisk 2>&1 | tail -10
fi
