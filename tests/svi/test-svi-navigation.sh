#!/bin/bash

# Script de test SVI interactif - Navigation sans audio
# Usage: ./test-svi-navigation.sh
# Ce script lit le fichier extensions.conf pour extraire la logique SVI

set -euo pipefail

# Configuration des chemins
readonly EXTENSIONS_CONF="/Users/thibaut/workspace/DoriaV2/asterisk/config/extensions.conf"

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

# Fonction pour vérifier l'existence du fichier extensions.conf
check_extensions_conf() {
    if [[ ! -f "$EXTENSIONS_CONF" ]]; then
        log_error "Fichier extensions.conf non trouvé: $EXTENSIONS_CONF"
        log_info "Assurez-vous que le chemin est correct ou que le conteneur Asterisk est démarré"
        exit 1
    fi
    log_success "Fichier extensions.conf trouvé: $EXTENSIONS_CONF"
}

# Fonction pour extraire les options d'un contexte depuis extensions.conf
get_context_options() {
    local context="$1"
    local in_context=false
    local options=()
    
    while IFS= read -r line; do
        # Supprimer les espaces
        line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        
        # Ignorer les lignes vides et commentaires
        [[ -z "$line" || "$line" == \;* ]] && continue
        
        # Détecter les contextes
        if [[ "$line" == "[$context]" ]]; then
            in_context=true
            continue
        elif [[ "$line" =~ ^\[.*\]$ ]] && [[ "$in_context" == true ]]; then
            break
        fi
        
        # Extraire les extensions si on est dans le bon contexte
        if [[ "$in_context" == true ]] && [[ "$line" == *"exten =>"* ]]; then
            local exten=$(echo "$line" | cut -d',' -f1 | sed 's/.*=> *//')
            local priority=$(echo "$line" | cut -d',' -f2)
            
            # Ne garder que les extensions avec priorité 1
            if [[ "$priority" == "1" ]] && [[ ! "$exten" =~ ^(s|i|t|h)$ ]]; then
                options+=("$exten")
            fi
        fi
    done < "$EXTENSIONS_CONF"
    
    # Trier et afficher les options
    printf '%s\n' "${options[@]}" | sort -V | tr '\n' ' '
}

# Fonction pour obtenir la description d'une action
get_action_description() {
    local context="$1"
    local option="$2"
    local in_context=false
    
    while IFS= read -r line; do
        # Supprimer les espaces
        line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        
        # Ignorer les lignes vides et commentaires
        [[ -z "$line" || "$line" == \;* ]] && continue
        
        # Détecter les contextes
        if [[ "$line" == "[$context]" ]]; then
            in_context=true
            continue
        elif [[ "$line" =~ ^\[.*\]$ ]] && [[ "$in_context" == true ]]; then
            break
        fi
        
        # Chercher l'extension spécifique
        if [[ "$in_context" == true ]] && [[ "$line" == *"exten => $option,1,"* ]]; then
            local action=$(echo "$line" | cut -d',' -f3-)
            
            # Analyser l'action pour donner une description
            if [[ "$action" == *"Dial(PJSIP/"* ]]; then
                local ext=$(echo "$action" | sed 's/.*Dial(PJSIP\/\([0-9]*\).*/\1/')
                echo "Transfert vers extension $ext"
            elif [[ "$action" == *"ConfBridge("* ]]; then
                local conf=$(echo "$action" | sed 's/.*ConfBridge(\([^)]*\)).*/\1/')
                echo "Accès à la salle de conférence $conf"
            elif [[ "$action" == *"Goto("* ]]; then
                local ctx=$(echo "$action" | sed 's/.*Goto(\([^,]*\),.*/\1/')
                echo "Redirection vers contexte $ctx"
            elif [[ "$action" == *"Directory"* ]]; then
                echo "Accès au répertoire téléphonique"
            elif [[ "$action" == *"Background"* ]]; then
                echo "Message audio"
            else
                echo "$action"
            fi
            return 0
        fi
    done < "$EXTENSIONS_CONF"
    
    echo "Action non trouvée"
}

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
    
    echo "Options disponibles (extraites d'extensions.conf):"
    local options=$(get_context_options "ivr-language")
    
    for option in $options; do
        local description=$(get_action_description "ivr-language" "$option")
        case "$option" in
            "1") echo "  1️⃣  Français → $description" ;;
            "2") echo "  2️⃣  English → $description" ;;
            *) echo "  ${option}️⃣  Option $option → $description" ;;
        esac
    done
    
    echo "  ⏱️  Timeout (t) → $(get_action_description "ivr-language" "t")"
    echo "  ❌ Touche invalide (i) → $(get_action_description "ivr-language" "i")"
    echo ""
}

