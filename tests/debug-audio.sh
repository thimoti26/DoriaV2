#!/bin/bash

# Script de monitoring audio en temps réel pour DoriaV2
# Usage: ./debug-audio.sh

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

echo -e "${BLUE}🔊 MONITORING AUDIO DORIAV2${NC}"
echo "============================"

# Vérifier que les conteneurs sont en cours
if ! docker compose ps | grep -q "Up"; then
    log_error "Conteneurs arrêtés. Démarrez d'abord la stack avec: ./doria.sh start"
    exit 1
fi

log_info "Monitoring des journaux audio Asterisk..."
log_warning "Appuyez sur Ctrl+C pour arrêter le monitoring"
echo ""

# Suivre les logs Asterisk en temps réel
docker compose logs -f asterisk | grep -i -E "(dial|audio|rtp|pjsip|call)" --color=auto
