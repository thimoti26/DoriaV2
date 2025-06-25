#!/bin/bash

# Script de lancement de l'interface web DoriaV2
# Usage: ./start-web-interface.sh [port]

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WEB_DIR="$SCRIPT_DIR/web-interface"
DEFAULT_PORT=8080
PORT=${1:-$DEFAULT_PORT}

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${PURPLE}🌐 DoriaV2 - Interface Web Asterisk${NC}"
echo -e "${PURPLE}======================================${NC}"

# Fonction d'affichage avec couleurs
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Vérifier si Python3 est installé
check_python() {
    if command -v python3 >/dev/null 2>&1; then
        PYTHON_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2)
        log_success "Python3 trouvé (version $PYTHON_VERSION)"
        return 0
    else
        log_error "Python3 n'est pas installé"
        return 1
    fi
}

# Vérifier si le port est disponible
check_port() {
    if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
        log_warning "Le port $PORT est déjà utilisé"
        log_info "Tentative d'utilisation d'un port alternatif..."
        
        # Essayer des ports alternatifs
        for alt_port in 8081 8082 8083 8084 8085; do
            if ! lsof -Pi :$alt_port -sTCP:LISTEN -t >/dev/null 2>&1; then
                PORT=$alt_port
                log_info "Utilisation du port $PORT"
                return 0
            fi
        done
        
        log_error "Aucun port alternatif disponible"
        return 1
    else
        log_success "Port $PORT disponible"
        return 0
    fi
}

# Créer les répertoires nécessaires
setup_directories() {
    log_info "Création des répertoires nécessaires..."
    
    # Créer le répertoire de logs s'il n'existe pas
    mkdir -p "$SCRIPT_DIR/asterisk-logs"
    mkdir -p "$SCRIPT_DIR/web-interface/logs"
    
    log_success "Répertoires créés"
}

