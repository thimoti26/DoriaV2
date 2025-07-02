#!/bin/bash

# Script principal DoriaV2 - Point d'entrée pour tous les outils
# Usage: ./doria.sh [commande]

set -euo pipefail

readonly SCRIPT_DIR="./scripts"
readonly TESTS_DIR="./tests"
readonly DOCS_DIR="./docs"

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

show_help() {
    cat << EOF
🚀 DORIAV2 - Serveur Asterisk avec Docker

USAGE:
    ./doria.sh [COMMANDE]

COMMANDES PRINCIPALES:
    start               Démarrer la stack Docker
    stop                Arrêter la stack Docker
    restart             Redémarrer la stack Docker
    status              Afficher l'état des conteneurs

CONFIGURATION:
    reload              Recharger les configurations
    reload-asterisk     Recharger uniquement Asterisk
    reload-web          Recharger uniquement Apache
    reload-mysql        Instructions pour MySQL

TESTS ET VALIDATION:
    test                Test complet de la stack
    test-audio          Test audio automatique
    test-linphone       Validation configuration Linphone
    test-network        Test connectivité réseau
    test-volumes        Test des volumes de configuration
    test-svi            Test SVI multilingue (français/anglais)
    test-svi-nav        Test navigation SVI interactif
    test-svi-paths      Test automatique de tous les chemins SVI

MAINTENANCE:
    debug-audio         Monitoring audio en temps réel
    update-volumes      Migration et backup des volumes
    cleanup             Nettoyage des fichiers temporaires

DOCUMENTATION:
    docs                Ouvrir le dossier documentation
    help, -h, --help   Afficher cette aide

EXEMPLES:
    ./doria.sh start           # Démarrer DoriaV2
    ./doria.sh test-linphone   # Tester la config Linphone
    ./doria.sh debug-audio     # Monitoring en temps réel
    ./doria.sh docs            # Voir la documentation

STRUCTURE:
    scripts/            Scripts de gestion et maintenance
    tests/              Scripts de test et validation
    docs/               Documentation complète
    asterisk/           Configuration Asterisk
    mysql/              Configuration MySQL
    src/                Code source web

EOF
}

# Vérification de l'existence des scripts
check_script_exists() {
    local script_name="$1"
    local script_path="$SCRIPT_DIR/$script_name"
    
    if [[ ! -f "$script_path" ]]; then
        log_error "Script $script_name non trouvé dans $SCRIPT_DIR"
        exit 1
    fi
}

# Vérification de l'existence des scripts de test
check_test_exists() {
    local script_name="$1"
    local script_path="$TESTS_DIR/$script_name"
    
    if [[ ! -f "$script_path" ]]; then
        log_error "Script de test $script_name non trouvé dans $TESTS_DIR"
        exit 1
    fi
}

# Exécution des commandes
case "${1:-help}" in
    "start")
        log_info "🚀 Démarrage de la stack DoriaV2..."
        docker compose up -d
        ;;
    "stop")
        log_info "🛑 Arrêt de la stack DoriaV2..."
        docker compose down
        ;;
    "restart")
        log_info "🔄 Redémarrage de la stack DoriaV2..."
        docker compose restart
        ;;
    "status")
        log_info "📊 État des conteneurs DoriaV2..."
        docker compose ps
        ;;
    "reload")
        check_script_exists "reload-config.sh"
        "$SCRIPT_DIR/reload-config.sh"
        ;;
    "reload-asterisk")
        check_script_exists "reload-config.sh"
        "$SCRIPT_DIR/reload-config.sh" asterisk
        ;;
    "reload-web")
        check_script_exists "reload-config.sh"
        "$SCRIPT_DIR/reload-config.sh" web
        ;;
    "reload-mysql")
        check_script_exists "reload-config.sh"
        "$SCRIPT_DIR/reload-config.sh" mysql
        ;;
    "test")
        check_test_exists "test-stack.sh"
        "$TESTS_DIR/test-stack.sh"
        ;;
    "test-audio")
        check_test_exists "test-audio-auto.sh"
        "$TESTS_DIR/test-audio-auto.sh"
        ;;
    "test-linphone")
        check_test_exists "test-linphone.sh"
        "$TESTS_DIR/test-linphone.sh"
        ;;
    "test-network")
        check_test_exists "test-network.sh"
        "$TESTS_DIR/test-network.sh"
        ;;
    "test-volumes")
        check_test_exists "test-volumes.sh"
        "$TESTS_DIR/test-volumes.sh"
        ;;
    "test-svi")
        check_test_exists "test-svi-multilingual.sh"
        "$TESTS_DIR/test-svi-multilingual.sh"
        ;;
    "test-svi-nav")
        check_test_exists "test-svi-navigation.sh"
        "$TESTS_DIR/test-svi-navigation.sh"
        ;;
    "test-svi-paths")
        check_test_exists "test-svi-paths.sh"
        "$TESTS_DIR/test-svi-paths.sh"
        ;;
    "debug-audio")
        check_test_exists "debug-audio.sh"
        "$TESTS_DIR/debug-audio.sh"
        ;;
    "update-volumes")
        check_script_exists "update-volumes.sh"
        "$SCRIPT_DIR/update-volumes.sh"
        ;;
    "cleanup")
        check_script_exists "cleanup.sh"
        "$SCRIPT_DIR/cleanup.sh"
        ;;
    "docs")
        log_info "📚 Ouverture du dossier documentation..."
        if command -v open &> /dev/null; then
            open "$DOCS_DIR"
        elif command -v xdg-open &> /dev/null; then
            xdg-open "$DOCS_DIR"
        else
            log_info "Dossier documentation : $DOCS_DIR"
            ls -la "$DOCS_DIR"
        fi
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        log_error "Commande inconnue : $1"
        echo ""
        show_help
        exit 1
        ;;
esac
