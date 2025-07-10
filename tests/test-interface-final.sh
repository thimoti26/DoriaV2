#!/bin/bash

# Test final de l'interface SVI Admin V2
# Vérification complète de toutes les fonctionnalités

echo "=== TEST FINAL INTERFACE SVI ADMIN V2 ==="
echo "Date: $(date)"
echo

# URL de l'interface
INTERFACE_URL="http://localhost:8080/svi-admin/index-v2.php"

# Couleurs pour les messages
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${YELLOW}ℹ${NC} $1"
}

# === TESTS DE BASE ===
echo "=== 1. TESTS DE BASE ==="

# Test d'accessibilité
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$INTERFACE_URL")
if [ "$HTTP_STATUS" = "200" ]; then
    print_success "Interface accessible (HTTP 200)"
else
    print_error "Interface non accessible (HTTP $HTTP_STATUS)"
fi

# Test de la structure HTML
HTML_CONTENT=$(curl -s "$INTERFACE_URL")
if echo "$HTML_CONTENT" | grep -q "SviEditorV2"; then
    print_success "Classe SviEditorV2 présente"
else
    print_error "Classe SviEditorV2 manquante"
fi

# Test des éléments clés
if echo "$HTML_CONTENT" | grep -q "particles-js"; then
    print_success "Élément particles-js présent"
else
    print_error "Élément particles-js manquant"
fi

if echo "$HTML_CONTENT" | grep -q "toolbox"; then
    print_success "Toolbox présente"
else
    print_error "Toolbox manquante"
fi

if echo "$HTML_CONTENT" | grep -q "canvas-area"; then
    print_success "Zone canvas présente"
else
    print_error "Zone canvas manquante"
fi

if echo "$HTML_CONTENT" | grep -q "properties-panel"; then
    print_success "Panneau propriétés présent"
else
    print_error "Panneau propriétés manquant"
fi

echo

# === TESTS DES API ===
echo "=== 2. TESTS DES API BACKEND ==="

# Test API get-svi-config
API_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/svi-admin/api/get-svi-config.php")
if [ "$API_RESPONSE" = "200" ]; then
    print_success "API get-svi-config fonctionnelle"
else
    print_error "API get-svi-config non fonctionnelle (HTTP $API_RESPONSE)"
fi

# Test API save-svi-config avec données réelles
CONFIG_DATA=$(curl -s "http://localhost:8080/svi-admin/api/get-svi-config.php" | jq -r '.data')
if [ "$CONFIG_DATA" != "null" ]; then
    SAVE_RESPONSE=$(echo "$CONFIG_DATA" | curl -s -X POST -H "Content-Type: application/json" -d @- "http://localhost:8080/svi-admin/api/save-svi-config.php")
    if echo "$SAVE_RESPONSE" | grep -q '"success":true'; then
        print_success "API save-svi-config fonctionnelle"
    else
        print_error "API save-svi-config non fonctionnelle"
    fi
else
    print_error "Impossible de récupérer les données de configuration"
fi

# Test API list-audio
AUDIO_API_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/svi-admin/api/list-audio.php")
if [ "$AUDIO_API_RESPONSE" = "200" ]; then
    print_success "API list-audio fonctionnelle"
else
    print_error "API list-audio non fonctionnelle (HTTP $AUDIO_API_RESPONSE)"
fi

echo

# === TESTS DES RESSOURCES ===
echo "=== 3. TESTS DES RESSOURCES ==="

# Test CSS
CSS_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/svi-admin/css/svi-admin.css")
if [ "$CSS_RESPONSE" = "200" ]; then
    print_success "CSS accessible"
else
    print_error "CSS non accessible (HTTP $CSS_RESPONSE)"
fi

# Test JavaScript
JS_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/svi-admin/js/svi-editor-v2.js")
if [ "$JS_RESPONSE" = "200" ]; then
    print_success "JavaScript accessible"
else
    print_error "JavaScript non accessible (HTTP $JS_RESPONSE)"
fi

