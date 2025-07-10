#!/bin/bash

# Script de test des volumes de configuration DoriaV2
# Usage: ./test-volumes.sh

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

echo -e "${BLUE}📁 TEST VOLUMES CONFIGURATION DORIAV2${NC}"
echo "====================================="

# Test 1: Vérifier les fichiers de configuration Asterisk
log_info "Test 1: Vérification des fichiers de configuration Asterisk..."

required_asterisk_files=(
    "asterisk/config/extensions.conf"
    "asterisk/config/pjsip.conf"
    "asterisk/config/manager.conf"
    "asterisk/config/odbc.ini"
    "asterisk/config/res_odbc.conf"
)

for file in "${required_asterisk_files[@]}"; do
    if [[ -f "$file" ]]; then
        log_success "Fichier $file présent"
    else
        log_error "Fichier $file manquant"
    fi
done

# Test 2: Vérifier les fichiers audio multilingues
log_info "Test 2: Vérification des fichiers audio multilingues..."

required_audio_fr=(
    "asterisk/sounds/custom/fr/welcome.wav"
    "asterisk/sounds/custom/fr/menu-main.wav"
    "asterisk/sounds/custom/fr/invalid.wav"
    "asterisk/sounds/custom/fr/timeout.wav"
)

for file in "${required_audio_fr[@]}"; do
    if [[ -f "$file" ]]; then
        log_success "Fichier audio FR $file présent"
    else
        log_warning "Fichier audio FR $file manquant"
    fi
done

required_audio_en=(
    "asterisk/sounds/custom/en/welcome.wav"
    "asterisk/sounds/custom/en/menu-main.wav"
    "asterisk/sounds/custom/en/invalid.wav"
    "asterisk/sounds/custom/en/timeout.wav"
)

for file in "${required_audio_en[@]}"; do
    if [[ -f "$file" ]]; then
        log_success "Fichier audio EN $file présent"
    else
        log_warning "Fichier audio EN $file manquant"
    fi
done

# Test 3: Vérifier la configuration MySQL
log_info "Test 3: Vérification de la configuration MySQL..."

if [[ -f "mysql/init.sql" ]]; then
    log_success "Fichier mysql/init.sql présent"
    if grep -q "doriav2" mysql/init.sql; then
        log_success "Base de données 'doriav2' configurée"
    else
        log_warning "Base de données 'doriav2' non trouvée"
    fi
else
    log_error "Fichier mysql/init.sql manquant"
fi

# Test 4: Vérifier les volumes Docker
log_info "Test 4: Vérification des volumes Docker..."

if docker volume ls | grep -q "doriav2"; then
    log_success "Volumes Docker DoriaV2 présents"
    docker volume ls | grep "doriav2"
else
    log_warning "Aucun volume Docker DoriaV2 trouvé"
fi

echo ""
log_info "Tests volumes terminés"
