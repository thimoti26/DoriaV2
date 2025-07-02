#!/bin/bash

# Test audio automatique pour DoriaV2
# Usage: ./test-audio-auto.sh

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

echo -e "${BLUE}🎵 TEST AUDIO AUTOMATIQUE DORIAV2${NC}"
echo "================================="

# Test 1: Vérifier les fichiers audio par défaut
log_info "Test 1: Fichiers audio par défaut Asterisk..."
default_sounds=$(docker compose exec asterisk find /var/lib/asterisk/sounds -name "*.wav" | wc -l)
if [ "$default_sounds" -gt 0 ]; then
    log_success "Fichiers audio par défaut présents ($default_sounds fichiers)"
else
    log_error "Aucun fichier audio par défaut trouvé"
fi

# Test 2: Vérifier les fichiers audio personnalisés
log_info "Test 2: Fichiers audio personnalisés..."
custom_sounds=$(docker compose exec asterisk find /var/lib/asterisk/sounds/custom -name "*.wav" 2>/dev/null | wc -l || echo "0")
if [ "$custom_sounds" -gt 0 ]; then
    log_success "Fichiers audio personnalisés présents ($custom_sounds fichiers)"
    docker compose exec asterisk ls -la /var/lib/asterisk/sounds/custom/
else
    log_warning "Aucun fichier audio personnalisé trouvé"
fi

# Test 3: Test extension audio simple
log_info "Test 3: Extension de test audio (*44)..."
if docker compose exec asterisk asterisk -rx "dialplan show *44@from-internal" | grep -q "\*44"; then
    log_success "Extension test audio *44 configurée"
else
    log_error "Extension test audio *44 non configurée"
fi

# Test 4: Test extension écho
log_info "Test 4: Extension test écho (*43)..."
if docker compose exec asterisk asterisk -rx "dialplan show *43@from-internal" | grep -q "\*43"; then
    log_success "Extension test écho *43 configurée"
else
    log_error "Extension test écho *43 non configurée"
fi

# Test 5: Test fichiers SVI
log_info "Test 5: Fichiers audio SVI..."
required_files=("welcome.wav" "menu-main.wav" "commercial.wav" "support.wav" "conference.wav" "operator.wav" "invalid.wav" "timeout.wav")
missing_files=0

for file in "${required_files[@]}"; do
    if docker compose exec asterisk test -f "/var/lib/asterisk/sounds/custom/$file"; then
        log_success "Fichier $file présent"
    else
        log_error "Fichier $file manquant"
        ((missing_files++))
    fi
done

if [ $missing_files -eq 0 ]; then
    log_success "Tous les fichiers audio SVI sont présents"
else
    log_warning "$missing_files fichier(s) SVI manquant(s)"
fi

# Test 6: Configuration RTP
log_info "Test 6: Configuration RTP..."
if docker compose exec asterisk asterisk -rx "rtp show settings" | grep -q "RTP"; then
    log_success "Configuration RTP accessible"
else
    log_warning "Configuration RTP non accessible"
fi

echo ""
log_success "🎉 Test audio terminé !"
echo ""
echo "Extensions de test disponibles:"
echo "  *43 - Test écho"
echo "  *44 - Test audio simple"  
echo "  *45 - Test tonalité"
echo "  999 - Test volume"
echo " 9999 - SVI complet"
