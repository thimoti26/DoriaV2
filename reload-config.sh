#!/bin/bash

# Script de rechargement des configurations DoriaV2
# Permet de recharger les configurations modifiées sans redémarrer les conteneurs
# Usage: ./reload-config.sh [asterisk|mysql|web|test|all|help]

set -euo pipefail  # Mode strict pour une meilleure gestion d'erreurs

# Configuration
readonly SCRIPT_NAME=$(basename "$0")
readonly ASTERISK_CONTAINER="doriav2-asterisk"
readonly MYSQL_CONTAINER="doriav2-mysql"
readonly WEB_CONTAINER="doriav2-web"

# Couleurs pour l'affichage
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Fonction utilitaire pour les messages
log_info() { echo -e "${BLUE}${1}${NC}"; }
log_success() { echo -e "${GREEN}✅ ${1}${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  ${1}${NC}"; }
log_error() { echo -e "${RED}❌ ${1}${NC}"; }

# Vérification des prérequis
check_prerequisites() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker n'est pas installé ou n'est pas dans le PATH"
        exit 1
    fi
    
    if ! docker ps --format "table {{.Names}}" | grep -q "$ASTERISK_CONTAINER"; then
        log_error "Le conteneur $ASTERISK_CONTAINER n'est pas en cours d'exécution"
        exit 1
    fi
}

echo "🔄 RECHARGEMENT DES CONFIGURATIONS DORIAV2"
echo "==========================================="

# Fonction pour exécuter une commande Asterisk
execute_asterisk_command() {
    local command="$1"
    local description="$2"
    
    if docker exec "$ASTERISK_CONTAINER" asterisk -rx "$command" &> /dev/null; then
        log_success "$description"
        return 0
    else
        log_error "Erreur lors de l'exécution : $command"
        return 1
    fi
}

reload_asterisk_config() {
    log_info "\n📞 Rechargement configuration Asterisk..."
    
    local commands=(
        "dialplan reload:Dialplan rechargé"
        "pjsip reload:Configuration PJSIP rechargée"
        "rtp reload:Configuration RTP rechargée"
        "module reload:Modules rechargés"
    )
    
    for cmd_desc in "${commands[@]}"; do
        local cmd="${cmd_desc%%:*}"
        local desc="${cmd_desc##*:}"
        
        if ! execute_asterisk_command "$cmd" "$desc"; then
            case "$cmd" in
                "rtp reload"|"module reload")
                    log_warning "$desc (peut nécessiter un redémarrage)"
                    ;;
                *)
                    log_error "Échec du rechargement : $desc"
                    ;;
            esac
        fi
    done
}

reload_mysql_config() {
    log_info "\n🗄️  Rechargement configuration MySQL..."
    
    log_warning "MySQL nécessite un redémarrage pour prendre en compte les changements de configuration"
    log_info "   Pour redémarrer MySQL: docker compose restart mysql"
}

reload_web_config() {
    log_info "\n🌐 Rechargement configuration Web..."
    
    if docker exec "$WEB_CONTAINER" apache2ctl graceful &> /dev/null; then
        log_success "Configuration Apache rechargée"
    else
        log_warning "Apache graceful reload non disponible, redémarrage recommandé"
        log_info "   Pour redémarrer Apache: docker compose restart web"
    fi
}

