#!/bin/bash

# Script de mise à jour DoriaV2 avec nouveaux points de montage
# Sauvegarde les configurations actuelles et applique les nouveaux volumes

echo "🔄 MISE À JOUR DORIAV2 - NOUVEAUX POINTS DE MONTAGE"
echo "==================================================="

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Vérifier que les fichiers de configuration existent
echo -e "${BLUE}🔍 Vérification des fichiers de configuration...${NC}"

config_files=(
    "./asterisk/config/extensions.conf"
    "./asterisk/config/pjsip.conf"
    "./asterisk/config/modules.conf"
    "./asterisk/config/asterisk.conf"
    "./asterisk/config/rtp.conf"
    "./asterisk/config/manager.conf"
    "./mysql/my.cnf"
)

missing_files=()
for file in "${config_files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✅ $file${NC}"
    else
        echo -e "${RED}❌ $file manquant${NC}"
        missing_files+=("$file")
    fi
done

# Si des fichiers manquent, les récupérer du conteneur
if [ ${#missing_files[@]} -gt 0 ]; then
    echo -e "\n${YELLOW}⚠️  Fichiers manquants détectés. Récupération depuis les conteneurs...${NC}"
    
    # Créer les répertoires si nécessaire
    mkdir -p ./asterisk/config
    mkdir -p ./mysql
    
    # Récupérer les configurations Asterisk depuis le conteneur
    if docker ps --format "table {{.Names}}" | grep -q "doriav2-asterisk"; then
        echo "   Récupération configurations Asterisk..."
        for config in extensions.conf pjsip.conf modules.conf asterisk.conf rtp.conf manager.conf res_odbc.conf cdr_odbc.conf extconfig.conf; do
            if docker exec doriav2-asterisk test -f "/etc/asterisk/$config" 2>/dev/null; then
                docker cp "doriav2-asterisk:/etc/asterisk/$config" "./asterisk/config/$config"
                echo -e "   ${GREEN}✅ $config récupéré${NC}"
            fi
        done
        
        # Récupérer odbc.ini
        if docker exec doriav2-asterisk test -f "/etc/odbc.ini" 2>/dev/null; then
            docker cp "doriav2-asterisk:/etc/odbc.ini" "./asterisk/config/odbc.ini"
            echo -e "   ${GREEN}✅ odbc.ini récupéré${NC}"
        fi
    fi
    
    # Récupérer la configuration MySQL
    if docker ps --format "table {{.Names}}" | grep -q "doriav2-mysql"; then
        echo "   Récupération configuration MySQL..."
        if docker exec doriav2-mysql test -f "/etc/mysql/my.cnf" 2>/dev/null; then
            docker cp "doriav2-mysql:/etc/mysql/my.cnf" "./mysql/my.cnf"
            echo -e "   ${GREEN}✅ my.cnf récupéré${NC}"
        fi
    fi
fi

# Créer un backup des configurations actuelles
backup_dir="./backup-configs-$(date +%Y%m%d-%H%M%S)"
echo -e "\n${BLUE}💾 Création d'un backup dans $backup_dir...${NC}"
mkdir -p "$backup_dir"

if docker ps --format "table {{.Names}}" | grep -q "doriav2-asterisk"; then
    docker exec doriav2-asterisk tar czf /tmp/asterisk-config-backup.tar.gz /etc/asterisk/
    docker cp "doriav2-asterisk:/tmp/asterisk-config-backup.tar.gz" "$backup_dir/"
    echo -e "${GREEN}✅ Backup Asterisk créé${NC}"
fi

# Afficher les changements qui vont être appliqués
echo -e "\n${BLUE}📋 NOUVEAUX POINTS DE MONTAGE QUI SERONT APPLIQUÉS:${NC}"
echo ""
echo "Asterisk:"
echo "  ./asterisk/config/extensions.conf   → /etc/asterisk/extensions.conf"
echo "  ./asterisk/config/pjsip.conf        → /etc/asterisk/pjsip.conf"
echo "  ./asterisk/config/modules.conf      → /etc/asterisk/modules.conf"
echo "  ./asterisk/config/asterisk.conf     → /etc/asterisk/asterisk.conf"
echo "  ./asterisk/config/rtp.conf          → /etc/asterisk/rtp.conf"
echo "  ./asterisk/config/manager.conf      → /etc/asterisk/manager.conf"
echo "  ./asterisk/config/res_odbc.conf     → /etc/asterisk/res_odbc.conf"
echo "  ./asterisk/config/cdr_odbc.conf     → /etc/asterisk/cdr_odbc.conf"
echo "  ./asterisk/config/extconfig.conf    → /etc/asterisk/extconfig.conf"
echo "  ./asterisk/config/odbc.ini          → /etc/odbc.ini"
echo "  ./asterisk/sounds/custom/           → /var/lib/asterisk/sounds/custom/"
echo ""
echo "MySQL:"
echo "  ./mysql/my.cnf                      → /etc/mysql/conf.d/custom.cnf"
echo ""
echo "Web:"
echo "  ./src/                              → /var/www/html/ (déjà configuré)"
echo ""

# Demander confirmation
echo -e "${YELLOW}⚠️  Cette opération va redémarrer les conteneurs pour appliquer les nouveaux volumes.${NC}"
echo -e "${YELLOW}   Les données persistantes seront préservées.${NC}"
echo ""
read -p "Continuer ? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}❌ Opération annulée${NC}"
    exit 1
fi

# Arrêter les conteneurs
echo -e "\n${BLUE}🛑 Arrêt des conteneurs...${NC}"
docker-compose down

# Redémarrer avec les nouveaux volumes
echo -e "\n${BLUE}🚀 Redémarrage avec les nouveaux points de montage...${NC}"
docker-compose up -d

# Attendre que les services soient prêts
echo -e "\n${BLUE}⏳ Attente du démarrage des services...${NC}"
sleep 10

# Vérifier l'état des conteneurs
echo -e "\n${BLUE}🔍 Vérification de l'état des conteneurs...${NC}"
docker-compose ps

# Tester les configurations
echo -e "\n${BLUE}🧪 Test des configurations...${NC}"

# Test Asterisk
if docker exec doriav2-asterisk asterisk -rx "core show version" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Asterisk opérationnel${NC}"
    
    # Test du dialplan
    if docker exec doriav2-asterisk asterisk -rx "dialplan show from-internal" | grep -q "extension"; then
        echo -e "${GREEN}✅ Dialplan chargé depuis le fichier monté${NC}"
    else
        echo -e "${RED}❌ Problème avec le dialplan${NC}"
    fi
else
    echo -e "${RED}❌ Asterisk non opérationnel${NC}"
fi

# Test MySQL
if docker exec doriav2-mysql mysqladmin ping -h localhost -u root -pdoriav2_root_password > /dev/null 2>&1; then
    echo -e "${GREEN}✅ MySQL opérationnel${NC}"
else
    echo -e "${RED}❌ MySQL non opérationnel${NC}"
fi

# Test Web
if curl -s http://localhost:8080 > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Interface web accessible${NC}"
else
    echo -e "${RED}❌ Interface web non accessible${NC}"
fi

echo -e "\n${GREEN}🎉 MISE À JOUR TERMINÉE !${NC}"
echo ""
echo -e "${BLUE}📋 NOUVELLES POSSIBILITÉS:${NC}"
echo ""
echo "1. Modifier les configurations directement dans les fichiers locaux:"
echo "   • ./asterisk/config/extensions.conf"
echo "   • ./asterisk/config/pjsip.conf"
echo "   • ./mysql/my.cnf"
echo "   • etc."
echo ""
echo "2. Recharger les configurations sans redémarrer:"
echo "   ./reload-config.sh"
echo ""
echo "3. Tester après modifications:"
echo "   ./test-stack.sh"
echo ""
echo -e "${BLUE}💡 Astuce:${NC} Les modifications sont maintenant immédiates !"
echo "   Plus besoin de reconstruire les conteneurs pour changer la config."

if [ -d "$backup_dir" ]; then
    echo ""
    echo -e "${BLUE}💾 Backup sauvegardé dans:${NC} $backup_dir"
fi
