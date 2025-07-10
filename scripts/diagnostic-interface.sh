#!/bin/bash

# Script de diagnostic pour l'interface SVI Admin V2
# Identifie les problèmes de fonctionnement

echo "=== DIAGNOSTIC INTERFACE SVI ADMIN V2 ==="
echo "Date: $(date)"
echo

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction d'affichage
print_status() {
    local status=$1
    local message=$2
    if [ "$status" = "OK" ]; then
        echo -e "${GREEN}✓${NC} $message"
    elif [ "$status" = "WARN" ]; then
        echo -e "${YELLOW}⚠${NC} $message"
    elif [ "$status" = "ERROR" ]; then
        echo -e "${RED}✗${NC} $message"
    else
        echo -e "${BLUE}ℹ${NC} $message"
    fi
}

# Test de base
BASE_URL="http://localhost:8080"
INTERFACE_URL="$BASE_URL/svi-admin/index-v2.php"

echo -e "${BLUE}=== 1. TESTS DE BASE ===${NC}"

# Test d'accès à l'interface
response=$(curl -s -o /dev/null -w "%{http_code}" "$INTERFACE_URL")
if [ "$response" = "200" ]; then
    print_status "OK" "Interface accessible (HTTP $response)"
else
    print_status "ERROR" "Interface non accessible (HTTP $response)"
fi

# Test des ressources
echo -e "\n${BLUE}=== 2. TESTS DES RESSOURCES ===${NC}"

# Test CSS
css_response=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/svi-admin/css/svi-admin.css")
if [ "$css_response" = "200" ]; then
    print_status "OK" "CSS accessible"
else
    print_status "ERROR" "CSS non accessible (HTTP $css_response)"
fi

# Test JavaScript
js_response=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/svi-admin/js/svi-editor-v2.js")
if [ "$js_response" = "200" ]; then
    print_status "OK" "JavaScript accessible"
else
    print_status "ERROR" "JavaScript non accessible (HTTP $js_response)"
fi

# Test des librairies externes
echo -e "\n${BLUE}=== 3. TESTS DES LIBRAIRIES EXTERNES ===${NC}"

# Test Sortable.js
sortable_test=$(curl -s -o /dev/null -w "%{http_code}" "https://cdn.jsdelivr.net/npm/sortablejs@1.15.0/Sortable.min.js")
if [ "$sortable_test" = "200" ]; then
    print_status "OK" "Sortable.js accessible"
else
    print_status "ERROR" "Sortable.js non accessible"
fi

# Test Toastify
toastify_test=$(curl -s -o /dev/null -w "%{http_code}" "https://cdn.jsdelivr.net/npm/toastify-js")
if [ "$toastify_test" = "200" ]; then
    print_status "OK" "Toastify accessible"
else
    print_status "ERROR" "Toastify non accessible"
fi

# Test Particles.js
particles_test=$(curl -s -o /dev/null -w "%{http_code}" "https://cdn.jsdelivr.net/npm/particles.js@2.0.0/particles.min.js")
if [ "$particles_test" = "200" ]; then
    print_status "OK" "Particles.js accessible"
else
    print_status "ERROR" "Particles.js non accessible"
fi

# Test Font Awesome
fa_test=$(curl -s -o /dev/null -w "%{http_code}" "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css")
if [ "$fa_test" = "200" ]; then
    print_status "OK" "Font Awesome accessible"
else
    print_status "ERROR" "Font Awesome non accessible"
fi

# Test de la structure HTML
echo -e "\n${BLUE}=== 4. TESTS DE LA STRUCTURE HTML ===${NC}"

html_content=$(curl -s "$INTERFACE_URL")

# Vérification des éléments essentiels
if echo "$html_content" | grep -q 'id="particles-js"'; then
    print_status "OK" "Div particles-js présent"
else
    print_status "ERROR" "Div particles-js manquant"
fi

if echo "$html_content" | grep -q 'class="toolbox"'; then
    print_status "OK" "Toolbox présente"
else
    print_status "ERROR" "Toolbox manquante"
fi

if echo "$html_content" | grep -q 'class="canvas-area"'; then
    print_status "OK" "Canvas area présent"
else
    print_status "ERROR" "Canvas area manquant"
fi

