#!/bin/bash

# Script de test pour validation Linphone avec DoriaV2
# Vérifie la configuration et donne des instructions spécifiques

echo "📱 TEST CONFIGURATION LINPHONE - DORIAV2"
echo "========================================"

# Couleurs
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

log_info() { echo -e "${BLUE}${1}${NC}"; }
log_success() { echo -e "${GREEN}✅ ${1}${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  ${1}${NC}"; }
log_error() { echo -e "${RED}❌ ${1}${NC}"; }

# Vérification des prérequis
check_docker_stack() {
    log_info "\n🔍 Vérification de la stack DoriaV2..."
    
    if ! docker compose ps | grep -q "doriav2-asterisk.*Up.*healthy"; then
        log_error "Conteneur Asterisk non disponible"
        echo "   Démarrer avec: docker compose up -d"
        return 1
    fi
    
    log_success "Stack DoriaV2 opérationnelle"
    return 0
}

# Test des comptes SIP configurés
test_sip_accounts() {
    log_info "\n👥 Vérification des comptes SIP..."
    
    # Vérifier si les comptes sont définis dans la config
    local config_file="./asterisk/config/pjsip.conf"
    local accounts_found=0
    local expected_accounts=("1001" "1002" "1003" "1004")
    
    if [[ -f "$config_file" ]]; then
        for account in "${expected_accounts[@]}"; do
            if grep -q "^\[$account\]" "$config_file"; then
                echo "   ✅ Compte $account configuré dans pjsip.conf"
                ((accounts_found++))
            else
                echo "   ❌ Compte $account non trouvé dans pjsip.conf"
            fi
        done
    else
        log_warning "Fichier pjsip.conf non trouvé"
    fi
    
    if [[ $accounts_found -eq 4 ]]; then
        log_success "Tous les comptes SIP sont configurés (${accounts_found}/4)"
    else
        log_warning "Seulement ${accounts_found}/4 comptes trouvés"
    fi
    
    # Test de connectivité PJSIP
    echo "   🔍 Test connectivité PJSIP..."
    if docker exec doriav2-asterisk asterisk -rx "pjsip show endpoints" 2>/dev/null | grep -q "Endpoint"; then
        echo "   ✅ Module PJSIP chargé et fonctionnel"
    else
        echo "   ⚠️  Module PJSIP peut nécessiter un rechargement"
    fi
}

# Test des extensions audio
test_audio_extensions() {
    log_info "\n🎵 Vérification des extensions de test audio..."
    
    # Vérifier si les extensions sont définies dans extensions.conf
    local config_file="./asterisk/config/extensions.conf"
    local extensions_found=0
    local test_extensions=("100" "\\*43" "\\*44" "\\*45")
    local display_extensions=("100" "*43" "*44" "*45")
    
    if [[ -f "$config_file" ]]; then
        for i in "${!display_extensions[@]}"; do
            local display_ext="${display_extensions[$i]}"
            
            # Recherche spécifique selon l'extension
            case "$display_ext" in
                "100")
                    if grep -q "exten.*=>.*100" "$config_file"; then
                        echo "   ✅ Extension $display_ext configurée dans extensions.conf"
                        ((extensions_found++))
                    else
                        echo "   ❌ Extension $display_ext non trouvée dans extensions.conf"
                    fi
                    ;;
                "*43"|"*44"|"*45")
                    if grep -q "exten.*=>.*\\$display_ext" "$config_file"; then
                        echo "   ✅ Extension $display_ext configurée dans extensions.conf"
                        ((extensions_found++))
                    else
                        echo "   ❌ Extension $display_ext non trouvée dans extensions.conf"
                    fi
                    ;;
            esac
        done
    else
        log_warning "Fichier extensions.conf non trouvé"
    fi
    
    if [[ $extensions_found -eq 4 ]]; then
        log_success "Extensions de test configurées (${extensions_found}/4)"
    else
        log_warning "Seulement ${extensions_found}/4 extensions trouvées"
    fi
    
    # Test du dialplan chargé
    echo "   🔍 Test dialplan chargé..."
    if docker exec doriav2-asterisk asterisk -rx "dialplan show from-internal" 2>/dev/null | grep -q "from-internal"; then
        echo "   ✅ Contexte from-internal chargé"
    else
        echo "   ⚠️  Contexte from-internal peut nécessiter un rechargement"
    fi
}

