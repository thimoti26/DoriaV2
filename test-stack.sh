#!/bin/bash

# Script de test complet pour la stack DoriaV2
# Teste Docker, MySQL, Redis, Asterisk, Apache et les connexions entre services

set +e  # Continue même en cas d'erreur pour les tests individuels

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables
PROJECT_NAME="doriav2"
CONTAINERS=("${PROJECT_NAME}-mysql" "${PROJECT_NAME}-redis" "${PROJECT_NAME}-asterisk" "${PROJECT_NAME}-web")

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}  TEST STACK TECHNIQUE DORIAV2  ${NC}"
echo -e "${BLUE}================================${NC}"

# Fonction pour afficher les résultats de test
test_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
        return 1
    fi
}

# Fonction pour tester si un conteneur est en cours d'exécution
test_container_running() {
    local container_name=$1
    docker ps --format "table {{.Names}}" | grep -q "^${container_name}$"
    return $?
}

# Fonction pour tester si un conteneur est healthy
test_container_healthy() {
    local container_name=$1
    # Vérifier d'abord si le conteneur a un health check configuré
    local has_health=$(docker inspect --format='{{if .State.Health}}true{{else}}false{{end}}' "$container_name" 2>/dev/null || echo "false")
    
    if [ "$has_health" = "true" ]; then
        local health_status=$(docker inspect --format='{{.State.Health.Status}}' "$container_name" 2>/dev/null)
        [ "$health_status" = "healthy" ]
    else
        # Pas de health check configuré, on considère OK si le conteneur tourne
        return 0
    fi
}

echo ""
echo -e "${YELLOW}🔍 Test 1: Vérification des conteneurs Docker${NC}"
echo "------------------------------------------------"

all_containers_ok=true
for container in "${CONTAINERS[@]}"; do
    if test_container_running "$container"; then
        test_result 0 "Conteneur $container est démarré"
        
        if test_container_healthy "$container"; then
            # Affichage différent selon le type de health check
            has_health=$(docker inspect --format='{{if .State.Health}}true{{else}}false{{end}}' "$container" 2>/dev/null || echo "false")
            if [ "$has_health" = "false" ]; then
                test_result 0 "Conteneur $container fonctionne (pas de health check)"
            else
                test_result 0 "Conteneur $container est healthy"
            fi
        else
            has_health=$(docker inspect --format='{{if .State.Health}}true{{else}}false{{end}}' "$container" 2>/dev/null || echo "false")
            if [ "$has_health" = "false" ]; then
                test_result 1 "Conteneur $container ne répond pas"
            else
                test_result 1 "Conteneur $container n'est pas healthy"
            fi
            all_containers_ok=false
        fi
    else
        test_result 1 "Conteneur $container n'est pas démarré"
        all_containers_ok=false
    fi
done

if [ "$all_containers_ok" = false ]; then
    echo -e "${RED}❌ Échec du test des conteneurs. Arrêt des tests.${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}🔍 Test 2: Connectivité réseau Docker${NC}"
echo "-------------------------------------"

# Test réseau entre conteneurs
docker exec ${PROJECT_NAME}-web ping -c 1 ${PROJECT_NAME}-mysql > /dev/null 2>&1
test_result $? "Web peut pinguer MySQL"

docker exec ${PROJECT_NAME}-web ping -c 1 ${PROJECT_NAME}-redis > /dev/null 2>&1
test_result $? "Web peut pinguer Redis"

docker exec ${PROJECT_NAME}-asterisk ping -c 1 ${PROJECT_NAME}-mysql > /dev/null 2>&1
test_result $? "Asterisk peut pinguer MySQL"

echo ""
echo -e "${YELLOW}🔍 Test 3: Services de base de données${NC}"
echo "---------------------------------------"

# Test MySQL
mysql_test=$(docker exec ${PROJECT_NAME}-mysql mysql -u doriav2_user -pdoriav2_password -e "SELECT 1;" doriav2 2>/dev/null)
test_result $? "Connexion MySQL avec utilisateur doriav2_user"

# Test table utilisateurs
table_test=$(docker exec ${PROJECT_NAME}-mysql mysql -u doriav2_user -pdoriav2_password -e "SHOW TABLES LIKE 'users';" doriav2 2>/dev/null | grep -q users)
test_result $? "Table 'users' existe dans la base doriav2"

# Test Redis
redis_test=$(docker exec ${PROJECT_NAME}-redis redis-cli ping 2>/dev/null | grep -q PONG)
test_result $? "Service Redis répond au ping"

echo ""
echo -e "${YELLOW}🔍 Test 4: Configuration Asterisk${NC}"
echo "----------------------------------"

