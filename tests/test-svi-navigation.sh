#!/bin/bash

# Script de test SVI interactif - Navigation sans audio
# Usage: ./test-svi-navigation.sh

set -euo pipefail

# Couleurs pour l'interface
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly MAGENTA='\033[0;35m'
readonly NC='\033[0m'

# Variables globales
CURRENT_CONTEXT="ivr-language"
CURRENT_LANGUAGE=""
STEP_COUNT=0
NAVIGATION_LOG=()

# Fonctions d'affichage
log_info() { echo -e "${BLUE}ℹ️  ${1}${NC}"; }
log_success() { echo -e "${GREEN}✅ ${1}${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  ${1}${NC}"; }
log_error() { echo -e "${RED}❌ ${1}${NC}"; }
log_step() { echo -e "${CYAN}🔹 ${1}${NC}"; }
log_menu() { echo -e "${MAGENTA}📋 ${1}${NC}"; }

# Fonction pour logger les étapes
add_step() {
    ((STEP_COUNT++))
    NAVIGATION_LOG+=("Étape $STEP_COUNT: $1")
    log_step "Étape $STEP_COUNT: $1"
}

# Fonction pour afficher le menu principal
show_header() {
    clear
    echo -e "${BLUE}╔══════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║        🌐 TEST SVI MULTILINGUE DORIAV2       ║${NC}"
    echo -e "${BLUE}║              Navigation Simulator            ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Contexte actuel: ${CURRENT_CONTEXT}${NC}"
    echo -e "${CYAN}Langue: ${CURRENT_LANGUAGE:-"Non sélectionnée"}${NC}"
    echo -e "${CYAN}Étapes parcourues: ${STEP_COUNT}${NC}"
    echo ""
}

# Fonction pour afficher le menu de sélection de langue
show_language_menu() {
    CURRENT_CONTEXT="ivr-language"
    add_step "Extension 9999 → Sélection de langue"
    
    log_menu "=== SÉLECTION DE LANGUE ==="
    echo "🎵 Audio: \"Pour français, tapez 1. For English, press 2\""
    echo ""
    echo "Options disponibles:"
    echo "  1️⃣  Français"
    echo "  2️⃣  English"
    echo "  ⏱️  Timeout (10s) → Français par défaut"
    echo "  ❌ Touche invalide → Répétition du menu"
    echo ""
}

# Fonction pour afficher le menu français
show_french_menu() {
    CURRENT_CONTEXT="ivr-main"
    CURRENT_LANGUAGE="Français"
    add_step "Menu principal français sélectionné"
    
    log_menu "=== MENU PRINCIPAL FRANÇAIS ==="
    echo "🎵 Audio: \"Bienvenue sur le serveur DoriaV2\""
    echo "🎵 Audio: \"Pour joindre le service commercial, tapez 1...\""
    echo ""
    echo "Options disponibles:"
    echo "  1️⃣  Service Commercial (→ 1001)"
    echo "  2️⃣  Support Technique (→ 1002)"
    echo "  3️⃣  Salle de Conférence (→ conference1)"
    echo "  4️⃣  Répertoire téléphonique"
    echo "  0️⃣  Opérateur (→ 1003)"
    echo "  8️⃣  🌐 Changer de langue"
    echo "  9️⃣  Retour au menu principal"
    echo "  ⏱️  Timeout → Répétition du menu"
    echo "  ❌ Touche invalide → Message d'erreur"
    echo ""
}

# Fonction pour afficher le menu anglais
show_english_menu() {
    CURRENT_CONTEXT="ivr-main-en"
    CURRENT_LANGUAGE="English"
    add_step "English main menu selected"
    
    log_menu "=== ENGLISH MAIN MENU ==="
    echo "🎵 Audio: \"Welcome to DoriaV2 server\""
    echo "🎵 Audio: \"For sales department, press 1...\""
    echo ""
    echo "Available options:"
    echo "  1️⃣  Sales Department (→ 1001)"
    echo "  2️⃣  Technical Support (→ 1002)"
    echo "  3️⃣  Conference Room (→ conference1)"
    echo "  4️⃣  Directory"
    echo "  0️⃣  Operator (→ 1003)"
    echo "  8️⃣  🌐 Change language"
    echo "  9️⃣  Return to main menu"
    echo "  ⏱️  Timeout → Menu repetition"
    echo "  ❌ Invalid key → Error message"
    echo ""
}

