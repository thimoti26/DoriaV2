#!/bin/bash

# Script de nettoyage du projet DoriaV2
# Supprime les éléments superflus et organise la structure

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}  NETTOYAGE PROJET DORIAV2     ${NC}"
echo -e "${BLUE}================================${NC}"

# Fonction pour afficher les actions
action_log() {
    if [ "$2" = "success" ]; then
        echo -e "${GREEN}✅ $1${NC}"
    elif [ "$2" = "warning" ]; then
        echo -e "${YELLOW}⚠️  $1${NC}"
    elif [ "$2" = "info" ]; then
        echo -e "${BLUE}ℹ️  $1${NC}"
    else
        echo -e "${RED}❌ $1${NC}"
    fi
}

echo ""
echo -e "${YELLOW}🧹 Phase 1: Suppression des fichiers temporaires${NC}"
echo "------------------------------------------------"

# Supprimer les fichiers de cache et temporaires
if [ -d ".git" ]; then
    action_log "Dossier .git conservé (contrôle de version)" "info"
else
    action_log "Pas de dossier .git trouvé" "info"
fi

# Nettoyer les logs Docker s'ils existent
if docker system df > /dev/null 2>&1; then
    action_log "Nettoyage des données Docker inutilisées" "info"
    docker system prune -f > /dev/null 2>&1 || true
fi

# Supprimer les fichiers de sauvegarde et temporaires courants
find . -name "*.bak" -type f -delete 2>/dev/null && action_log "Fichiers .bak supprimés" "success" || action_log "Aucun fichier .bak trouvé" "info"
find . -name "*.tmp" -type f -delete 2>/dev/null && action_log "Fichiers .tmp supprimés" "success" || action_log "Aucun fichier .tmp trouvé" "info"
find . -name "*~" -type f -delete 2>/dev/null && action_log "Fichiers ~ supprimés" "success" || action_log "Aucun fichier ~ trouvé" "info"
find . -name ".DS_Store" -type f -delete 2>/dev/null && action_log "Fichiers .DS_Store supprimés" "success" || action_log "Aucun fichier .DS_Store trouvé" "info"

echo ""
echo -e "${YELLOW}🧹 Phase 2: Vérification de la structure du projet${NC}"
echo "------------------------------------------------"

# Vérifier les dossiers essentiels
essential_dirs=("asterisk" "asterisk/config" "asterisk/sounds" "mysql" "src" "src/api")
for dir in "${essential_dirs[@]}"; do
    if [ -d "$dir" ]; then
        action_log "Dossier essentiel '$dir' présent" "success"
    else
        action_log "Dossier essentiel '$dir' manquant!" "error"
    fi
done

# Vérifier les fichiers essentiels
essential_files=(
    "compose.yml"
    "asterisk/Dockerfile"
    "asterisk/config/pjsip.conf"
    "asterisk/config/extensions.conf"
    "asterisk/config/odbc.ini"
    "mysql/Dockerfile"
    "mysql/init.sql"
    "src/index.php"
)

for file in "${essential_files[@]}"; do
    if [ -f "$file" ]; then
        action_log "Fichier essentiel '$file' présent" "success"
    else
        action_log "Fichier essentiel '$file' manquant!" "error"
    fi
done

echo ""
echo -e "${YELLOW}🧹 Phase 3: Optimisation des fichiers de test${NC}"
echo "--------------------------------------------"

# Garder les fichiers de test utiles mais les organiser
if [ -f "src/test_simple.php" ]; then
    # Le test simple est redondant, on peut le supprimer
    rm "src/test_simple.php"
    action_log "Supprimé test_simple.php (redondant)" "success"
fi

# Créer un fichier .dockerignore pour optimiser les builds
if [ ! -f ".dockerignore" ]; then
    cat > .dockerignore << 'EOF'
# Fichiers de développement
.git/
.gitignore
README.md
test-stack.sh
cleanup.sh

# Fichiers temporaires
*.tmp
*.bak
*~
.DS_Store

# Logs
*.log
EOF
    action_log "Créé fichier .dockerignore" "success"
else
    action_log "Fichier .dockerignore déjà présent" "info"
fi

# Créer un fichier .gitignore si nécessaire
if [ ! -f ".gitignore" ]; then
    cat > .gitignore << 'EOF'
# Fichiers temporaires
*.tmp
*.bak
*~
.DS_Store

# Logs
*.log

# Données sensibles
.env

# Volumes Docker (données persistantes)
mysql_data/
redis_data/
EOF
    action_log "Créé fichier .gitignore" "success"
else
    action_log "Fichier .gitignore déjà présent" "info"
fi

echo ""
echo -e "${YELLOW}🧹 Phase 4: Validation de la configuration${NC}"
echo "-------------------------------------------"

# Vérifier que les configurations sont cohérentes
config_errors=0

# Vérifier la configuration ODBC
if grep -q "driver = MariaDB" asterisk/config/odbc.ini; then
    action_log "Configuration ODBC correcte (pilote MariaDB)" "success"
else
    action_log "Configuration ODBC incorrecte" "error"
    config_errors=$((config_errors + 1))
fi

# Vérifier la configuration NAT
if grep -q "external_media_address=doriav2-asterisk" asterisk/config/pjsip.conf; then
    action_log "Configuration NAT correcte (noms de conteneurs)" "success"
else
    action_log "Configuration NAT incorrecte" "error"
    config_errors=$((config_errors + 1))
fi

# Vérifier la base de données MySQL
if grep -q "doriav2" mysql/init.sql; then
    action_log "Configuration MySQL correcte (base doriav2)" "success"
else
    action_log "Configuration MySQL incorrecte" "error"
    config_errors=$((config_errors + 1))
fi

echo ""
echo -e "${YELLOW}📊 Résumé du nettoyage${NC}"
echo "------------------------"

if [ $config_errors -eq 0 ]; then
    action_log "Projet nettoyé et validé avec succès!" "success"
    echo ""
    echo -e "${BLUE}Structure du projet optimisée:${NC}"
    echo "  📁 asterisk/ - Configuration Asterisk PBX"
    echo "  📁 mysql/ - Configuration base de données"
    echo "  📁 src/ - Code source application web"
    echo "  📄 compose.yml - Orchestration Docker"
    echo "  📄 test-stack.sh - Script de test complet"
    echo "  📄 cleanup.sh - Script de nettoyage"
    echo ""
    echo -e "${GREEN}🎉 Le projet est prêt pour la production!${NC}"
else
    action_log "Erreurs de configuration détectées: $config_errors" "error"
    echo -e "${RED}⚠️  Veuillez corriger les erreurs avant de continuer${NC}"
fi

echo -e "${BLUE}================================${NC}"
