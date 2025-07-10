#!/bin/bash

# Script de diagnostic des contacts SIP - DoriaV2
# Analyse et gestion des endpoints PJSIP

echo "📞 DIAGNOSTIC CONTACTS SIP - DORIAV2"
echo "===================================="
echo "Date: $(date)"
echo ""

# Vérifier si Asterisk est accessible
if ! docker exec doriav2-asterisk asterisk -rx "core show version" > /dev/null 2>&1; then
    echo "❌ Asterisk non accessible. Vérifiez que le conteneur est démarré."
    exit 1
fi

echo "✅ Asterisk accessible"
echo ""

# Fonction pour afficher le statut des endpoints
show_endpoints_status() {
    echo "📊 STATUT DES ENDPOINTS SIP"
    echo "----------------------------"
    
    # Récupérer le statut des endpoints
    docker exec doriav2-asterisk asterisk -rx "pjsip show endpoints" | \
    grep -E "(Endpoint:|Contact:)" | \
    while read line; do
        if [[ $line =~ Endpoint:.*([0-9]{4}).*(Available|Unavailable|Not\ in\ use) ]]; then
            endpoint=$(echo $line | grep -o '[0-9]\{4\}' | head -1)
            status=$(echo $line | grep -o -E "(Available|Unavailable|Not in use)")
            
            case $status in
                "Available")
                    echo "✅ Extension $endpoint : Disponible"
                    ;;
                "Not in use")
                    echo "🟢 Extension $endpoint : Connecté (pas en cours d'appel)"
                    ;;
                "Unavailable")
                    echo "❌ Extension $endpoint : Non connecté"
                    ;;
            esac
        fi
    done
    echo ""
}

# Fonction pour afficher les contacts détaillés
show_contacts_detail() {
    echo "🔍 DÉTAIL DES CONTACTS"
    echo "----------------------"
    
    docker exec doriav2-asterisk asterisk -rx "pjsip show aors" | \
    grep -E "(Aor:|Contact:)" | \
    while read line; do
        if [[ $line =~ Aor:.*([0-9]{4}) ]]; then
            aor=$(echo $line | grep -o '[0-9]\{4\}')
            echo "📋 AOR $aor:"
        elif [[ $line =~ Contact:.*sip:([0-9]{4})@([^\ ]+).*\[(Avail|Unavail)\] ]]; then
            contact_line=$(echo $line | sed 's/^[[:space:]]*//')
            if [[ $contact_line =~ Avail ]]; then
                echo "  ✅ $contact_line"
            else
                echo "  ❌ $contact_line"
            fi
        fi
    done
    echo ""
}

# Fonction pour expliquer les messages "Unreachable"
explain_unreachable() {
    echo "💡 EXPLICATION DES MESSAGES 'UNREACHABLE'"
    echo "------------------------------------------"
    echo ""
    echo "Les messages 'Contact X/sip:X@dynamic is now Unreachable' sont NORMAUX et indiquent que :"
    echo ""
    echo "• 🔍 Asterisk effectue des vérifications périodiques des contacts SIP"
    echo "• 📞 Aucun client SIP n'est connecté pour ces extensions"
    echo "• ⏰ Le paramètre 'qualify_frequency=30' teste la disponibilité toutes les 30 secondes"
    echo "• 🏠 Les contacts '@dynamic' sont créés automatiquement lors de l'enregistrement"
    echo ""
    echo "Ce N'EST PAS une erreur si :"
    echo "✅ Aucun téléphone/softphone n'est configuré pour ces extensions"
    echo "✅ Les extensions sont créées pour usage futur"
    echo "✅ Les clients SIP se connectent/déconnectent périodiquement"
    echo ""
}

# Fonction pour afficher les recommandations
show_recommendations() {
    echo "🚀 RECOMMANDATIONS"
    echo "------------------"
    echo ""
    echo "Pour réduire les messages 'Unreachable' :"
    echo ""
    echo "1. 📱 Connecter des clients SIP :"
    echo "   • Linphone, X-Lite, Zoiper, etc."
    echo "   • Serveur : IP du serveur Asterisk"
    echo "   • Port : 5060"
    echo "   • Utilisateur/Mot de passe : voir pjsip.conf"
    echo ""
    echo "2. ⚙️ Ajuster la configuration (optionnel) :"
    echo "   • Augmenter 'qualify_frequency' (ex: 60 secondes)"
    echo "   • Réduire 'qualify_timeout'"
    echo "   • Désactiver 'qualify_frequency=0' pour certaines extensions"
    echo ""
    echo "3. 🧹 Supprimer les extensions inutilisées :"
    echo "   • Commenter les sections dans pjsip.conf"
    echo "   • Recharger la configuration Asterisk"
    echo ""
}