# Fonction pour traiter les actions
process_option() {
    local option="$1"
    
    case "$CURRENT_CONTEXT" in
        "ivr-language")
            case "$option" in
                "1")
                    add_step "Option 1 → Français sélectionné"
                    show_header
                    show_french_menu
                    ;;
                "2")
                    add_step "Option 2 → English selected"
                    show_header
                    show_english_menu
                    ;;
                "t")
                    add_step "Timeout → Français par défaut"
                    CURRENT_LANGUAGE="Français (défaut)"
                    show_header
                    show_french_menu
                    ;;
                "i")
                    add_step "Touche invalide → Répétition menu langue"
                    log_warning "🎵 Audio: \"Option invalide. Invalid option\""
                    show_header
                    show_language_menu
                    ;;
                *)
                    process_option "i"
                    ;;
            esac
            ;;
            
        "ivr-main")
            case "$option" in
                "1")
                    add_step "Service Commercial → Transfert vers 1001"
                    log_success "🎵 Audio français: \"Connexion au service commercial\""
                    log_success "📞 Dial(PJSIP/1001,30) → Extension 1001"
                    ;;
                "2")
                    add_step "Support Technique → Transfert vers 1002"
                    log_success "🎵 Audio français: \"Connexion au support technique\""
                    log_success "📞 Dial(PJSIP/1002,30) → Extension 1002"
                    ;;
                "3")
                    add_step "Salle de Conférence → conference1"
                    log_success "🎵 Audio français: \"Accès à la salle de conférence\""
                    log_success "🏛️ ConfBridge(conference1) → Conférence"
                    ;;
                "4")
                    add_step "Répertoire téléphonique"
                    log_success "🎵 Audio français: \"Accès au répertoire\""
                    log_success "📱 Directory(default,from-internal)"
                    ;;
                "0")
                    add_step "Opérateur → Transfert vers 1003"
                    log_success "🎵 Audio français: \"Connexion à l'opérateur\""
                    log_success "📞 Dial(PJSIP/1003,30) → Extension 1003"
                    ;;
                "8")
                    add_step "Changement de langue → Retour sélection"
                    log_success "🎵 Audio français: \"Changement de langue\""
                    show_header
                    show_language_menu
                    ;;
                "9")
                    add_step "Retour menu → Menu principal français"
                    show_header
                    show_french_menu
                    ;;
                "t")
                    add_step "Timeout → Répétition menu français"
                    log_warning "🎵 Audio français: \"Pas de réponse, retour au menu\""
                    show_header
                    show_french_menu
                    ;;
                "i")
                    add_step "Touche invalide → Message d'erreur français"
                    log_warning "🎵 Audio français: \"Touche invalide, veuillez réessayer\""
                    show_header
                    show_french_menu
                    ;;
                *)
                    process_option "i"
                    ;;
            esac
            ;;
            
        "ivr-main-en")
            case "$option" in
                "1")
                    add_step "Sales Department → Transfer to 1001"
                    log_success "🎵 English audio: \"Connecting to sales department\""
                    log_success "📞 Dial(PJSIP/1001,30) → Extension 1001"
                    ;;
                "2")
                    add_step "Technical Support → Transfer to 1002"
                    log_success "🎵 English audio: \"Connecting to technical support\""
                    log_success "📞 Dial(PJSIP/1002,30) → Extension 1002"
                    ;;
                "3")
                    add_step "Conference Room → conference1"
                    log_success "🎵 English audio: \"Accessing conference room\""
                    log_success "🏛️ ConfBridge(conference1) → Conference"
                    ;;
                "4")
                    add_step "Directory"
                    log_success "🎵 English audio: \"Accessing directory\""
                    log_success "📱 Directory(default,from-internal)"
                    ;;
                "0")
                    add_step "Operator → Transfer to 1003"
                    log_success "🎵 English audio: \"Connecting to operator\""
                    log_success "📞 Dial(PJSIP/1003,30) → Extension 1003"
                    ;;
                "8")
                    add_step "Change language → Return to selection"
                    log_success "🎵 English audio: \"Language change\""
                    show_header
                    show_language_menu
                    ;;
                "9")
                    add_step "Return to menu → English main menu"
                    show_header
                    show_english_menu
                    ;;
                "t")
                    add_step "Timeout → English menu repetition"
                    log_warning "🎵 English audio: \"No response, returning to menu\""
                    show_header
                    show_english_menu
                    ;;
                "i")
                    add_step "Invalid key → English error message"
                    log_warning "🎵 English audio: \"Invalid option, please try again\""
                    show_header
                    show_english_menu
                    ;;
                *)
                    process_option "i"
                    ;;
            esac
            ;;
    esac
}