# Vérifier les fichiers nécessaires
check_files() {
    log_info "Vérification des fichiers nécessaires..."
    
    local missing_files=()
    
    if [[ ! -f "$WEB_DIR/index.html" ]]; then
        missing_files+=("web-interface/index.html")
    fi
    
    if [[ ! -f "$WEB_DIR/server.py" ]]; then
        missing_files+=("web-interface/server.py")
    fi
    
    if [[ ${#missing_files[@]} -gt 0 ]]; then
        log_error "Fichiers manquants: ${missing_files[*]}"
        return 1
    fi
    
    log_success "Tous les fichiers nécessaires sont présents"
    return 0
}

# Afficher les informations de démarrage
show_startup_info() {
    echo ""
    echo -e "${CYAN}🚀 Démarrage de l'interface web DoriaV2${NC}"
    echo -e "${CYAN}=====================================${NC}"
    echo -e "${GREEN}📱 Interface web: http://localhost:$PORT${NC}"
    echo -e "${GREEN}🔧 API Asterisk:  http://localhost:$PORT/api/status${NC}"
    echo -e "${GREEN}📊 Tableau bord:  http://localhost:$PORT/#dashboard${NC}"
    echo -e "${GREEN}📞 Extensions:    http://localhost:$PORT/#extensions${NC}"
    echo -e "${GREEN}⚙️  Système:      http://localhost:$PORT/#system${NC}"
    echo -e "${GREEN}📄 Journaux:     http://localhost:$PORT/#logs${NC}"
    echo ""
    echo -e "${YELLOW}💡 Endpoints API disponibles:${NC}"
    echo -e "   • GET  /api/status           - Statut du système"
    echo -e "   • POST /api/control/start    - Démarrer Asterisk"
    echo -e "   • POST /api/control/stop     - Arrêter Asterisk"
    echo -e "   • POST /api/control/restart  - Redémarrer Asterisk"
    echo -e "   • GET  /api/logs/asterisk    - Journaux Asterisk"
    echo -e "   • GET  /api/logs/docker      - Journaux Docker"
    echo -e "   • POST /api/docker/up        - Démarrer conteneurs"
    echo -e "   • POST /api/docker/down      - Arrêter conteneurs"
    echo ""
    echo -e "${PURPLE}🔑 Extension configurée: osmo (1000) - osmo/osmoosmo${NC}"
    echo -e "${PURPLE}📞 Numéros de test: *43 (écho), *97 (messagerie), 123 (bienvenue)${NC}"
    echo ""
    echo -e "${CYAN}Appuyez sur Ctrl+C pour arrêter le serveur${NC}"
    echo -e "${CYAN}==========================================${NC}"
    echo ""
}

# Créer un fichier de configuration pour l'interface
create_config() {
    log_info "Création du fichier de configuration..."
    
    cat > "$WEB_DIR/config.json" << EOF
{
    "system": {
        "name": "DoriaV2 Asterisk PBX",
        "version": "2.0.0",
        "port": $PORT,
        "asterisk_config_path": "../asterisk-config",
        "compose_file": "../compose.yml",
        "control_script": "../asterisk-ctl.sh"
    },
    "extensions": {
        "osmo": {
            "number": "1000",
            "username": "osmo",
            "password": "osmoosmo",
            "name": "Extension principale",
            "status": "configured"
        }
    },
    "test_numbers": {
        "*43": "Test d'écho",
        "*97": "Messagerie vocale",
        "123": "Message de bienvenue",
        "1000": "Extension osmo"
    },
    "api": {
        "base_url": "/api",
        "timeout": 30,
        "retry_attempts": 3
    }
}
EOF

    log_success "Fichier de configuration créé: $WEB_DIR/config.json"
}

# Fonction de nettoyage
cleanup() {
    echo ""
    log_info "Arrêt de l'interface web..."
    
    # Tuer tous les processus Python du serveur web s'ils existent
    pkill -f "python3.*server.py" 2>/dev/null || true
    
    log_success "Interface web arrêtée"
    exit 0
}

# Gestionnaire de signal pour un arrêt propre
trap cleanup SIGINT SIGTERM

# Fonction principale
main() {
    log_info "Initialisation de l'interface web DoriaV2..."
    
    # Vérifications préliminaires
    if ! check_python; then
        log_error "Python3 est requis pour l'interface web"
        exit 1
    fi
    
    if ! check_port; then
        log_error "Impossible de trouver un port disponible"
        exit 1
    fi
    
    if ! check_files; then
        log_error "Fichiers requis manquants"
        exit 1
    fi
    
    # Configuration
    setup_directories
    create_config
    
    # Affichage des informations
    show_startup_info
    
    # Démarrage du serveur
    cd "$WEB_DIR"
    
    log_info "Démarrage du serveur Python sur le port $PORT..."
    
    # Démarrer le serveur avec gestion d'erreur
    if python3 server.py $PORT; then
        log_success "Serveur démarré avec succès"
    else
        log_error "Erreur lors du démarrage du serveur"
        exit 1
    fi
}

# Affichage de l'aide
show_help() {
    echo -e "${PURPLE}DoriaV2 - Interface Web Asterisk${NC}"
    echo ""
    echo -e "${YELLOW}Usage:${NC}"
    echo "  $0 [PORT]"
    echo ""
    echo -e "${YELLOW}Options:${NC}"
    echo "  PORT     Port pour l'interface web (défaut: 8080)"
    echo "  -h       Afficher cette aide"
    echo ""
    echo -e "${YELLOW}Exemples:${NC}"
    echo "  $0           # Démarrer sur le port 8080"
    echo "  $0 8081      # Démarrer sur le port 8081"
    echo ""
    echo -e "${YELLOW}Fonctionnalités:${NC}"
    echo "  • Interface web moderne avec Bootstrap"
    echo "  • Contrôle du système Asterisk"
    echo "  • Gestion des extensions SIP"
    echo "  • Visualisation des journaux"
    echo "  • API REST pour l'automatisation"
    echo "  • Configuration Linphone intégrée"
}

# Gestion des arguments
case "${1:-}" in
    -h|--help|help)
        show_help
        exit 0
        ;;
    *)
        main
        ;;
esac
