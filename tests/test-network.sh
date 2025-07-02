#!/bin/bash

# Script de test connectivité réseau DoriaV2
# Usage: ./test-network.sh

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

echo -e "${BLUE}🌐 TEST CONNECTIVITÉ RÉSEAU DORIAV2${NC}"
echo "==================================="

# Test 1: Vérifier le réseau Docker
log_info "Test 1: Vérification du réseau Docker..."
if docker network ls | grep -q "doriav2"; then
    log_success "Réseau Docker 'doriav2' trouvé"
else
    log_warning "Réseau Docker 'doriav2' non trouvé"
fi

# Test 2: Vérifier les ports
log_info "Test 2: Vérification des ports exposés..."

# Port SIP (5060)
if netstat -ln 2>/dev/null | grep -q ":5060"; then
    log_success "Port SIP 5060 exposé"
else
    log_warning "Port SIP 5060 non exposé"
fi

# Port HTTP (8080)
if netstat -ln 2>/dev/null | grep -q ":8080"; then
    log_success "Port HTTP 8080 exposé"
else
    log_warning "Port HTTP 8080 non exposé"
fi

# Test 3: Connectivité entre conteneurs
log_info "Test 3: Connectivité entre conteneurs..."
if docker compose exec asterisk ping -c 1 doriav2-mysql >/dev/null 2>&1; then
    log_success "Connectivité Asterisk → MySQL OK"
else
    log_error "Connectivité Asterisk → MySQL KO"
fi

if docker compose exec asterisk ping -c 1 doriav2-web >/dev/null 2>&1; then
    log_success "Connectivité Asterisk → Web OK"
else
    log_error "Connectivité Asterisk → Web KO"
fi

# Test 4: Résolution DNS interne
log_info "Test 4: Résolution DNS interne..."
if docker compose exec asterisk nslookup doriav2-mysql >/dev/null 2>&1; then
    log_success "Résolution DNS doriav2-mysql OK"
else
    log_error "Résolution DNS doriav2-mysql KO"
fi

echo ""
log_info "Tests réseau terminés"