# Fonction pour afficher le menu français
show_french_menu() {
    CURRENT_CONTEXT="ivr-main"
    CURRENT_LANGUAGE="Français"
    add_step "Menu principal français sélectionné"
    
    log_menu "=== MENU PRINCIPAL FRANÇAIS ==="
    echo "🎵 Audio: \"Bienvenue sur le serveur DoriaV2\""
    echo ""
    
    echo "Options disponibles (extraites d'extensions.conf):"
    local options=$(get_context_options "ivr-main")
    
    for option in $options; do
        local description=$(get_action_description "ivr-main" "$option")
        
        case "$option" in
            "1") echo "  1️⃣  Service Commercial → $description" ;;
            "2") echo "  2️⃣  Support Technique → $description" ;;
            "3") echo "  3️⃣  Salle de Conférence → $description" ;;
            "4") echo "  4️⃣  Répertoire → $description" ;;
            "0") echo "  0️⃣  Opérateur → $description" ;;
            "8") echo "  8️⃣  🌐 Changer de langue → $description" ;;
            "9") echo "  9️⃣  Retour au menu → $description" ;;
            *) echo "  ${option}️⃣  Option $option → $description" ;;
        esac
    done
    
    echo "  ⏱️  Timeout (t) → $(get_action_description "ivr-main" "t")"
    echo "  ❌ Touche invalide (i) → $(get_action_description "ivr-main" "i")"
    echo ""
}

# Fonction pour afficher le menu anglais
show_english_menu() {
    CURRENT_CONTEXT="ivr-main-en"
    CURRENT_LANGUAGE="English"
    add_step "English main menu selected"
    
    log_menu "=== ENGLISH MAIN MENU ==="
    echo "🎵 Audio: \"Welcome to DoriaV2 server\""
    echo ""
    
    echo "Available options (extracted from extensions.conf):"
    local options=$(get_context_options "ivr-main-en")
    
    for option in $options; do
        local description=$(get_action_description "ivr-main-en" "$option")
        
        case "$option" in
            "1") echo "  1️⃣  Sales Department → $description" ;;
            "2") echo "  2️⃣  Technical Support → $description" ;;
            "3") echo "  3️⃣  Conference Room → $description" ;;
            "4") echo "  4️⃣  Directory → $description" ;;
            "0") echo "  0️⃣  Operator → $description" ;;
            "8") echo "  8️⃣  🌐 Change language → $description" ;;
            "9") echo "  9️⃣  Return to menu → $description" ;;
            *) echo "  ${option}️⃣  Option $option → $description" ;;
        esac
    done
    
    echo "  ⏱️  Timeout (t) → $(get_action_description "ivr-main-en" "t")"
    echo "  ❌ Invalid key (i) → $(get_action_description "ivr-main-en" "i")"
    echo ""
}

# Fonction pour traiter les actions
process_option() {
    local option="$1"
    local description=$(get_action_description "$CURRENT_CONTEXT" "$option")
    
    if [[ "$description" != "Action non trouvée" ]]; then
        add_step "Option $option → $description"
        
        # Analyser la description pour déterminer le comportement
        if [[ "$description" == "Redirection vers contexte"* ]]; then
            local target_context=$(echo "$description" | sed 's/.*contexte //')
            
            log_success "🎯 Redirection vers [$target_context]"
            
            # Changer de contexte selon la redirection
            case "$target_context" in
                "ivr-language")
                    show_header
                    show_language_menu
                    ;;
                "ivr-main")
                    CURRENT_CONTEXT="ivr-main"
                    CURRENT_LANGUAGE="Français"
                    show_header
                    show_french_menu
                    ;;
                "ivr-main-en")
                    CURRENT_CONTEXT="ivr-main-en"
                    CURRENT_LANGUAGE="English"
                    show_header
                    show_english_menu
                    ;;
                *)
                    log_info "🎯 Redirection vers contexte: $target_context"
                    ;;
            esac
            
        elif [[ "$description" == "Transfert vers extension"* ]]; then
            local extension=$(echo "$description" | sed 's/.*extension //')
            log_success "📞 Appel vers extension PJSIP/$extension"
            log_info "📧 Si pas de réponse → Voicemail($extension@default)"
            log_info "📴 Fin d'appel → Hangup()"
            
        elif [[ "$description" == "Accès à la salle de conférence"* ]]; then
            local conference=$(echo "$description" | sed 's/.*conférence //')
            log_success "🏛️ Entrée en salle de conférence: $conference"
            log_info "📴 Sortie de conférence → Hangup()"
            
        elif [[ "$description" == "Accès au répertoire téléphonique" ]]; then
            log_success "📱 Accès au répertoire téléphonique"
            log_info "📴 Fin de consultation → Hangup()"
            
        elif [[ "$description" == "Message audio" ]]; then
            log_success "🎵 Lecture audio"
            
            # Si c'est un retour au menu, on le simule
            if [[ "$CURRENT_CONTEXT" == "ivr-main" ]]; then
                show_header
                show_french_menu
            elif [[ "$CURRENT_CONTEXT" == "ivr-main-en" ]]; then
                show_header
                show_english_menu
            fi
            
        else
            log_info "⚙️ Action: $description"
        fi
        
    else
        # Gérer les cas spéciaux (timeout, invalid)
        case "$option" in
            "t")
                add_step "Timeout → Comportement par défaut"
                log_warning "⏱️ Timeout - retour au menu"
                case "$CURRENT_CONTEXT" in
                    "ivr-language") show_language_menu ;;
                    "ivr-main") show_french_menu ;;
                    "ivr-main-en") show_english_menu ;;
                esac
                ;;
            "i")
                add_step "Touche invalide → Comportement par défaut"
                log_warning "❌ Touche invalide - retour au menu"
                case "$CURRENT_CONTEXT" in
                    "ivr-language") show_language_menu ;;
                    "ivr-main") show_french_menu ;;
                    "ivr-main-en") show_english_menu ;;
                esac
                ;;
            *)
                add_step "Option inconnue: $option"
                log_error "❌ Option '$option' non trouvée dans extensions.conf"
                local available_options=$(get_context_options "$CURRENT_CONTEXT")
                log_info "Options disponibles: $available_options"
                ;;
        esac
    fi
}

