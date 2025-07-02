#!/bin/bash

# Script de rechargement des configurations DoriaV2
# Usage: ./reload-config.sh [service]

set -euo pipefail

# Couleurs
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ️  ${1}${NC}"; }
log_success() { echo -e "${GREEN}✅ ${1}${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  ${1}${NC}"; }
log_error() { echo -e "${RED}❌ ${1}${NC}"; }

show_help() {
    cat << EOF
🔄 RECHARGEMENT CONFIGURATIONS DORIAV2

USAGE:
    ./reload-config.sh [SERVICE]

SERVICES:
    asterisk        Recharger uniquement Asterisk
    apache          Recharger uniquement Apache  
    mysql           Instructions pour MySQL
    all             Recharger tous les services (défaut)

EXEMPLES:
    ./reload-config.sh              # Tout recharger
    ./reload-config.sh asterisk     # Asterisk uniquement
    ./reload-config.sh apache       # Apache uniquement

EOF
}

reload_asterisk() {
    log_info "Rechargement des configurations Asterisk..."
    
    if docker compose ps asterisk | grep -q "Up"; then
        # Recharger la configuration sans redémarrer
        docker compose exec asterisk asterisk -rx "core reload" && \
        docker compose exec asterisk asterisk -rx "pjsip reload" && \
        docker compose exec asterisk asterisk -rx "dialplan reload" && \
        log_success "Configuration Asterisk rechargée"
    else
        log_warning "Container Asterisk non démarré, redémarrage..."
        docker compose restart asterisk
        log_success "Container Asterisk redémarré"
    fi
}

reload_apache() {
    log_info "Rechargement de la configuration Apache..."
    
    if docker compose ps web | grep -q "Up"; then
        docker compose exec web apache2ctl graceful && \
        log_success "Configuration Apache rechargée"
    else
        log_warning "Container web non démarré, redémarrage..."
        docker compose restart web
        log_success "Container web redémarré"
    fi
}

reload_mysql() {
    log_info "Instructions pour MySQL:"
    echo "  - MySQL ne supporte pas le rechargement à chaud"
    echo "  - Pour appliquer les changements my.cnf:"
    echo "    docker compose restart mysql"
    echo "  - Pour les changements de données:"
    echo "    Les modifications sont automatiquement prises en compte"
}

reload_all() {
    log_info "🔄 Rechargement de toutes les configurations..."
    echo ""
    
    reload_asterisk
    echo ""
    reload_apache
    echo ""
    reload_mysql
    
    echo ""
    log_success "🎉 Rechargement complet terminé !"
}

# Main
case "${1:-all}" in
    "asterisk")
        reload_asterisk
        ;;
    "apache"|"web")
        reload_apache
        ;;
    "mysql")
        reload_mysql
        ;;
    "all"|"")
        reload_all
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        log_error "Service inconnu: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