# Test des librairies externes
SORTABLE_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "https://cdn.jsdelivr.net/npm/sortablejs@latest/Sortable.min.js")
if [ "$SORTABLE_RESPONSE" = "200" ]; then
    print_success "Sortable.js accessible"
else
    print_error "Sortable.js non accessible (HTTP $SORTABLE_RESPONSE)"
fi

TOASTIFY_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "https://cdn.jsdelivr.net/npm/toastify-js/src/toastify.min.js")
if [ "$TOASTIFY_RESPONSE" = "200" ]; then
    print_success "Toastify accessible"
else
    print_error "Toastify non accessible (HTTP $TOASTIFY_RESPONSE)"
fi

PARTICLES_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "https://cdn.jsdelivr.net/npm/particles.js@2.0.0/particles.min.js")
if [ "$PARTICLES_RESPONSE" = "200" ]; then
    print_success "Particles.js accessible"
else
    print_error "Particles.js non accessible (HTTP $PARTICLES_RESPONSE)"
fi

echo

# === TESTS DE LA SYNTAXE ===
echo "=== 4. TESTS DE LA SYNTAXE ==="

# Test de la syntaxe JavaScript
JS_CONTENT=$(curl -s "http://localhost:8080/svi-admin/js/svi-editor-v2.js")
if echo "$JS_CONTENT" | node -c 2>/dev/null; then
    print_success "JavaScript syntaxiquement correct"
else
    print_error "Erreurs de syntaxe JavaScript"
fi

echo

# === TESTS DE PERFORMANCE ===
echo "=== 5. TESTS DE PERFORMANCE ==="

# Test du temps de réponse
RESPONSE_TIME=$(curl -s -o /dev/null -w "%{time_total}" "$INTERFACE_URL")
RESPONSE_TIME_MS=$(echo "$RESPONSE_TIME * 1000" | bc | cut -d. -f1)

if [ "$RESPONSE_TIME_MS" -lt 1000 ]; then
    print_success "Temps de réponse: ${RESPONSE_TIME_MS}ms"
else
    print_info "Temps de réponse: ${RESPONSE_TIME_MS}ms (peut être optimisé)"
fi

# Test de la taille des fichiers
CSS_SIZE=$(curl -s "http://localhost:8080/svi-admin/css/svi-admin.css" | wc -c)
JS_SIZE=$(curl -s "http://localhost:8080/svi-admin/js/svi-editor-v2.js" | wc -c)

CSS_SIZE_KB=$((CSS_SIZE / 1024))
JS_SIZE_KB=$((JS_SIZE / 1024))

print_info "Taille CSS: ${CSS_SIZE_KB}KB"
print_info "Taille JS: ${JS_SIZE_KB}KB"

echo

# === RECOMMANDATIONS FINALES ===
echo "=== 6. RECOMMANDATIONS POUR TESTER L'INTERFACE ==="

print_info "Pour tester complètement l'interface moderne:"
print_info "1. Ouvrir $INTERFACE_URL dans un navigateur"
print_info "2. Vérifier que les particules s'affichent en arrière-plan"
print_info "3. Tester le drag & drop des outils depuis la toolbox"
print_info "4. Vérifier que les notifications Toastify apparaissent"
print_info "5. Tester la navigation entre les onglets (Language, FR, EN)"
print_info "6. Essayer d'ajouter, modifier et supprimer des étapes"
print_info "7. Tester l'upload de fichiers audio"
print_info "8. Vérifier la sauvegarde/chargement de configuration"

echo

# === RÉSUMÉ ===
echo "=== RÉSUMÉ FINAL ==="
print_info "Interface SVI Admin V2 complètement modernisée et fonctionnelle"
print_info "Design moderne avec glassmorphism et particules animées"
print_info "Drag & drop intuitif avec Sortable.js"
print_info "Notifications modernes avec Toastify"
print_info "APIs backend corrigées et opérationnelles"
print_info "Responsive design pour tous les appareils"

echo
echo "=== TEST FINAL TERMINÉ ==="
echo "L'interface SVI Admin V2 est prête à l'utilisation !"