# Fonction pour afficher l'aide
show_help() {
    echo ""
    log_info "COMMANDES SPÉCIALES:"
    echo "  h, help       - Afficher cette aide"
    echo "  r, reset      - Recommencer depuis le début"
    echo "  l, log        - Afficher l'historique de navigation"
    echo "  s, summary    - Résumé des contextes (depuis extensions.conf)"
    echo "  v, validate   - Valider la configuration SVI"
    echo "  t             - Simuler un timeout"
    echo "  i             - Simuler une touche invalide"
    echo "  q, quit       - Quitter le test"
    echo ""
    log_info "📁 Source: $EXTENSIONS_CONF"
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
    log_info "📊 RÉSUMÉ DES CONTEXTES SVI (depuis extensions.conf):"
    echo "─────────────────────────────"
    
    for context in "ivr-language" "ivr-main" "ivr-main-en"; do
        echo "🌐 [$context]:"
        local options=$(get_context_options "$context")
        for option in $options; do
            local description=$(get_action_description "$context" "$option")
            echo "    $option → $description"
        done
        echo ""
    done
    
    echo "🎯 FLUX COMPLET:"
    echo "  9999 → ivr-language → ivr-main/ivr-main-en → Actions"
    echo ""
    
    log_info "📁 Fichier source: $EXTENSIONS_CONF"
}

# Fonction pour valider la configuration
validate_configuration() {
    echo ""
    log_info "🔍 VALIDATION DE LA CONFIGURATION SVI:"
    echo "─────────────────────────────"
    
    local errors=0
    
    # Vérifier que les contextes essentiels existent
    local required_contexts=("ivr-language" "ivr-main" "ivr-main-en")
    for context in "${required_contexts[@]}"; do
        if grep -q "^\[$context\]$" "$EXTENSIONS_CONF"; then
            log_success "✓ Contexte [$context] trouvé"
        else
            log_error "✗ Contexte [$context] manquant"
            ((errors++))
        fi
    done
    
    # Vérifier les extensions critiques
    local critical_extensions=(
        "ivr-language:1"
        "ivr-language:2" 
        "ivr-main:1"
        "ivr-main:2"
        "ivr-main:8"
        "ivr-main-en:1"
        "ivr-main-en:2"
        "ivr-main-en:8"
    )
    
    for ext in "${critical_extensions[@]}"; do
        local context="${ext%:*}"
        local option="${ext#*:}"
        local description=$(get_action_description "$context" "$option")
        if [[ "$description" != "Action non trouvée" ]]; then
            log_success "✓ Extension $ext configurée"
        else
            log_error "✗ Extension $ext manquante"
            ((errors++))
        fi
    done
    
    echo ""
    if [[ $errors -eq 0 ]]; then
        log_success "🎉 Configuration SVI valide ! Aucune erreur détectée."
    else
        log_error "⚠️ $errors erreur(s) détectée(s) dans la configuration."
    fi
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
    echo -e "${BLUE}📁 Lecture de la configuration depuis: $EXTENSIONS_CONF${NC}"
    echo ""
    
    # Vérifier le fichier extensions.conf
    check_extensions_conf
    
    log_info "Ce script lit extensions.conf et simule la navigation SVI réelle"
    log_info "Tapez 'h' pour l'aide, 'v' pour valider la config, 'q' pour quitter"
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
            "v"|"validate")
                validate_configuration
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