# Fonction pour afficher l'aide
show_help() {
    echo ""
    log_info "COMMANDES SPÉCIALES:"
    echo "  h, help    - Afficher cette aide"
    echo "  r, reset   - Recommencer depuis le début"
    echo "  l, log     - Afficher l'historique de navigation"
    echo "  s, summary - Résumé des contextes disponibles"
    echo "  t          - Simuler un timeout"
    echo "  i          - Simuler une touche invalide"
    echo "  q, quit    - Quitter le test"
    echo ""
}

# Fonction pour afficher le log de navigation
show_navigation_log() {
    echo ""
    log_info "📜 HISTORIQUE DE NAVIGATION:"
    echo "─────────────────────────────"
    for step in "${NAVIGATION_LOG[@]}"; do
        echo "  $step"
    done
    echo ""
}

# Fonction pour afficher le résumé
show_summary() {
    echo ""
    log_info "📊 RÉSUMÉ DES CONTEXTES SVI:"
    echo "─────────────────────────────"
    echo "🌐 [ivr-language]  : Sélection langue (1=FR, 2=EN)"
    echo "🇫🇷 [ivr-main]     : Menu français (1,2,3,4,0,8,9)"
    echo "🇬🇧 [ivr-main-en]  : Menu anglais (1,2,3,4,0,8,9)"
    echo ""
    echo "🎯 FLUX COMPLET:"
    echo "  9999 → ivr-language → ivr-main/ivr-main-en → Actions"
    echo ""
}

# Fonction pour réinitialiser
reset_navigation() {
    CURRENT_CONTEXT="ivr-language"
    CURRENT_LANGUAGE=""
    STEP_COUNT=0
    NAVIGATION_LOG=()
    show_header
    show_language_menu
}

# Fonction principale
main() {
    echo -e "${GREEN}🚀 Démarrage du simulateur SVI DoriaV2${NC}"
    echo ""
    log_info "Ce script simule la navigation dans le SVI multilingue"
    log_info "Tapez 'h' pour l'aide, 'q' pour quitter"
    echo ""
    
    show_header
    show_language_menu
    show_help
    
    while true; do
        echo -n -e "${YELLOW}🎯 Votre choix (ou 'h' pour aide): ${NC}"
        read -r choice
        
        case "$choice" in
            "h"|"help")
                show_help
                ;;
            "r"|"reset")
                reset_navigation
                ;;
            "l"|"log")
                show_navigation_log
                ;;
            "s"|"summary")
                show_summary
                ;;
            "q"|"quit")
                echo ""
                log_success "🎉 Test terminé !"
                show_navigation_log
                echo -e "${BLUE}Merci d'avoir testé le SVI DoriaV2 !${NC}"
                exit 0
                ;;
            "")
                # Entrée vide, ignorer
                ;;
            *)
                echo ""
                process_option "$choice"
                echo ""
                ;;
        esac
    done
}

# Vérification si le script est exécuté directement
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
