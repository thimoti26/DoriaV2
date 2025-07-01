#!/bin/bash

# Script de diagnostic audio en temps réel pour DoriaV2
# Monitore les logs Asterisk pendant les tests audio

echo "======================================"
echo "🎵 DIAGNOSTIC AUDIO TEMPS RÉEL"
echo "======================================"

echo ""
echo "📋 État des services:"
echo "- Extensions configurées: *43, *44, *45, 100"
echo "- Endpoint 1001: $(docker exec doriav2-asterisk asterisk -rx 'pjsip show endpoint 1001' | grep 'Not in use\|Unavailable')"

echo ""
echo "🔊 Tests audio recommandés dans cet ordre:"
echo "1. Extension 100  : Message de félicitations simple"
echo "2. Extension *45  : Tonalité 440Hz (3 secondes)"
echo "3. Extension *44  : Hello world + Thank you"
echo "4. Extension *43  : Test d'écho complet"

echo ""
echo "📡 Configuration Linphone recommandée:"
echo "- Utilisateur: 1001"
echo "- Mot de passe: linphone1001"
echo "- Serveur: localhost:5060"
echo "- Codecs: ulaw (priorité 1), alaw (priorité 2)"

echo ""
echo "🔍 Monitoring des logs Asterisk en cours..."
echo "Appelez maintenant une extension pour voir les logs:"
echo ""

# Monitoring en temps réel des logs
docker exec doriav2-asterisk tail -f /var/log/asterisk/messages.log | while read line; do
    # Filtrer les lignes importantes
    if echo "$line" | grep -E "(PJSIP|Playback|Echo|Answer|Hangup|from-internal)" > /dev/null; then
        timestamp=$(echo "$line" | cut -d' ' -f1-3)
        message=$(echo "$line" | cut -d']' -f2-)
        echo "🔔 $timestamp →$message"
    fi
done
