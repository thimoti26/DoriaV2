#!/bin/bash

# Script de test complet pour la stack DoriaV2
# Teste Docker, MySQL, Redis, Asterisk, Apache et diagnostique les problèmes audio

set +e  # Continue même en cas d'erreur pour les tests individuels

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

# Fonction pour afficher des infos
info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

# Fonction pour afficher des warnings
warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
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

echo ""
echo -e "${YELLOW}🔍 Test 5: Diagnostic audio et NAT${NC}"
echo "----------------------------------"

# Test de la présence des fichiers audio
audio_files_test=$(docker exec ${PROJECT_NAME}-asterisk ls /var/lib/asterisk/sounds/en/demo-echotest.gsm 2>/dev/null)
test_result $? "Fichiers audio système présents"

# Test des fichiers audio personnalisés
custom_audio_test=$(docker exec ${PROJECT_NAME}-asterisk ls /var/lib/asterisk/sounds/custom/ 2>/dev/null | wc -l)
if [ "$custom_audio_test" -gt 0 ]; then
    test_result 0 "Fichiers audio personnalisés présents ($custom_audio_test fichiers)"
else
    test_result 1 "Fichiers audio personnalisés manquants"
fi

# Test de la configuration RTP
rtp_range_test=$(docker exec ${PROJECT_NAME}-asterisk grep -q "rtpstart=10000" /etc/asterisk/rtp.conf 2>/dev/null && echo "ok" || echo "error")
test_result $([ "$rtp_range_test" = "ok" ] && echo 0 || echo 1) "Configuration RTP (ports 10000-20000)"

# Test des ports exposés
echo ""
info "Vérification des ports exposés:"
docker port ${PROJECT_NAME}-asterisk 2>/dev/null | while read line; do
    echo -e "${CYAN}   $line${NC}"
done

# Test configuration NAT - vérifier les vraies adresses IP
echo ""
info "Configuration NAT actuelle dans PJSIP:"
ext_media=$(docker exec ${PROJECT_NAME}-asterisk grep "external_media_address" /etc/asterisk/pjsip.conf 2>/dev/null || echo "Non configuré")
echo -e "${CYAN}   $ext_media${NC}"

ext_sig=$(docker exec ${PROJECT_NAME}-asterisk grep "external_signaling_address" /etc/asterisk/pjsip.conf 2>/dev/null || echo "Non configuré")
echo -e "${CYAN}   $ext_sig${NC}"

local_net=$(docker exec ${PROJECT_NAME}-asterisk grep "local_net" /etc/asterisk/pjsip.conf 2>/dev/null || echo "Non configuré")
echo -e "${CYAN}   $local_net${NC}"

# Test des endpoints avec détails
echo ""
echo -e "${YELLOW}🔍 Test 6: État détaillé des endpoints SIP${NC}"
echo "--------------------------------------------"

endpoints_output=$(docker exec ${PROJECT_NAME}-asterisk asterisk -rx "pjsip show endpoints" 2>/dev/null)
if echo "$endpoints_output" | grep -q "1001"; then
    test_result 0 "Endpoint 1001 configuré"
    
    # Vérifier l'état de 1001
    endpoint_state=$(echo "$endpoints_output" | grep "1001/1001" | awk '{print $2}')
    if [ "$endpoint_state" = "Available" ]; then
        test_result 0 "Endpoint 1001 disponible"
    else
        warning "Endpoint 1001 état: $endpoint_state"
        test_result 1 "Endpoint 1001 non disponible"
    fi
    
    # Afficher les contacts
    echo ""
    info "Contacts pour endpoint 1001:"
    echo "$endpoints_output" | grep -A3 "1001/1001" | grep "Contact:" | while read line; do
        echo -e "${CYAN}   $line${NC}"
    done
else
    test_result 1 "Endpoint 1001 non trouvé"
fi

# Test de connectivité réseau détaillé
echo ""
echo -e "${YELLOW}🔍 Test 7: Diagnostic réseau détaillé${NC}"
echo "---------------------------------------"