# Test Asterisk version
asterisk_version=$(docker exec ${PROJECT_NAME}-asterisk asterisk -rx "core show version" 2>/dev/null | head -1)
test_result $? "Asterisk répond aux commandes CLI"
echo -e "${BLUE}   Version: $asterisk_version${NC}"

# Test ODBC
odbc_test=$(docker exec ${PROJECT_NAME}-asterisk asterisk -rx "odbc show all" 2>/dev/null | grep -q "mysql")
test_result $? "Configuration ODBC MySQL active"

# Test endpoints PJSIP
endpoints_test=$(docker exec ${PROJECT_NAME}-asterisk asterisk -rx "pjsip show endpoints" 2>/dev/null | grep -q "1001")
test_result $? "Endpoints PJSIP configurés (utilisateur 1001 trouvé)"

# Test dialplan
dialplan_test=$(docker exec ${PROJECT_NAME}-asterisk asterisk -rx "dialplan show from-internal" 2>/dev/null | grep -q "*43")
test_result $? "Extension test d'écho (*43) configurée"

echo ""
echo -e "${YELLOW}🔍 Test 5: Service Web Apache${NC}"
echo "-------------------------------"

# Test Apache
apache_test=$(docker exec ${PROJECT_NAME}-web apache2ctl status 2>/dev/null)
test_result $? "Service Apache actif"

# Test accès web local
web_response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 2>/dev/null || echo "000")
if [ "$web_response" = "200" ]; then
    test_result 0 "Interface web accessible (HTTP 200)"
else
    test_result 1 "Interface web non accessible (HTTP $web_response)"
fi

# Test fichiers PHP
if docker exec ${PROJECT_NAME}-web test -f /var/www/html/index.php; then
    test_result 0 "Fichier index.php présent"
else
    test_result 1 "Fichier index.php manquant"
fi

echo ""
echo -e "${YELLOW}🔍 Test 6: Connectivité Asterisk SIP${NC}"
echo "-------------------------------------"

# Test port SIP
sip_port=$(netstat -tuln 2>/dev/null | grep ":5060" | wc -l || echo "0")
if [ "$sip_port" -gt 0 ]; then
    test_result 0 "Port SIP 5060 ouvert"
else
    test_result 1 "Port SIP 5060 non accessible"
fi

# Test ports RTP
rtp_ports=$(netstat -tuln 2>/dev/null | grep -E ":1000[0-9]" | wc -l || echo "0")
if [ "$rtp_ports" -gt 0 ]; then
    test_result 0 "Ports RTP (10000-10100) ouverts"
else
    test_result 1 "Ports RTP non accessibles"
fi

echo ""
echo -e "${YELLOW}🔍 Test 7: Configuration réseau et NAT${NC}"
echo "---------------------------------------"

# Test configuration NAT dans PJSIP
nat_config=$(docker exec ${PROJECT_NAME}-asterisk grep -q "external_media_address=doriav2-asterisk" /etc/asterisk/pjsip.conf && echo "ok" || echo "error")
test_result $([ "$nat_config" = "ok" ] && echo 0 || echo 1) "Configuration NAT externe correcte"

# Test local_net
local_net_config=$(docker exec ${PROJECT_NAME}-asterisk grep -q "local_net=doriav2_network" /etc/asterisk/pjsip.conf && echo "ok" || echo "error")
test_result $([ "$local_net_config" = "ok" ] && echo 0 || echo 1) "Configuration réseau local correcte"

echo ""
echo -e "${YELLOW}📊 Résumé de la configuration${NC}"
echo "-----------------------------"

# Affichage des informations de configuration pour Linphone
echo -e "${BLUE}Configuration Linphone:${NC}"
echo "  Serveur SIP: localhost:5060"
echo "  Utilisateurs disponibles:"
echo "    - 1001 / mot de passe: linphone1001"
echo "    - 1002 / mot de passe: linphone1002" 
echo "    - 1003 / mot de passe: linphone1003"
echo "    - 1004 / mot de passe: linphone1004"
echo ""
echo -e "${BLUE}Extensions de test:${NC}"
echo "  - *43  : Test d'écho"
echo "  - 100  : Extension de démonstration"
echo "  - 8000 : Salle de conférence"
echo "  - 1001-1004 : Appels entre utilisateurs"

echo ""
echo -e "${BLUE}Services exposés:${NC}"
echo "  - Interface web: http://localhost:8080"
echo "  - MySQL: localhost:3306"
echo "  - Redis: localhost:6379"
echo "  - Asterisk SIP: localhost:5060"
echo "  - Asterisk Manager: localhost:5038"

echo ""
echo -e "${GREEN}🎉 Tests terminés!${NC}"
echo -e "${BLUE}================================${NC}"
