#!/bin/bash

# Script de mise à jour et gestion des volumes DoriaV2
# Usage: ./update-volumes.sh [action]

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
📦 GESTION DES VOLUMES DORIAV2

USAGE:
    ./update-volumes.sh [ACTION]

ACTIONS:
    backup          Sauvegarder les volumes
    restore         Restaurer les volumes
    update          Mettre à jour les configurations
    check           Vérifier l'état des volumes
    clean           Nettoyer les volumes inutilisés

EXEMPLES:
    ./update-volumes.sh backup      # Sauvegarder
    ./update-volumes.sh update      # Mettre à jour
    ./update-volumes.sh check       # Vérifier

EOF
}

backup_volumes() {
    log_info "📦 Sauvegarde des volumes..."
    
    local backup_dir="./backups/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    # Sauvegarder les configurations Asterisk
    if docker volume ls | grep -q "doriav2_asterisk-config"; then
        log_info "Sauvegarde volume asterisk-config..."
        docker run --rm -v doriav2_asterisk-config:/source -v "$PWD/$backup_dir":/backup alpine tar czf /backup/asterisk-config.tar.gz -C /source .
    fi
    
    # Sauvegarder les données MySQL
    if docker volume ls | grep -q "doriav2_mysql-data"; then
        log_info "Sauvegarde volume mysql-data..."
        docker run --rm -v doriav2_mysql-data:/source -v "$PWD/$backup_dir":/backup alpine tar czf /backup/mysql-data.tar.gz -C /source .
    fi
    
    log_success "Sauvegarde créée dans: $backup_dir"
}

update_volumes() {
    log_info "🔄 Mise à jour des volumes..."
    
    # Synchroniser les configurations locales vers les volumes
    if [ -d "./asterisk/config" ]; then
        log_info "Synchronisation configuration Asterisk..."
        docker run --rm -v "$PWD/asterisk/config":/source:ro -v doriav2_asterisk-config:/dest alpine sh -c "cp -r /source/* /dest/"
    fi
    
    if [ -d "./asterisk/sounds" ]; then
        log_info "Synchronisation sons Asterisk..."
        docker run --rm -v "$PWD/asterisk/sounds":/source:ro -v doriav2_asterisk-sounds:/dest alpine sh -c "cp -r /source/* /dest/"
    fi
    
    log_success "Volumes mis à jour"
}

check_volumes() {
    log_info "🔍 Vérification des volumes..."
    
    echo ""
    echo "Volumes Docker:"
    docker volume ls | grep -E "(doriav2|VOLUME)" || log_warning "Aucun volume DoriaV2 trouvé"
    
    echo ""
    echo "Espace utilisé par les volumes:"
    docker system df -v | grep -A 10 "VOLUME NAME" || log_warning "Impossible d'afficher l'espace"
    
    echo ""
    log_info "Contenu du volume asterisk-config:"
    docker run --rm -v doriav2_asterisk-config:/config alpine ls -la /config || log_warning "Volume asterisk-config inaccessible"
    
    log_success "Vérification terminée"
}

clean_volumes() {
    log_warning "⚠️  Nettoyage des volumes inutilisés..."
    echo "Cette action va supprimer les volumes Docker non utilisés."
    read -p "Continuer ? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker volume prune -f
        log_success "Volumes inutilisés supprimés"
    else
        log_info "Nettoyage annulé"
    fi
}

restore_volumes() {
    log_info "📥 Restauration des volumes..."
    
    if [ ! -d "./backups" ]; then
        log_error "Aucun dossier de sauvegarde trouvé"
        exit 1
    fi
    
    local latest_backup=$(ls -1t ./backups/ | head -1)
    
    if [ -z "$latest_backup" ]; then
        log_error "Aucune sauvegarde trouvée"
        exit 1
    fi
    
    log_info "Restauration depuis: $latest_backup"
    
    # Arrêter les services
    docker compose down
    
    # Restaurer asterisk-config
    if [ -f "./backups/$latest_backup/asterisk-config.tar.gz" ]; then
        log_info "Restauration asterisk-config..."
        docker volume rm doriav2_asterisk-config 2>/dev/null || true
        docker volume create doriav2_asterisk-config
        docker run --rm -v doriav2_asterisk-config:/dest -v "$PWD/backups/$latest_backup":/backup alpine tar xzf /backup/asterisk-config.tar.gz -C /dest
    fi
    
    # Restaurer mysql-data
    if [ -f "./backups/$latest_backup/mysql-data.tar.gz" ]; then
        log_info "Restauration mysql-data..."
        docker volume rm doriav2_mysql-data 2>/dev/null || true
        docker volume create doriav2_mysql-data
        docker run --rm -v doriav2_mysql-data:/dest -v "$PWD/backups/$latest_backup":/backup alpine tar xzf /backup/mysql-data.tar.gz -C /dest
    fi
    
    log_success "Restauration terminée. Redémarrez les services avec: docker compose up -d"
}

# Main
case "${1:-check}" in
    "backup")
        backup_volumes
        ;;
    "restore")
        restore_volumes
        ;;
    "update")
        update_volumes
        ;;
    "check")
        check_volumes
        ;;
    "clean")
        clean_volumes
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        log_error "Action inconnue: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
