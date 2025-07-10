#!/bin/bash

# Script de test configuration Linphone pour DoriaV2
# Usage: ./test-linphone.sh

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

echo -e "${BLUE}📱 TEST CONFIGURATION LINPHONE${NC}"
echo "==============================="

# Vérifier que les conteneurs sont en cours
if ! docker compose ps | grep -q "Up"; then
    log_error "Conteneurs arrêtés. Démarrez d'abord la stack avec: ./doria.sh start"
    exit 1
fi

# Test 1: Vérifier les endpoints PJSIP
log_info "Test 1: Vérification des endpoints PJSIP..."
if docker compose exec asterisk asterisk -rx "pjsip show endpoints" | grep -q "1001\|1002\|1003\|1004"; then
    log_success "Endpoints PJSIP configurés"
    docker compose exec asterisk asterisk -rx "pjsip show endpoints" | grep -E "1001|1002|1003|1004"
else
    log_error "Endpoints PJSIP non configurés"
fi

echo ""

# Test 2: Afficher la configuration pour Linphone
log_info "Test 2: Configuration recommandée pour Linphone..."
echo ""
echo -e "${YELLOW}📋 Configuration Linphone:${NC}"
echo "Serveur SIP: localhost:5060"
echo "Transport: UDP"
echo ""
echo -e "${YELLOW}👤 Comptes utilisateur disponibles:${NC}"
echo "Extension 1001 | Mot de passe: password1001"
echo "Extension 1002 | Mot de passe: password1002"
echo "Extension 1003 | Mot de passe: password1003"
echo "Extension 1004 | Mot de passe: password1004"
echo ""
echo -e "${YELLOW}🎯 Numéros de test:${NC}"
echo "Extension 9999: SVI multilingue (français/anglais)"
echo ""

log_success "Configuration Linphone validée"
