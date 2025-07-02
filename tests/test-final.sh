#!/bin/bash

# Test final de validation DoriaV2
# Usage: ./test-final.sh

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

total_tests=0
passed_tests=0

run_test() {
    local test_name="$1"
    local test_command="$2"
    
    ((total_tests++))
    log_info "Test $total_tests: $test_name"
    
    if eval "$test_command" &>/dev/null; then
        log_success "PASSED"
        ((passed_tests++))
    else
        log_error "FAILED"
    fi
    echo ""
}

echo -e "${BLUE}🎯 VALIDATION FINALE DORIAV2${NC}"
echo "============================"
echo ""

# Tests infrastructure
run_test "Docker Compose disponible" "command -v docker compose"
run_test "Conteneurs en cours" "docker compose ps | grep -q Up"
run_test "Réseau Docker créé" "docker network ls | grep -q doria"

# Tests Asterisk
run_test "Asterisk démarré" "docker compose exec asterisk asterisk -rx 'core show version'"
run_test "PJSIP configuré" "docker compose exec asterisk asterisk -rx 'pjsip show endpoints' | grep -q 1001"
run_test "Extension 9999 (SVI)" "docker compose exec asterisk asterisk -rx 'dialplan show 9999@from-internal' | grep -q 9999"
run_test "Extension test *43" "docker compose exec asterisk asterisk -rx 'dialplan show *43@from-internal' | grep -q '*43'"

# Tests MySQL
run_test "MySQL démarré" "docker compose exec mysql mysql -uroot -proot_password -e 'SELECT 1;'"
run_test "Base DoriaV2 créée" "docker compose exec mysql mysql -uroot -proot_password -e 'USE doriav2;'"

# Tests Web
run_test "Apache démarré" "curl -s http://localhost:8080"
run_test "PHP fonctionnel" "curl -s http://localhost:8080 | grep -q PHP"

# Tests Audio
run_test "Fichiers audio par défaut" "docker compose exec asterisk test -d /var/lib/asterisk/sounds/en"
run_test "Fichiers audio personnalisés" "docker compose exec asterisk test -d /var/lib/asterisk/sounds/custom"
run_test "Fichier welcome.wav" "docker compose exec asterisk test -f /var/lib/asterisk/sounds/custom/welcome.wav"

# Tests Volumes
run_test "Volume asterisk-config" "docker volume ls | grep -q asterisk-config"
run_test "Volume mysql-data" "docker volume ls | grep -q mysql-data"

# Tests Scripts
run_test "Script principal doria.sh" "test -x ../doria.sh"
run_test "Scripts de test" "test -d ../tests && test -f ../tests/README.md"
run_test "Scripts utilitaires" "test -d ../scripts && test -f ../scripts/README.md"

# Tests Documentation
run_test "Documentation présente" "test -d ../docs && test -f ../docs/INDEX.md"
run_test "Architecture documentée" "test -f ../ARCHITECTURE.md"
run_test "README principal" "test -f ../README.md"

# Résultats
echo ""
echo -e "${BLUE}📊 RÉSULTATS DE LA VALIDATION${NC}"
echo "==============================="

if [ $passed_tests -eq $total_tests ]; then
    log_success "🎉 TOUS LES TESTS SONT PASSÉS ! ($passed_tests/$total_tests)"
    echo ""
    echo -e "${GREEN}✨ DoriaV2 est parfaitement configuré et prêt à l'emploi !${NC}"
    echo ""
    echo "🚀 Pour démarrer :"
    echo "   cd .. && ./doria.sh start"
    echo ""
    echo "📞 Extensions disponibles :"
    echo "   1001-1004 : Utilisateurs SIP"
    echo "   9999      : Serveur Vocal Interactif (SVI)"
    echo "   8000      : Salle de conférence"
    echo "   *43,*44   : Tests audio"
else
    echo ""
    log_warning "⚠️  TESTS PARTIELS: $passed_tests/$total_tests réussis"
    
    failed_tests=$((total_tests - passed_tests))
    if [ $failed_tests -le 3 ]; then
        echo ""
        echo -e "${YELLOW}DoriaV2 est fonctionnel mais quelques optimisations sont possibles.${NC}"
        echo "Consultez la documentation pour plus de détails."
    else
        echo ""
        log_error "❌ Plusieurs tests ont échoué. Vérifiez la configuration."
        echo "Consultez les guides de dépannage dans docs/"
    fi
fi

echo ""
echo "📚 Documentation complète : docs/INDEX.md"
echo "🏗️  Architecture détaillée : ARCHITECTURE.md"
