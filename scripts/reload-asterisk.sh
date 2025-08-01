#!/bin/bash

# Script pour recharger la configuration Asterisk
# Utilisé par l'interface web d'administration

# Fonction pour afficher les messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Vérifier si Asterisk est en cours d'exécution
if ! pgrep asterisk > /dev/null; then
    log_message "ERREUR: Asterisk n'est pas en cours d'exécution"
    exit 1
fi

log_message "Rechargement de la configuration Asterisk..."

# Recharger la configuration PJSIP
if asterisk -rx "pjsip reload" > /dev/null 2>&1; then
    log_message "Configuration PJSIP rechargée avec succès"
else
    log_message "ERREUR: Échec du rechargement PJSIP"
    exit 1
fi

# Recharger la configuration des extensions
if asterisk -rx "dialplan reload" > /dev/null 2>&1; then
    log_message "Plan de numérotation rechargé avec succès"
else
    log_message "AVERTISSEMENT: Échec du rechargement du plan de numérotation"
fi

# Afficher le statut des endpoints
log_message "Statut des endpoints après rechargement:"
asterisk -rx "pjsip show endpoints" 2>/dev/null | grep -E "Endpoint:|===" || echo "Aucun endpoint trouvé"

log_message "Rechargement terminé avec succès"
exit 0