test_configurations() {
    log_info "\n🧪 Test des configurations..."
    
    # Test syntaxe Asterisk dialplan
    echo "   Test syntaxe dialplan..."
    local dialplan_errors
    dialplan_errors=$(docker exec "$ASTERISK_CONTAINER" asterisk -rx "dialplan show" 2>&1 | grep -i "error\|warning" | head -3 || true)
    
    if [[ -z "$dialplan_errors" ]]; then
        echo -e "   ${GREEN}✅ Syntaxe dialplan correcte${NC}"
    else
        echo -e "   ${RED}❌ Erreurs détectées dans le dialplan:${NC}"
        while IFS= read -r line; do
            echo -e "      ${RED}$line${NC}"
        done <<< "$dialplan_errors"
    fi
    
    # Test endpoints PJSIP
    echo "   Test endpoints PJSIP..."
    local endpoints_count=0
    
    if docker exec "$ASTERISK_CONTAINER" asterisk -rx "pjsip show endpoints" &>/dev/null; then
        local pjsip_output
        pjsip_output=$(docker exec "$ASTERISK_CONTAINER" asterisk -rx "pjsip show endpoints" 2>/dev/null)
        endpoints_count=$(echo "$pjsip_output" | grep -c "100[1-4]" 2>/dev/null || echo "0")
    fi
    
    # Nettoyer le résultat pour s'assurer qu'il s'agit d'un nombre
    endpoints_count=$(echo "$endpoints_count" | tr -d '\n\r ' | grep -o '[0-9]*' | head -1)
    endpoints_count=${endpoints_count:-0}
    
    if [[ $endpoints_count -ge 4 ]]; then
        echo -e "   ${GREEN}✅ Endpoints PJSIP configurés (${endpoints_count}/4)${NC}"
    elif [[ $endpoints_count -gt 0 ]]; then
        echo -e "   ${YELLOW}⚠️  Seulement ${endpoints_count}/4 endpoints détectés${NC}"
    else
        echo -e "   ${YELLOW}⚠️  Aucun endpoint PJSIP détecté (PJSIP peut ne pas être configuré)${NC}"
    fi
}

show_help() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTION]

DESCRIPTION:
    Script de rechargement des configurations DoriaV2 sans redémarrage de conteneurs.

OPTIONS:
    asterisk, ast     Recharger uniquement la configuration Asterisk
    mysql, db         Afficher les instructions pour MySQL
    web, apache       Recharger uniquement la configuration Apache
    test             Tester la validité des configurations
    all              Recharger toutes les configurations (défaut)
    help, -h, --help Afficher cette aide

COMMANDES MANUELLES:
    Asterisk (dans le conteneur):
      dialplan reload     Recharger extensions.conf
      pjsip reload        Recharger pjsip.conf
      rtp reload          Recharger rtp.conf
      module reload       Recharger tous les modules
      core reload         Rechargement général

    Apache:
      docker exec $WEB_CONTAINER apache2ctl graceful

    Services (nécessitent redémarrage):
      docker compose restart mysql
      docker compose restart redis

EXEMPLES:
    $SCRIPT_NAME                 # Rechargement complet
    $SCRIPT_NAME asterisk        # Asterisk uniquement
    $SCRIPT_NAME test            # Tests uniquement

EOF
}

show_completion_message() {
    echo ""
    log_success "🎉 Rechargement terminé !"
    echo ""
    log_info "💡 Utilisation:"
    echo "   Modifiez les fichiers de configuration et relancez ce script pour"
    echo "   appliquer les changements sans redémarrer les conteneurs."
    echo ""
    log_info "📋 Fichiers de configuration montés:"
    echo "   • ./asterisk/config/*.conf  → /etc/asterisk/"
    echo "   • ./mysql/my.cnf            → /etc/mysql/conf.d/"
    echo "   • ./src/                    → /var/www/html/"
    echo ""
    log_info "🔍 Outils supplémentaires:"
    echo "   • Monitoring: ./debug-audio.sh"
    echo "   • Tests: ./test-stack.sh"
    echo "   • Tests volumes: ./test-volumes.sh"
    echo ""
}

# Fonction principale
main() {
    check_prerequisites
    
    case "${1:-all}" in
        "asterisk"|"ast")
            reload_asterisk_config
            test_configurations
            ;;
        "mysql"|"db")
            reload_mysql_config
            ;;
        "web"|"apache")
            reload_web_config
            ;;
        "test")
            test_configurations
            ;;
        "help"|"-h"|"--help")
            show_help
            exit 0
            ;;
        "all"|*)
            reload_asterisk_config
            reload_mysql_config
            reload_web_config
            test_configurations
            ;;
    esac
    
    show_completion_message
}

# Point d'entrée du script
main "$@"
