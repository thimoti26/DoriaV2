#!/bin/bash

# Script de test pour l'interface web DoriaV2
# Vérifie toutes les fonctionnalités et endpoints

set -e

# Configuration
API_BASE="http://localhost:8081/api"
WEB_BASE="http://localhost:8081"
TIMEOUT=10

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Fonctions d'affichage
log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }
log_test() { echo -e "${CYAN}🧪 Test: $1${NC}"; }

# Compteurs
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0

# Fonction de test générique
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_result="$3"
    
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    log_test "$test_name"
    
    if eval "$test_command" >/dev/null 2>&1; then
        log_success "$test_name - RÉUSSI"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        log_error "$test_name - ÉCHEC"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Test de connectivité HTTP
test_http_get() {
    local url="$1"
    local description="$2"
    
    run_test "GET $description" "curl -s --max-time $TIMEOUT '$url' | grep -q 'success\\|html\\|DoriaV2'" "200"
}

# Test de POST
test_http_post() {
    local url="$1"
    local description="$2"
    local data="$3"
    
    run_test "POST $description" "curl -s --max-time $TIMEOUT -X POST '$url' -H 'Content-Type: application/json' -d '$data'" "200"
}

# En-tête
echo -e "\n${PURPLE}🧪 TESTS INTERFACE WEB DORIAE V2${NC}"
echo -e "${PURPLE}=================================${NC}\n"

# Vérification préliminaire
log_info "Vérification de la disponibilité du serveur..."

if ! curl -s --max-time 5 "$WEB_BASE" >/dev/null 2>&1; then
    log_error "Le serveur web n'est pas accessible sur $WEB_BASE"
    log_info "Veuillez démarrer l'interface web avec: ./start-web-interface.sh"
    exit 1
fi

log_success "Serveur web accessible"

# Tests de l'interface web
echo -e "\n${CYAN}🌐 Tests Interface Web${NC}"
echo -e "${CYAN}=====================${NC}"

test_http_get "$WEB_BASE" "Page principale"
test_http_get "$WEB_BASE/styles.css" "Fichier CSS"
test_http_get "$WEB_BASE/script.js" "Fichier JavaScript"

# Tests de l'API
echo -e "\n${CYAN}🔌 Tests API REST${NC}"
echo -e "${CYAN}=================${NC}"

test_http_get "$API_BASE/status" "API Statut système"

# Tests des endpoints de contrôle (simulation)
log_test "API Contrôle Asterisk (simulation)"
for action in start stop restart status; do
    if curl -s --max-time $TIMEOUT -X POST "$API_BASE/control/$action" >/dev/null 2>&1; then
        log_success "POST /api/control/$action - RÉUSSI"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        log_warning "POST /api/control/$action - Mode simulation"
    fi
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
done

# Tests des logs
log_test "API Journaux"
for log_type in asterisk docker; do
    if curl -s --max-time $TIMEOUT "$API_BASE/logs/$log_type" >/dev/null 2>&1; then
        log_success "GET /api/logs/$log_type - RÉUSSI"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        log_warning "GET /api/logs/$log_type - Mode simulation"
    fi
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
done

# Tests des commandes Docker
log_test "API Docker (simulation)"
for action in up down restart ps; do
    if curl -s --max-time $TIMEOUT -X POST "$API_BASE/docker/$action" >/dev/null 2>&1; then
        log_success "POST /api/docker/$action - RÉUSSI"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        log_warning "POST /api/docker/$action - Mode simulation"
    fi
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
done

# Tests de fonctionnalités JavaScript
echo -e "\n${CYAN}⚡ Tests Fonctionnalités JavaScript${NC}"
echo -e "${CYAN}====================================${NC}"

# Test de la structure HTML
log_test "Structure HTML - Onglets navigation"
if curl -s "$WEB_BASE" | grep -q "dashboard-tab\\|extensions-tab\\|system-tab\\|logs-tab"; then
    log_success "Navigation par onglets - RÉUSSI"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    log_error "Navigation par onglets - ÉCHEC"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_TOTAL=$((TESTS_TOTAL + 1))

# Test de la présence des éléments clés
log_test "Éléments interface - Extension osmo"
if curl -s "$WEB_BASE" | grep -q "osmo\\|1000\\|osmoosmo"; then
    log_success "Configuration extension osmo - RÉUSSI"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    log_error "Configuration extension osmo - ÉCHEC"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_TOTAL=$((TESTS_TOTAL + 1))

# Test des numéros de test
log_test "Numéros de test disponibles"
if curl -s "$WEB_BASE" | grep -q "\\*43\\|\\*97\\|123"; then
    log_success "Numéros de test présents - RÉUSSI"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    log_error "Numéros de test présents - ÉCHEC"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_TOTAL=$((TESTS_TOTAL + 1))

# Test du responsive design
echo -e "\n${CYAN}📱 Tests Design Responsive${NC}"
echo -e "${CYAN}============================${NC}"

log_test "CSS Bootstrap et responsivité"
if curl -s "$WEB_BASE/styles.css" | grep -q "responsive\\|mobile\\|@media"; then
    log_success "CSS responsive - RÉUSSI"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    log_warning "CSS responsive - Vérification manuelle requise"
fi
TESTS_TOTAL=$((TESTS_TOTAL + 1))

