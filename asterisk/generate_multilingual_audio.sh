#!/bin/bash

# Script de génération des fichiers audio multilingues pour DoriaV2
# Usage: ./generate_multilingual_audio.sh

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

# Dossiers
CUSTOM_DIR="./asterisk/sounds/custom"
FR_DIR="$CUSTOM_DIR/fr"
EN_DIR="$CUSTOM_DIR/en"

echo -e "${BLUE}🎵 GÉNÉRATION FICHIERS AUDIO MULTILINGUES${NC}"
echo "============================================="

# Vérifier si espeak est installé
if ! command -v espeak &> /dev/null; then
    log_warning "espeak non trouvé. Installation..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            brew install espeak
        else
            log_error "Homebrew requis pour installer espeak sur macOS"
            exit 1
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        sudo apt-get update && sudo apt-get install -y espeak
    fi
fi

# Vérifier si sox est installé
if ! command -v sox &> /dev/null; then
    log_warning "sox non trouvé. Installation..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install sox
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get install -y sox
    fi
fi

# Fonction de génération audio
generate_audio() {
    local text="$1"
    local filename="$2"
    local voice="$3"
    local output_dir="$4"
    
    log_info "Génération: $filename"
    
    # Générer avec espeak
    espeak -v "$voice" -s 150 -w "/tmp/temp_audio.wav" "$text"
    
    # Convertir au format Asterisk (8kHz, mono, 16-bit)
    sox "/tmp/temp_audio.wav" -r 8000 -c 1 -b 16 "$output_dir/$filename"
    
    # Nettoyer
    rm -f "/tmp/temp_audio.wav"
    
    log_success "Créé: $output_dir/$filename"
}

# Créer les dossiers si nécessaire
mkdir -p "$FR_DIR" "$EN_DIR"

log_info "Génération des fichiers de sélection de langue..."

# Fichiers de sélection de langue (racine)
generate_audio "Pour français, tapez 1. For English, press 2" "language-prompt.wav" "fr+en" "$CUSTOM_DIR"
generate_audio "Option invalide. Invalid option" "language-invalid.wav" "fr+en" "$CUSTOM_DIR"
generate_audio "Pas de réponse, français par défaut. No response, defaulting to French" "language-timeout.wav" "fr+en" "$CUSTOM_DIR"

log_info "Génération des fichiers français..."

# Fichiers français
generate_audio "Français sélectionné" "language-selected.wav" "fr" "$FR_DIR"
generate_audio "Changement de langue" "change-language.wav" "fr" "$FR_DIR"

# Vérifier si les fichiers français existent déjà, sinon les créer
if [ ! -f "$FR_DIR/welcome.wav" ]; then
    generate_audio "Bienvenue sur le serveur DoriaV2" "welcome.wav" "fr" "$FR_DIR"
fi

if [ ! -f "$FR_DIR/menu-main.wav" ]; then
    generate_audio "Pour joindre le service commercial, tapez 1. Pour le support technique, tapez 2. Pour la salle de conférence, tapez 3. Pour le répertoire téléphonique, tapez 4. Pour l'opérateur, tapez 0. Pour changer de langue, tapez 8. Pour revenir au menu principal, tapez 9" "menu-main.wav" "fr" "$FR_DIR"
fi

log_info "Génération des fichiers anglais..."

# Fichiers anglais
generate_audio "English selected" "language-selected.wav" "en" "$EN_DIR"
generate_audio "Language change" "change-language.wav" "en" "$EN_DIR"
generate_audio "Welcome to DoriaV2 server" "welcome.wav" "en" "$EN_DIR"
generate_audio "For sales department, press 1. For technical support, press 2. For conference room, press 3. For directory, press 4. For operator, press 0. To change language, press 8. To return to main menu, press 9" "menu-main.wav" "en" "$EN_DIR"
generate_audio "Connecting to sales department" "commercial.wav" "en" "$EN_DIR"
generate_audio "Connecting to technical support" "support.wav" "en" "$EN_DIR"
generate_audio "Accessing conference room" "conference.wav" "en" "$EN_DIR"
generate_audio "Accessing directory" "directory.wav" "en" "$EN_DIR"
generate_audio "Connecting to operator" "operator.wav" "en" "$EN_DIR"
generate_audio "Invalid option, please try again" "invalid.wav" "en" "$EN_DIR"
generate_audio "No response, returning to main menu" "timeout.wav" "en" "$EN_DIR"

echo ""
log_success "🎉 Génération des fichiers audio terminée !"
echo ""
echo "📁 Fichiers créés:"
echo "   $CUSTOM_DIR/language-*.wav (3 fichiers)"
echo "   $FR_DIR/ (fichiers français)"
echo "   $EN_DIR/ (fichiers anglais)"
echo ""
echo "🎯 Test du SVI:"
echo "   Composer 9999 depuis votre client SIP"
echo "   1 = Français, 2 = English"
echo ""
echo "📚 Documentation: asterisk/sounds/AUDIO_FILES_MULTILINGUAL.md"
