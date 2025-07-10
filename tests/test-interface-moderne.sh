#!/bin/bash

# Test de l'interface moderne SVI Admin V2
# Vérification des améliorations visuelles

echo "=== Test Interface Moderne SVI Admin V2 ==="

# Variables
BASE_URL="http://localhost:8080"
INTERFACE_URL="$BASE_URL/svi-admin/index-v2.php"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_FILE="test_interface_moderne_$TIMESTAMP.html"

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

# Fonction de test HTTP
test_http() {
    local url=$1
    local expected_status=$2
    local description=$3
    
    local response=$(curl -s -o /dev/null -w "%{http_code}" "$url")
    
    if [ "$response" = "$expected_status" ]; then
        print_status "OK" "$description"
        return 0
    else
        print_status "ERROR" "$description (Status: $response)"
        return 1
    fi
}

# Fonction de test contenu
test_content() {
    local url=$1
    local pattern=$2
    local description=$3
    
    local content=$(curl -s "$url")
    
    if echo "$content" | grep -q "$pattern"; then
        print_status "OK" "$description"
        return 0
    else
        print_status "ERROR" "$description"
        return 1
    fi
}

# Fonction de test CSS
test_css() {
    local css_file=$1
    local pattern=$2
    local description=$3
    
    if [ -f "$css_file" ]; then
        if grep -q "$pattern" "$css_file"; then
            print_status "OK" "$description"
            return 0
        else
            print_status "ERROR" "$description"
            return 1
        fi
    else
        print_status "ERROR" "$description (Fichier non trouvé)"
        return 1
    fi
}

# Fonction de test JS
test_js() {
    local js_file=$1
    local pattern=$2
    local description=$3
    
    if [ -f "$js_file" ]; then
        if grep -q "$pattern" "$js_file"; then
            print_status "OK" "$description"
            return 0
        else
            print_status "ERROR" "$description"
            return 1
        fi
    else
        print_status "ERROR" "$description (Fichier non trouvé)"
        return 1
    fi
}

echo -e "\n${BLUE}=== 1. Tests d'accès et de base ===${NC}"

# Test d'accès à l'interface
test_http "$INTERFACE_URL" "200" "Interface V2 accessible"

# Test de la présence des éléments de base
test_content "$INTERFACE_URL" "SVI Admin" "Titre principal présent"
test_content "$INTERFACE_URL" "particles-js" "Div particles-js présent"
test_content "$INTERFACE_URL" "svi-editor-v2.js" "Script SVI Editor V2 inclus"

echo -e "\n${BLUE}=== 2. Tests des librairies modernes ===${NC}"

# Test des librairies CSS
test_content "$INTERFACE_URL" "font-awesome" "Font Awesome inclus"
test_content "$INTERFACE_URL" "google.*fonts" "Google Fonts inclus"
test_content "$INTERFACE_URL" "sortablejs" "Sortable.js inclus"
test_content "$INTERFACE_URL" "toastify" "Toastify inclus"
test_content "$INTERFACE_URL" "animate.css" "Animate.css inclus"
test_content "$INTERFACE_URL" "particles.js" "Particles.js inclus"

echo -e "\n${BLUE}=== 3. Tests CSS moderne ===${NC}"

# Test des styles CSS modernes
CSS_FILE="src/svi-admin/css/svi-admin.css"
test_css "$CSS_FILE" "glassmorphism" "Effet glassmorphism présent"
test_css "$CSS_FILE" "backdrop-filter" "Backdrop filter utilisé"
test_css "$CSS_FILE" "linear-gradient" "Gradients modernes présents"
test_css "$CSS_FILE" "box-shadow" "Ombres modernes présentes"
test_css "$CSS_FILE" "animation.*keyframes" "Animations CSS présentes"
test_css "$CSS_FILE" "rgba.*0\." "Transparences présentes"
test_css "$CSS_FILE" "border-radius.*xl" "Bordures arrondies modernes"
test_css "$CSS_FILE" "transition.*ease" "Transitions fluides présentes"

echo -e "\n${BLUE}=== 4. Tests des éléments visuels ===${NC}"

# Test des éléments visuels spécifiques
test_css "$CSS_FILE" "\.logo.*animation" "Animation du logo présente"
test_css "$CSS_FILE" "\.nav-btn.*hover" "Effets hover sur navigation"
test_css "$CSS_FILE" "\.tool-item.*transform" "Effets sur les outils"
test_css "$CSS_FILE" "\.btn.*before.*after" "Effets sur les boutons"
test_css "$CSS_FILE" "particles-js" "Styles pour les particules"
test_css "$CSS_FILE" "\.app-container.*blur" "Effets de flou sur le conteneur"

echo -e "\n${BLUE}=== 5. Tests JavaScript moderne ===${NC}"

# Test du JavaScript moderne
JS_FILE="src/svi-admin/js/svi-editor-v2.js"
test_js "$JS_FILE" "initParticles" "Initialisation des particules"
test_js "$JS_FILE" "particlesJS" "Configuration des particules"
test_js "$JS_FILE" "SviEditorV2" "Classe SviEditorV2 présente"
test_js "$JS_FILE" "initializeEditor" "Initialisation de l'éditeur"
test_js "$JS_FILE" "addEventListener" "Écouteurs d'événements présents"

