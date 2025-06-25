#!/bin/bash

# Script pour générer les fichiers audio du SVI avec la synthèse vocale macOS

SOUNDS_DIR="sounds"
mkdir -p $SOUNDS_DIR/custom

echo "Génération des fichiers audio pour le SVI..."

# Fonction pour générer un fichier audio
generate_audio() {
    local filename=$1
    local text=$2
    local voice=${3:-"Thomas"}  # Voix française par défaut
    
    echo "Génération de $filename.wav..."
    
    # Générer avec 'say' en WAV temporaire
    say -v "$voice" "$text" -o "/tmp/${filename}.aiff"
    
    if [ $? -eq 0 ]; then
        # Convertir en format compatible Asterisk (8kHz, mono, WAV)
        ffmpeg -y -i "/tmp/${filename}.aiff" -ar 8000 -ac 1 -acodec pcm_s16le "$SOUNDS_DIR/custom/${filename}.wav" 2>/dev/null
        
        if [ $? -eq 0 ]; then
            echo "✓ $filename.wav créé avec succès"
        else
            echo "✗ Erreur lors de la conversion de $filename"
        fi
        
        # Nettoyer le fichier temporaire
        rm -f "/tmp/${filename}.aiff"
    else
        echo "✗ Erreur lors de la génération de $filename"
    fi
}

# Messages du SVI en français
generate_audio "welcome" "Bienvenue sur le serveur vocal de Doria V2."

generate_audio "menu-main" "Pour le service commercial, tapez 1. Pour le support technique, tapez 2. Pour la conférence, tapez 3. Pour l'opérateur, tapez 0."

generate_audio "commercial" "Transfert vers le service commercial."

generate_audio "support" "Transfert vers le support technique."

generate_audio "conference" "Connexion à la salle de conférence."

generate_audio "operator" "Transfert vers l'opérateur."

generate_audio "invalid" "Option non valide."

generate_audio "timeout" "Retour au menu principal."

echo ""
echo "Génération terminée ! Fichiers créés dans $SOUNDS_DIR/custom/"
echo "Pour tester le SVI, appelez l'extension 9999 depuis Linphone."