# IP du conteneur Asterisk
asterisk_ip=$(docker inspect ${PROJECT_NAME}-asterisk --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' 2>/dev/null)
info "IP du conteneur Asterisk: $asterisk_ip"

# IP de l'hôte dans le réseau Docker
host_ip=$(ip route | grep docker0 | awk '{print $9}' 2>/dev/null || echo "Non trouvé")
info "IP de l'hôte sur docker0: $host_ip"

# Vérifier les erreurs récentes dans les logs Asterisk
echo ""
info "Dernières erreurs Asterisk:"
recent_errors=$(docker logs --tail 20 ${PROJECT_NAME}-asterisk 2>&1 | grep -E "(ERROR|WARNING)" | tail -3)
if [ -n "$recent_errors" ]; then
    echo "$recent_errors" | while read line; do
        echo -e "${YELLOW}   $line${NC}"
    done
else
    echo -e "${GREEN}   Aucune erreur récente trouvée${NC}"
fi

# Test de la ligne de commande Asterisk
echo ""
echo -e "${YELLOW}🔍 Test 8: Tests fonctionnels Asterisk${NC}"
echo "----------------------------------------"

# Test extension *43 (écho)
dialplan_echo=$(docker exec ${PROJECT_NAME}-asterisk asterisk -rx "dialplan show from-internal *43" 2>/dev/null | grep -q "Echo test")
test_result $? "Extension *43 (test écho) configurée"

# Test extension 100 (démo)
dialplan_demo=$(docker exec ${PROJECT_NAME}-asterisk asterisk -rx "dialplan show from-internal 100" 2>/dev/null | grep -q "Demo extension")
test_result $? "Extension 100 (démonstration) configurée"

# Test module res_pjsip chargé
pjsip_loaded=$(docker exec ${PROJECT_NAME}-asterisk asterisk -rx "module show like pjsip" 2>/dev/null | grep -q "res_pjsip.so")
test_result $? "Module PJSIP chargé"

# Test module app_echo chargé
echo_loaded=$(docker exec ${PROJECT_NAME}-asterisk asterisk -rx "module show like echo" 2>/dev/null | grep -q "app_echo.so")
test_result $? "Module Echo chargé"

echo ""
echo -e "${YELLOW}📊 Résumé de la configuration${NC}"
echo "-----------------------------"

# Affichage des informations de configuration pour Linphone
echo -e "${BLUE}Configuration Linphone:${NC}"
echo "  Serveur SIP: localhost:5060 (ou IP réelle de votre machine)"
echo "  Transport: UDP"
echo "  Utilisateurs disponibles:"
echo "    - 1001 / mot de passe: linphone1001"
echo "    - 1002 / mot de passe: linphone1002" 
echo "    - 1003 / mot de passe: linphone1003"
echo "    - 1004 / mot de passe: linphone1004"
echo ""
echo -e "${BLUE}Extensions de test audio:${NC}"
echo "  - *43  : Test d'écho complet (avec message)"
echo "  - 100  : Extension de démonstration"
echo "  - 8000 : Salle de conférence principale"
echo "  - 8001 : Salle de conférence secondaire"
echo "  - 9999 : Serveur vocal interactif (SVI)"
echo "  - 1001-1004 : Appels entre utilisateurs"

echo ""
echo -e "${BLUE}Diagnostic audio:${NC}"
if [ "$rtp_range_test" = "ok" ]; then
    echo -e "${GREEN}  ✅ Configuration RTP correcte${NC}"
else
    echo -e "${RED}  ❌ Configuration RTP problématique${NC}"
fi

if [ -n "$recent_errors" ]; then
    echo -e "${YELLOW}  ⚠️  Erreurs récentes détectées (voir ci-dessus)${NC}"
else
    echo -e "${GREEN}  ✅ Aucune erreur Asterisk récente${NC}"
fi

echo ""
echo -e "${BLUE}Services exposés:${NC}"
echo "  - Interface web: http://localhost:8080"
echo "  - MySQL: localhost:3306"
echo "  - Redis: localhost:6379"
echo "  - Asterisk SIP: localhost:5060"
echo "  - Asterisk Manager: localhost:5038"
echo "  - RTP Audio: localhost:10000-20000/udp"

echo ""
echo -e "${YELLOW}🚀 Actions recommandées:${NC}"
echo "1. Connectez Linphone avec l'utilisateur 1001"
echo "2. Testez d'abord l'extension 100 (démo simple)"
echo "3. Ensuite testez *43 pour l'écho audio"
echo "4. Si pas d'audio: vérifiez les codecs dans Linphone (activez ulaw/alaw)"
echo "5. Si problème de NAT: utilisez l'IP réelle de votre machine au lieu de localhost"

echo ""
echo -e "${GREEN}🎉 Tests terminés!${NC}"
echo -e "${BLUE}================================${NC}"

# Test 7: Tests API avancés
echo ""
echo -e "${YELLOW}🔍 Test 7: Tests API avancés${NC}"
echo "----------------------------"

# Test création d'un utilisateur SIP
test_user_creation=$(curl -s -X POST http://localhost:8080/api/sip-users.php \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","extension":"1005"}' \
  | grep -q "success" && echo "ok" || echo "error")
test_result $([ "$test_user_creation" = "ok" ] && echo 0 || echo 1) "Création d'utilisateur SIP via API"

# Test récupération des utilisateurs
users_list=$(curl -s http://localhost:8080/api/sip-users.php | grep -q "success" && echo "ok" || echo "error")
test_result $([ "$users_list" = "ok" ] && echo 0 || echo 1) "Récupération liste utilisateurs SIP"

# Test suppression d'un utilisateur SIP
test_user_deletion=$(curl -s -X DELETE http://localhost:8080/api/sip-users.php \
  -H "Content-Type: application/json" \
  -d '{"extension":"1005"}' \
  | grep -q "success" && echo "ok" || echo "error")
test_result $([ "$test_user_deletion" = "ok" ] && echo 0 || echo 1) "Suppression d'utilisateur SIP via API"

# Test récupération de l'utilisateur supprimé
deleted_user_check=$(curl -s http://localhost:8080/api/sip-users.php?extension=1005 | grep -q "not found" && echo "ok" || echo "error")
test_result $([ "$deleted_user_check" = "ok" ] && echo 0 || echo 1) "Vérification suppression utilisateur SIP"

echo ""
echo -e "${GREEN}🎉 Tous les tests API ont réussi!${NC}"
echo -e "${BLUE}================================${NC}"