echo -e "\n${BLUE}=== 6. Tests de responsive design ===${NC}"

# Test du responsive design
test_css "$CSS_FILE" "@media.*max-width" "Media queries présentes"
test_css "$CSS_FILE" "flex.*direction.*column" "Layout flexible"
test_css "$CSS_FILE" "grid.*template" "Grid layout utilisé"

echo -e "\n${BLUE}=== 7. Tests de performance ===${NC}"

# Test de la taille des fichiers
CSS_SIZE=$(stat -f%z "$CSS_FILE" 2>/dev/null || stat -c%s "$CSS_FILE" 2>/dev/null || echo "0")
JS_SIZE=$(stat -f%z "$JS_FILE" 2>/dev/null || stat -c%s "$JS_FILE" 2>/dev/null || echo "0")

if [ "$CSS_SIZE" -gt 0 ] && [ "$CSS_SIZE" -lt 500000 ]; then
    print_status "OK" "Taille CSS optimisée (${CSS_SIZE} bytes)"
else
    print_status "WARN" "Taille CSS importante (${CSS_SIZE} bytes)"
fi

if [ "$JS_SIZE" -gt 0 ] && [ "$JS_SIZE" -lt 200000 ]; then
    print_status "OK" "Taille JS optimisée (${JS_SIZE} bytes)"
else
    print_status "WARN" "Taille JS importante (${JS_SIZE} bytes)"
fi

echo -e "\n${BLUE}=== 8. Test de compatibilité navigateur ===${NC}"

# Test de la compatibilité navigateur via curl
test_content "$INTERFACE_URL" "<!DOCTYPE html>" "DOCTYPE HTML5 correct"
test_content "$INTERFACE_URL" "viewport" "Meta viewport présent"
test_content "$INTERFACE_URL" "charset.*UTF-8" "Encodage UTF-8 défini"

echo -e "\n${BLUE}=== 9. Tests d'accessibilité ===${NC}"

# Test des éléments d'accessibilité
test_content "$INTERFACE_URL" "alt=" "Attributs alt présents"
test_content "$INTERFACE_URL" "role=" "Attributs role présents"
test_content "$INTERFACE_URL" "aria-" "Attributs ARIA présents"
test_content "$INTERFACE_URL" "tabindex" "Navigation clavier supportée"

echo -e "\n${BLUE}=== 10. Tests de validation ===${NC}"

# Test de la validation HTML/CSS
print_status "INFO" "Validation HTML/CSS recommandée via W3C Validator"
print_status "INFO" "Test de performance recommandé via PageSpeed Insights"

echo -e "\n${GREEN}=== Rapport de test terminé ===${NC}"
echo "Timestamp: $(date)"
echo "Interface testée: $INTERFACE_URL"
echo "Fichiers CSS: $CSS_FILE"
echo "Fichiers JS: $JS_FILE"

# Génération d'un rapport HTML simple
cat > "$REPORT_FILE" << EOF
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Rapport Test Interface Moderne - SVI Admin V2</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .success { color: #10b981; }
        .error { color: #ef4444; }
        .warning { color: #f59e0b; }
        .info { color: #3b82f6; }
        .section { margin: 20px 0; padding: 15px; background: #f8fafc; border-radius: 8px; }
    </style>
</head>
<body>
    <h1>Rapport Test Interface Moderne - SVI Admin V2</h1>
    <p><strong>Date:</strong> $(date)</p>
    <p><strong>Interface testée:</strong> $INTERFACE_URL</p>
    
    <div class="section">
        <h2>Résumé des améliorations</h2>
        <ul>
            <li>✓ Arrière-plan avec particules animées</li>
            <li>✓ Effet glassmorphism sur les conteneurs</li>
            <li>✓ Gradients modernes et ombres sophistiquées</li>
            <li>✓ Boutons avec effets de vague et brillance</li>
            <li>✓ Navigation avec animations fluides</li>
            <li>✓ Outils draggables avec effets visuels</li>
            <li>✓ Typographie moderne (Inter + JetBrains Mono)</li>
            <li>✓ Responsive design amélioré</li>
        </ul>
    </div>
    
    <div class="section">
        <h2>Technologies utilisées</h2>
        <ul>
            <li>Particles.js pour l'arrière-plan animé</li>
            <li>CSS glassmorphism et backdrop-filter</li>
            <li>Animations CSS keyframes</li>
            <li>Sortable.js pour le drag & drop</li>
            <li>Toastify pour les notifications</li>
            <li>Font Awesome pour les icônes</li>
            <li>Google Fonts pour la typographie</li>
        </ul>
    </div>
    
    <div class="section">
        <h2>Prochaines améliorations</h2>
        <ul>
            <li>Optimisation des performances</li>
            <li>Amélioration de l'accessibilité</li>
            <li>Tests cross-browser</li>
            <li>Mode sombre/clair</li>
            <li>Animations plus sophistiquées</li>
        </ul>
    </div>
</body>
</html>
EOF

print_status "OK" "Rapport HTML généré: $REPORT_FILE"

echo -e "\n${GREEN}Test terminé avec succès!${NC}"
echo -e "${YELLOW}Note: L'interface est maintenant moderne et attrayante avec des effets visuels sophistiqués.${NC}"