if echo "$html_content" | grep -q 'class="properties-panel"'; then
    print_status "OK" "Properties panel présent"
else
    print_status "ERROR" "Properties panel manquant"
fi

if echo "$html_content" | grep -q 'svi-editor-v2.js'; then
    print_status "OK" "Script SVI Editor V2 inclus"
else
    print_status "ERROR" "Script SVI Editor V2 manquant"
fi

# Test des erreurs JavaScript potentielles
echo -e "\n${BLUE}=== 5. TESTS DES ERREURS JAVASCRIPT ===${NC}"

# Vérification de la syntaxe JavaScript
if node -c "src/svi-admin/js/svi-editor-v2.js" 2>/dev/null; then
    print_status "OK" "JavaScript syntaxiquement correct"
else
    print_status "ERROR" "Erreur de syntaxe JavaScript"
    echo "Erreur détaillée:"
    node -c "src/svi-admin/js/svi-editor-v2.js"
fi

# Test des API backend
echo -e "\n${BLUE}=== 6. TESTS DES API BACKEND ===${NC}"

# Test API save-config
save_config_test=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$BASE_URL/svi-admin/api/save-config.php")
if [ "$save_config_test" = "200" ] || [ "$save_config_test" = "405" ]; then
    print_status "OK" "API save-config accessible"
else
    print_status "ERROR" "API save-config non accessible (HTTP $save_config_test)"
fi

# Test API load-config
load_config_test=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/svi-admin/api/load-config.php")
if [ "$load_config_test" = "200" ]; then
    print_status "OK" "API load-config accessible"
else
    print_status "ERROR" "API load-config non accessible (HTTP $load_config_test)"
fi

# Test des permissions de fichiers
echo -e "\n${BLUE}=== 7. TESTS DES PERMISSIONS ===${NC}"

# Vérification des permissions des fichiers
if [ -r "src/svi-admin/index-v2.php" ]; then
    print_status "OK" "index-v2.php lisible"
else
    print_status "ERROR" "index-v2.php non lisible"
fi

if [ -r "src/svi-admin/css/svi-admin.css" ]; then
    print_status "OK" "CSS lisible"
else
    print_status "ERROR" "CSS non lisible"
fi

if [ -r "src/svi-admin/js/svi-editor-v2.js" ]; then
    print_status "OK" "JavaScript lisible"
else
    print_status "ERROR" "JavaScript non lisible"
fi

# Test des logs Docker
echo -e "\n${BLUE}=== 8. TESTS DES LOGS DOCKER ===${NC}"

# Vérification des logs du conteneur web
web_logs=$(docker logs doriav2-web 2>&1 | tail -10)
if echo "$web_logs" | grep -q "ERROR\|FATAL\|Warning"; then
    print_status "WARN" "Erreurs détectées dans les logs web"
    echo "Logs récents:"
    echo "$web_logs"
else
    print_status "OK" "Pas d'erreurs critiques dans les logs web"
fi

# Test de navigation
echo -e "\n${BLUE}=== 9. TESTS DE NAVIGATION ===${NC}"

# Test des liens internes
if echo "$html_content" | grep -q 'data-view="builder"'; then
    print_status "OK" "Navigation builder présente"
else
    print_status "ERROR" "Navigation builder manquante"
fi

if echo "$html_content" | grep -q 'data-view="files"'; then
    print_status "OK" "Navigation files présente"
else
    print_status "ERROR" "Navigation files manquante"
fi

if echo "$html_content" | grep -q 'data-view="config"'; then
    print_status "OK" "Navigation config présente"
else
    print_status "ERROR" "Navigation config manquante"
fi

# Recommandations
echo -e "\n${BLUE}=== 10. RECOMMANDATIONS ===${NC}"

print_status "INFO" "Ouvrir la console navigateur (F12) pour voir les erreurs JavaScript"
print_status "INFO" "Vérifier la connexion réseau pour les librairies externes"
print_status "INFO" "Tester avec différents navigateurs (Chrome, Firefox, Safari)"
print_status "INFO" "Vérifier que Docker est en cours d'exécution"

echo -e "\n${GREEN}=== DIAGNOSTIC TERMINÉ ===${NC}"
echo "Pour plus d'informations, consultez les logs du navigateur et les logs Docker."
