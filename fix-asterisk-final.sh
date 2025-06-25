#!/bin/bash

echo "🔧 DIAGNOSTIC ET SOLUTION ASTERISK"
echo "=================================="
echo ""

echo "1. 📊 État actuel du système:"
echo "   - Conteneurs: $(docker ps | wc -l) en cours"
echo "   - Images: $(docker images | wc -l) disponibles"
echo "   - Espace: $(docker system df 2>/dev/null | grep 'Images' || echo 'Non disponible')"

echo ""
echo "2. 🧹 Nettoyage complet..."
docker compose down 2>/dev/null || true
docker rm -f asterisk test-asterisk 2>/dev/null || true

echo ""
echo "3. 🚀 Solution alternative: Asterisk via script dédié"
echo ""

# Créer un script Asterisk autonome
cat > run-asterisk-standalone.sh << 'EOF'
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
EOF

chmod +x run-asterisk-standalone.sh

echo "4. 📱 Alternative: Test client SIP simple"
echo ""
echo "📋 SOLUTIONS DISPONIBLES:"
echo "========================="
echo "A. ./run-asterisk-standalone.sh - Asterisk simple"
echo "B. ./asterisk-ctl.sh start - Docker Compose (si problème résolu)"
echo "C. Manuel: docker run ubuntu + installation Asterisk"
echo ""
echo "📞 CONFIGURATION LINPHONE:"
echo "• Serveur: localhost:5060"
echo "• Extension: osmo"
echo "• Mot de passe: osmoosmo"
echo ""
echo "🎯 PROCHAINE ÉTAPE:"
echo "Lancez: ./run-asterisk-standalone.sh"
