#!/bin/bash

# Script de test final DoriaV2 - Prêt pour Linphone
# Usage: ./test-final.sh

echo "🎉 TEST FINAL DORIAV2 - PRÊT POUR LINPHONE"
echo "=========================================="

# Vérification des prérequis
echo "🔍 Vérification des prérequis..."

# 1. Conteneurs en marche
containers_ok=true
for container in "doriav2-asterisk" "doriav2-mysql" "doriav2-redis" "doriav2-web"; do
    if docker ps --format "table {{.Names}}" | grep -q "^${container}$"; then
        echo "✅ Conteneur $container démarré"
    else
        echo "❌ Conteneur $container non démarré"
        containers_ok=false
    fi
done

if [ "$containers_ok" = false ]; then
    echo ""
    echo "🚀 Démarrage des conteneurs manquants..."
    docker-compose up -d
    sleep 5
fi

# 2. Asterisk répond
echo ""
echo "📞 Test de connectivité Asterisk..."
if docker exec doriav2-asterisk asterisk -rx "core show version" > /dev/null 2>&1; then
    echo "✅ Asterisk répond aux commandes"
else
    echo "❌ Asterisk ne répond pas"
    exit 1
fi

# 3. Extensions configurées
echo ""
echo "📋 Vérification des extensions de test..."
extensions=("100" "*43" "*44" "*45")
for ext in "${extensions[@]}"; do
    if docker exec doriav2-asterisk asterisk -rx "dialplan show ${ext}@from-internal" 2>/dev/null | grep -q "extension"; then
        echo "✅ Extension $ext configurée"
    else
        echo "❌ Extension $ext manquante"
    fi
done

# 4. Endpoints SIP
echo ""
echo "📱 État des endpoints SIP..."
endpoint_info=$(docker exec doriav2-asterisk asterisk -rx "pjsip show endpoints" 2>/dev/null)
echo "$endpoint_info" | grep -E "1001|1002|1003|1004" | while read line; do
    if echo "$line" | grep -q "Not in use\|Unavailable"; then
        echo "📞 $(echo "$line" | awk '{print $2}') - Disponible"
    fi
done

# 5. Contact actuel pour 1001 (s'il y en a un)
echo ""
echo "🔗 Connexions actives pour l'utilisateur 1001..."
contacts=$(docker exec doriav2-asterisk asterisk -rx "pjsip show contacts 1001" 2>/dev/null)
if echo "$contacts" | grep -q "Avail"; then
    echo "🟢 Client SIP déjà connecté :"
    echo "$contacts" | grep "Contact:" | grep -v "dynamic"
else
    echo "🟡 Aucun client SIP connecté actuellement"
fi

# 6. Configuration recommandée pour Linphone
echo ""
echo "📋 CONFIGURATION LINPHONE RECOMMANDÉE"
echo "====================================="
echo ""
echo "Paramètres du compte SIP :"
echo "┌─────────────────────────────────────┐"
echo "│ Serveur SIP    : localhost:5060     │"
echo "│ Utilisateur    : 1001               │"
echo "│ Mot de passe   : linphone1001       │"
echo "│ Domaine        : localhost          │"
echo "│ Transport      : UDP                │"
echo "└─────────────────────────────────────┘"
echo ""
echo "Paramètres audio :"
echo "┌─────────────────────────────────────┐"
echo "│ Codecs prioritaires :               │"
echo "│   1. ulaw (PCMU)                    │"
echo "│   2. alaw (PCMA)                    │"
echo "│   3. GSM (optionnel)                │"
echo "│                                     │"
echo "│ À désactiver :                      │"
echo "│   - G722, G729, Opus, etc.          │"
echo "│                                     │"
echo "│ Echo cancellation : Activée         │"
echo "└─────────────────────────────────────┘"
echo ""

# 7. Plan de test recommandé
echo "🧪 PLAN DE TEST AUDIO RECOMMANDÉ"
echo "================================"
echo ""
echo "Après avoir configuré Linphone, testez dans cet ordre :"
echo ""
echo "1️⃣  Extension 100 - Test de base"
echo "   📞 Composez : 100"
echo "   🎯 Attendu  : Message 'Congratulations'"
echo "   ⏱️  Durée    : ~5 secondes"
echo "   🔍 But      : Vérifier connectivité et audio basique"
echo ""
echo "2️⃣  Extension *45 - Test tonalité"
echo "   📞 Composez : *45"
echo "   🎯 Attendu  : Tonalité 440Hz claire"
echo "   ⏱️  Durée    : 3 secondes"
echo "   🔍 But      : Vérifier génération audio côté serveur"
echo ""
echo "3️⃣  Extension *44 - Test messages multiples"
echo "   📞 Composez : *44"
echo "   🎯 Attendu  : 'Hello World' puis 'Thank you'"
echo "   ⏱️  Durée    : ~10 secondes"
echo "   🔍 But      : Vérifier lecture de fichiers audio"
echo ""
echo "4️⃣  Extension *43 - Test d'écho complet"
echo "   📞 Composez : *43"
echo "   🎯 Attendu  : Instructions puis écho de votre voix"
echo "   ⏱️  Durée    : Jusqu'à raccrocher"
echo "   🔍 But      : Vérifier audio bidirectionnel"
echo ""

# 8. Monitoring en temps réel
echo "🔍 MONITORING PENDANT LES TESTS"
echo "==============================="
echo ""
echo "Ouvrez un second terminal et lancez :"
echo "   ./debug-audio.sh"
echo ""
echo "Cela affichera les logs Asterisk en temps réel pendant vos appels."
echo ""

# 9. Interface web
echo "🌐 INTERFACE WEB DISPONIBLE"
echo "============================"
echo ""
echo "Dashboard : http://localhost:8080"
echo "API REST  : http://localhost:8080/api/sip-users.php"
echo ""

# 10. Diagnostic en cas de problème
echo "🆘 DIAGNOSTIC EN CAS DE PROBLÈME"
echo "================================"
echo ""
echo "❌ Pas d'audio du tout :"
echo "   • Vérifier codecs Linphone (ulaw/alaw uniquement)"
echo "   • Tester d'abord extension 100, puis *45"
echo "   • Vérifier volume audio Linphone et système"
echo ""
echo "❌ Connection refused :"
echo "   • Utiliser l'IP réelle au lieu de localhost"
echo "   • Vérifier que le port 5060 UDP est libre"
echo "   • Redémarrer : docker-compose restart"
echo ""
echo "❌ Audio haché ou coupé :"
echo "   • Problème RTP/NAT - utiliser IP réelle"
echo "   • Vérifier pare-feu ports 10000-10100 UDP"
echo ""

# Affichage final
echo ""
echo "🎯 VOUS ÊTES PRÊT !"
echo "=================="
echo ""
echo "1. Configurez Linphone avec les paramètres ci-dessus"
echo "2. Lancez ./debug-audio.sh dans un autre terminal"
echo "3. Testez les extensions dans l'ordre recommandé"
echo "4. En cas de problème, consultez TROUBLESHOOTING_AUDIO.md"
echo ""
echo "🏆 Bonne chance avec vos tests audio !"

# Afficher IP réelle si disponible
real_ip=$(ifconfig | grep -E '192\.168\.|10\.|172\.' | grep 'inet ' | head -1 | awk '{print $2}')
if [ ! -z "$real_ip" ]; then
    echo ""
    echo "💡 ASTUCE : Si localhost ne marche pas, essayez avec votre IP réelle :"
    echo "    Serveur SIP : ${real_ip}:5060"
fi