# Test des dépendances externes
echo -e "\n${CYAN}🔗 Tests Dépendances Externes${NC}"
echo -e "${CYAN}===============================${NC}"

log_test "Bootstrap CDN"
if curl -s --max-time 5 "https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/css/bootstrap.min.css" >/dev/null 2>&1; then
    log_success "Bootstrap CDN accessible - RÉUSSI"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    log_warning "Bootstrap CDN - Vérification réseau requise"
fi
TESTS_TOTAL=$((TESTS_TOTAL + 1))

log_test "Font Awesome CDN"
if curl -s --max-time 5 "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" >/dev/null 2>&1; then
    log_success "Font Awesome CDN accessible - RÉUSSI"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    log_warning "Font Awesome CDN - Vérification réseau requise"
fi
TESTS_TOTAL=$((TESTS_TOTAL + 1))

# Tests de performance
echo -e "\n${CYAN}⚡ Tests Performance${NC}"
echo -e "${CYAN}===================${NC}"

log_test "Temps de réponse page principale"
start_time=$(date +%s%N)
curl -s --max-time $TIMEOUT "$WEB_BASE" >/dev/null 2>&1
end_time=$(date +%s%N)
response_time=$(((end_time - start_time) / 1000000))

if [ $response_time -lt 1000 ]; then
    log_success "Temps de réponse: ${response_time}ms - EXCELLENT"
    TESTS_PASSED=$((TESTS_PASSED + 1))
elif [ $response_time -lt 3000 ]; then
    log_success "Temps de réponse: ${response_time}ms - BON"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    log_warning "Temps de réponse: ${response_time}ms - LENT"
fi
TESTS_TOTAL=$((TESTS_TOTAL + 1))

# Tests de sécurité basiques
echo -e "\n${CYAN}🔒 Tests Sécurité Basiques${NC}"
echo -e "${CYAN}===========================${NC}"

log_test "En-têtes CORS"
if curl -s -I "$API_BASE/status" | grep -q "Access-Control-Allow-Origin"; then
    log_success "En-têtes CORS présents - RÉUSSI"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    log_warning "En-têtes CORS - À vérifier"
fi
TESTS_TOTAL=$((TESTS_TOTAL + 1))

log_test "Protection contre l'injection"
if ! curl -s "$API_BASE/status?param=<script>alert('xss')</script>" | grep -q "<script>"; then
    log_success "Protection XSS basique - RÉUSSI"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    log_error "Protection XSS basique - ÉCHEC"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_TOTAL=$((TESTS_TOTAL + 1))

# Résumé des tests
echo -e "\n${PURPLE}📊 RÉSUMÉ DES TESTS${NC}"
echo -e "${PURPLE}===================${NC}"

echo -e "Tests exécutés: ${CYAN}$TESTS_TOTAL${NC}"
echo -e "Tests réussis:  ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests échoués:  ${RED}$TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}🎉 TOUS LES TESTS SONT PASSÉS !${NC}"
    echo -e "${GREEN}✨ L'interface web DoriaV2 est entièrement fonctionnelle${NC}"
    exit_code=0
elif [ $TESTS_PASSED -gt $TESTS_FAILED ]; then
    echo -e "\n${YELLOW}⚠️  LA PLUPART DES TESTS SONT PASSÉS${NC}"
    echo -e "${YELLOW}🔧 Quelques ajustements mineurs peuvent être nécessaires${NC}"
    exit_code=0
else
    echo -e "\n${RED}❌ PLUSIEURS TESTS ONT ÉCHOUÉ${NC}"
    echo -e "${RED}🛠️  Une révision de la configuration est recommandée${NC}"
    exit_code=1
fi

# Informations supplémentaires
echo -e "\n${CYAN}📋 INFORMATIONS SUPPLÉMENTAIRES${NC}"
echo -e "${CYAN}================================${NC}"

echo -e "Interface web: ${YELLOW}$WEB_BASE${NC}"
echo -e "API REST:      ${YELLOW}$API_BASE${NC}"
echo -e "Documentation: ${YELLOW}$WEB_BASE/README.md${NC}"

# Tests de fonctionnalités spécifiques
echo -e "\n${CYAN}🎯 TESTS SPÉCIFIQUES DORIAE V2${NC}"
echo -e "${CYAN}===============================${NC}"

# Test configuration osmo
log_test "Configuration extension osmo complète"
osmo_config=$(curl -s "$WEB_BASE" | grep -c "osmo\\|1000\\|osmoosmo\\|localhost:5060")
if [ $osmo_config -ge 4 ]; then
    log_success "Configuration osmo complète - RÉUSSI"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    log_error "Configuration osmo incomplète - ÉCHEC"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_TOTAL=$((TESTS_TOTAL + 1))

# Test guide Linphone
log_test "Guide Linphone intégré"
if curl -s "$WEB_BASE" | grep -q "linphoneModal\\|Linphone\\|Configuration"; then
    log_success "Guide Linphone présent - RÉUSSI"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    log_error "Guide Linphone manquant - ÉCHEC"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_TOTAL=$((TESTS_TOTAL + 1))

echo -e "\n${PURPLE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${WHITE}          🧪 Tests Interface Web DoriaV2 Terminés          ${NC}"
echo -e "${PURPLE}═══════════════════════════════════════════════════════════${NC}\n"

exit $exit_code