# Afficher les informations de connexion
show_connection_info() {
    log_info "\n📋 INFORMATIONS DE CONFIGURATION LINPHONE"
    echo "========================================="
    echo ""
    echo "🔧 Configuration de base :"
    echo "   Nom d'utilisateur : 1001"
    echo "   Mot de passe     : linphone1001"
    echo "   Domaine          : localhost"
    echo "   Proxy SIP        : sip:localhost:5060"
    echo "   Transport        : UDP"
    echo ""
    echo "🎵 Codecs recommandés :"
    echo "   1. PCMU (ulaw)   - Priorité 1"
    echo "   2. PCMA (alaw)   - Priorité 2"
    echo "   3. Désactiver    - G722, G729, Opus"
    echo ""
    echo "📱 Comptes disponibles :"
    echo "   1001 / linphone1001"
    echo "   1002 / linphone1002"  
    echo "   1003 / linphone1003"
    echo "   1004 / linphone1004"
    echo ""
}

# Tests de connectivité recommandés
show_test_sequence() {
    log_info "\n🧪 SÉQUENCE DE TESTS RECOMMANDÉE"
    echo "================================"
    echo ""
    echo "1️⃣  Test de base (Extension 100)"
    echo "   📞 Composer : 100"
    echo "   🎵 Attendu  : Message Asterisk (~5 sec)"
    echo "   🎯 But     : Vérifier connectivité"
    echo ""
    echo "2️⃣  Test tonalité (Extension *45)"
    echo "   📞 Composer : *45"
    echo "   🎵 Attendu  : Tonalité 440Hz (3 sec)"
    echo "   🎯 But     : Vérifier génération audio"
    echo ""
    echo "3️⃣  Test messages (Extension *44)"
    echo "   📞 Composer : *44"
    echo "   🎵 Attendu  : 'Hello World' + 'Thank you'"
    echo "   🎯 But     : Vérifier lecture fichiers"
    echo ""
    echo "4️⃣  Test écho (Extension *43)"
    echo "   📞 Composer : *43"
    echo "   🎵 Attendu  : Écho de votre voix"
    echo "   🎯 But     : Vérifier audio bidirectionnel"
    echo ""
    echo "5️⃣  Test inter-utilisateurs"
    echo "   📞 Composer : 1002 (depuis 1001)"
    echo "   🎵 Attendu  : Sonnerie puis décroché"
    echo "   🎯 But     : Vérifier appels utilisateurs"
    echo ""
}

# Diagnostics en cas de problème
show_troubleshooting() {
    log_info "\n🚨 DIAGNOSTIC EN CAS DE PROBLÈME"
    echo "================================"
    echo ""
    echo "❌ Problème : 'Non enregistré'"
    echo "   Solution  : Vérifier l'IP du serveur"
    echo "   Commande  : ip addr show | grep inet"
    echo "   Note      : Utiliser IP réelle au lieu de localhost"
    echo ""
    echo "❌ Problème : 'Pas d'audio'"
    echo "   Solution  : Vérifier les codecs"
    echo "   Test      : Extension *45 (tonalité simple)"
    echo "   Config    : Activer uniquement ulaw/alaw"
    echo ""
    echo "❌ Problème : 'Audio coupé'"
    echo "   Solution  : Configuration RTP"
    echo "   Ports     : UDP 10000-10100"
    echo "   NAT       : Activer 'RTP symmetric'"
    echo ""
    echo "🔍 Monitoring en temps réel :"
    echo "   ./debug-audio.sh"
    echo ""
    echo "🧪 Test complet de la stack :"
    echo "   ./test-stack.sh"
    echo ""
}

# Fonction principale
main() {
    echo ""
    
    # Tests techniques
    if ! check_docker_stack; then
        exit 1
    fi
    
    test_sip_accounts
    test_audio_extensions
    
    # Informations utilisateur
    show_connection_info
    show_test_sequence
    show_troubleshooting
    
    echo ""
    log_success "🎉 Configuration prête pour Linphone !"
    echo ""
    log_info "📖 Guide détaillé : TUTORIEL_LINPHONE.md"
    log_info "🌐 Interface web  : http://localhost:8080"
    echo ""
}

# Point d'entrée
main "$@"
