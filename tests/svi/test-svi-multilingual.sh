#!/bin/bash

# Test du SVI multilingue DoriaV2
# Usage: ./test-svi-multilingual.sh

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

echo -e "${BLUE}🌐 TEST SVI MULTILINGUE DORIAV2${NC}"
echo "================================"

# Test 1: Vérifier la configuration SVI 9999
log_info "Test 1: Configuration extension 9999..."
if docker compose exec asterisk asterisk -rx "dialplan show 9999@from-internal" | grep -q "9999"; then
    log_success "Extension 9999 configurée"
else
    log_error "Extension 9999 non configurée"
fi

# Test 2: Vérifier le contexte de sélection de langue
log_info "Test 2: Contexte sélection de langue..."
if docker compose exec asterisk asterisk -rx "dialplan show ivr-language" | grep -q "ivr-language"; then
    log_success "Contexte ivr-language configuré"
else
    log_error "Contexte ivr-language non configuré"
fi

# Test 3: Vérifier les contextes multilingues
log_info "Test 3: Contextes multilingues..."
contexts_found=0

if docker compose exec asterisk asterisk -rx "dialplan show ivr-main" | grep -q "ivr-main"; then
    log_success "Contexte ivr-main (français) configuré"
    ((contexts_found++))
else
    log_error "Contexte ivr-main (français) non configuré"
fi

if docker compose exec asterisk asterisk -rx "dialplan show ivr-main-en" | grep -q "ivr-main-en"; then
    log_success "Contexte ivr-main-en (anglais) configuré"
    ((contexts_found++))
else
    log_error "Contexte ivr-main-en (anglais) non configuré"
fi

# Test 4: Vérifier les dossiers audio
log_info "Test 4: Structure dossiers audio..."
audio_dirs=0

if docker compose exec asterisk test -d "/var/lib/asterisk/sounds/custom/fr"; then
    log_success "Dossier audio français présent"
    ((audio_dirs++))
else
    log_warning "Dossier audio français manquant"
fi

if docker compose exec asterisk test -d "/var/lib/asterisk/sounds/custom/en"; then
    log_success "Dossier audio anglais présent"
    ((audio_dirs++))
else
    log_warning "Dossier audio anglais manquant"
fi

# Test 5: Vérifier les fichiers audio de sélection de langue
log_info "Test 5: Fichiers audio sélection de langue..."
language_files=0

files_to_check=("language-prompt.wav" "language-invalid.wav" "language-timeout.wav")
for file in "${files_to_check[@]}"; do
    if docker compose exec asterisk test -f "/var/lib/asterisk/sounds/custom/$file"; then
        log_success "Fichier $file présent"
        ((language_files++))
    else
        log_warning "Fichier $file manquant"
    fi
done

# Test 6: Vérifier les fichiers audio français
log_info "Test 6: Fichiers audio français..."
fr_files=0

fr_files_to_check=("welcome.wav" "menu-main.wav" "language-selected.wav" "change-language.wav")
for file in "${fr_files_to_check[@]}"; do
    if docker compose exec asterisk test -f "/var/lib/asterisk/sounds/custom/fr/$file"; then
        log_success "Fichier français $file présent"
        ((fr_files++))
    else
        log_warning "Fichier français $file manquant"
    fi
done

# Test 7: Vérifier les fichiers audio anglais
log_info "Test 7: Fichiers audio anglais..."
en_files=0

en_files_to_check=("welcome.wav" "menu-main.wav" "language-selected.wav" "change-language.wav")
for file in "${en_files_to_check[@]}"; do
    if docker compose exec asterisk test -f "/var/lib/asterisk/sounds/custom/en/$file"; then
        log_success "Fichier anglais $file présent"
        ((en_files++))
    else
        log_warning "Fichier anglais $file manquant"
    fi
done

# Test 8: Vérifier les nouvelles options du menu (option 8)
log_info "Test 8: Option changement de langue (8)..."
if docker compose exec asterisk asterisk -rx "dialplan show 8@ivr-main" | grep -q "exten => 8"; then
    log_success "Option changement de langue (8) configurée en français"
else
    log_warning "Option changement de langue (8) manquante en français"
fi

if docker compose exec asterisk asterisk -rx "dialplan show 8@ivr-main-en" | grep -q "exten => 8"; then
    log_success "Option changement de langue (8) configurée en anglais"
else
    log_warning "Option changement de langue (8) manquante en anglais"
fi

# Résultats
echo ""
echo -e "${BLUE}📊 RÉSULTATS DU TEST${NC}"
echo "===================="

total_score=$((contexts_found + audio_dirs + language_files + fr_files + en_files))
max_score=14

if [ $total_score -eq $max_score ]; then
    log_success "🎉 SVI MULTILINGUE PARFAITEMENT CONFIGURÉ ! ($total_score/$max_score)"
    echo ""
    echo -e "${GREEN}✨ Le SVI DoriaV2 est prêt avec support français/anglais !${NC}"
    echo ""
    echo "🎯 Comment tester :"
    echo "   1. Composer 9999 depuis votre client SIP"
    echo "   2. Écouter le message de sélection de langue"
    echo "   3. Appuyer sur 1 pour français ou 2 pour anglais"
    echo "   4. Naviguer dans le menu selon la langue choisie"
    echo "   5. Appuyer sur 8 pour changer de langue à tout moment"
elif [ $total_score -ge 10 ]; then
    log_warning "⚠️  SVI MULTILINGUE PARTIELLEMENT CONFIGURÉ ($total_score/$max_score)"
    echo ""
    echo "Le SVI de base fonctionne, mais certains fichiers audio peuvent manquer."
    echo "Exécutez: ./asterisk/generate_multilingual_audio.sh"
else
    log_error "❌ SVI MULTILINGUE INCOMPLET ($total_score/$max_score)"
    echo ""
    echo "Configuration incomplète. Vérifiez:"
    echo "1. La configuration Asterisk (extensions.conf)"
    echo "2. Les fichiers audio multilingues"
    echo "3. La structure des dossiers"
fi

echo ""
echo "📚 Documentation : docs/GUIDE_SVI_9999.md"
echo "🎵 Génération audio : ./asterisk/generate_multilingual_audio.sh"