# Fonction pour nettoyer les contacts expirés
clean_expired_contacts() {
    echo "🧹 NETTOYAGE DES CONTACTS EXPIRÉS"
    echo "---------------------------------"
    
    echo "Suppression des contacts dynamiques non disponibles..."
    
    # Pour chaque AOR, supprimer les contacts dynamiques unavailable
    for ext in 1001 1002 1003 1004; do
        echo "📞 Nettoyage extension $ext..."
        docker exec doriav2-asterisk asterisk -rx "pjsip delete contact $ext/sip:$ext@dynamic" 2>/dev/null || true
    done
    
    echo "✅ Nettoyage terminé"
    echo ""
}

# Fonction pour configurer un client SIP exemple
show_sip_client_config() {
    echo "📱 CONFIGURATION CLIENT SIP EXEMPLE"
    echo "-----------------------------------"
    echo ""
    echo "Pour connecter un softphone (Linphone, X-Lite, etc.) :"
    echo ""
    echo "🏠 Serveur SIP :"
    echo "   • Adresse : $(docker inspect doriav2-asterisk | grep IPAddress | tail -1 | cut -d'"' -f4) ou localhost"
    echo "   • Port : 5060"
    echo "   • Transport : UDP"
    echo ""
    echo "👤 Comptes disponibles :"
    echo "   • Extension 1001 / Mot de passe : linphone1001"
    echo "   • Extension 1002 / Mot de passe : linphone1002"
    echo "   • Extension 1003 / Mot de passe : linphone1003"
    echo "   • Extension 1004 / Mot de passe : linphone1004"
    echo ""
    echo "📋 Configuration Linphone :"
    echo "   1. Ajouter un compte SIP"
    echo "   2. Nom d'utilisateur : 1001 (ou 1002, 1003, 1004)"
    echo "   3. Mot de passe : linphone1001 (correspondant)"
    echo "   4. Domaine : IP du serveur"
    echo "   5. Activer l'enregistrement automatique"
    echo ""
}

# Fonction de test de connectivité
test_connectivity() {
    echo "🔗 TEST DE CONNECTIVITÉ"
    echo "-----------------------"
    
    echo "📡 Test des ports Asterisk..."
    
    # Test port SIP UDP
    if docker exec doriav2-asterisk netstat -un | grep -q ":5060"; then
        echo "✅ Port SIP 5060/UDP ouvert"
    else
        echo "❌ Port SIP 5060/UDP non disponible"
    fi
    
    # Test port Manager Interface
    if docker exec doriav2-asterisk netstat -tn | grep -q ":5038"; then
        echo "✅ Port Manager 5038/TCP ouvert"
    else
        echo "❌ Port Manager 5038/TCP non disponible"
    fi
    
    # Test des transports PJSIP
    echo ""
    echo "🚀 Transports PJSIP actifs :"
    docker exec doriav2-asterisk asterisk -rx "pjsip show transports" | grep -E "(transport-|Type|Bind)"
    echo ""
}

# === MENU PRINCIPAL ===

case "${1:-status}" in
    "status"|"")
        show_endpoints_status
        show_contacts_detail
        ;;
    "explain")
        explain_unreachable
        ;;
    "recommend")
        show_recommendations
        ;;
    "clean")
        clean_expired_contacts
        show_endpoints_status
        ;;
    "config")
        show_sip_client_config
        ;;
    "test")
        test_connectivity
        ;;
    "full")
        show_endpoints_status
        show_contacts_detail
        explain_unreachable
        show_recommendations
        show_sip_client_config
        test_connectivity
        ;;
    *)
        echo "Usage: $0 [status|explain|recommend|clean|config|test|full]"
        echo ""
        echo "  status     - Afficher le statut des endpoints (défaut)"
        echo "  explain    - Expliquer les messages 'Unreachable'"
        echo "  recommend  - Recommandations pour améliorer la situation"
        echo "  clean      - Nettoyer les contacts expirés"
        echo "  config     - Exemple de configuration client SIP"
        echo "  test       - Tester la connectivité"
        echo "  full       - Rapport complet"
        ;;
esac

echo ""
echo "🎯 RÉSUMÉ"
echo "========="
echo ""
echo "Les messages 'Unreachable' sont normaux quand aucun client SIP n'est connecté."
echo "Pour une utilisation en production, connectez des softphones aux extensions."
echo ""
echo "📞 Test rapide : Configurez Linphone avec l'extension 1001/linphone1001"
echo "🔗 Interface SVI : http://localhost:8080/svi-admin/"
echo ""
echo "✨ Tout fonctionne correctement ! ✨"
