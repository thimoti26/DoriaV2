#!/bin/bash

# Test complet de la stack DoriaV2
# Usage: ./test-stack.sh

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

echo -e "${BLUE}🧪 TEST COMPLET DE LA STACK DORIAV2${NC}"
echo "=================================="

# Test 1: Vérifier que Docker Compose est disponible
log_info "Test 1: Vérification Docker Compose..."
if command -v docker compose &> /dev/null; then
    log_success "Docker Compose disponible"
else
    log_error "Docker Compose non trouvé"
    exit 1
fi

# Test 2: Vérifier l'état des conteneurs
log_info "Test 2: État des conteneurs..."
if docker compose ps | grep -q "Up"; then
    log_success "Conteneurs en cours d'exécution"
    docker compose ps
else
    log_warning "Conteneurs arrêtés, démarrage..."
    docker compose up -d
    sleep 10
fi

# Test 3: Test connectivité Asterisk
log_info "Test 3: Connectivité Asterisk..."
if docker compose exec asterisk asterisk -rx "core show version" &> /dev/null; then
    log_success "Asterisk accessible"
else
    log_error "Asterisk non accessible"
fi

# Test 4: Test base de données MySQL
log_info "Test 4: Base de données MySQL..."
if docker compose exec mysql mysql -uroot -proot_password -e "SELECT 1;" &> /dev/null; then
    log_success "MySQL accessible"
else
    log_error "MySQL non accessible"
fi

# Test 5: Test interface web
log_info "Test 5: Interface web..."
if curl -s http://localhost:8080 &> /dev/null; then
    log_success "Interface web accessible"
else
    log_warning "Interface web non accessible sur port 8080"
fi

# Test 6: Test extensions SIP
log_info "Test 6: Extensions SIP..."
extensions_count=$(docker compose exec asterisk asterisk -rx "pjsip show endpoints" | grep -c "1001\|1002\|1003\|1004" || echo "0")
if [ "$extensions_count" -ge 4 ]; then
    log_success "Extensions SIP configurées ($extensions_count/4)"
else
    log_warning "Extensions SIP manquantes ($extensions_count/4)"
fi

# Test 7: Test SVI 9999
log_info "Test 7: SVI extension 9999..."
if docker compose exec asterisk asterisk -rx "dialplan show 9999@from-internal" | grep -q "9999"; then
    log_success "SVI 9999 configuré"
else
    log_error "SVI 9999 non configuré"
fi

echo ""
log_success "🎉 Test de la stack terminé !"
echo ""
echo "Pour des tests spécifiques, utilisez:"
echo "  ./test-audio-auto.sh    # Test audio"
echo "  ./test-linphone.sh      # Configuration Linphone"
echo "  ./test-network.sh       # Connectivité réseau"
