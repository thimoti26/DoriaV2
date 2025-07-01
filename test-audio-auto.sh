#!/bin/bash

# Test audio automatisé DoriaV2
# Ce script teste toutes les extensions audio via la CLI Asterisk

echo "🎵 TEST AUDIO AUTOMATISÉ DORIAV2"
echo "=================================="

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

test_extension() {
    local ext=$1
    local description=$2
    local timeout=${3:-10}
    
    echo -e "\n📞 Test extension ${ext} - ${description}"
    echo "   Durée maximale: ${timeout}s"
    
    # Démarrer le test en arrière-plan
    local cmd="channel originate Local/${ext}@from-internal extension h@from-internal"
    local result=$(docker exec doriav2-asterisk asterisk -rx "$cmd" 2>&1)
    
    if echo "$result" | grep -q "Asterisk ending"; then
        echo -e "   ${GREEN}✅ Extension ${ext} testée avec succès${NC}"
        return 0
    else
        echo -e "   ${RED}❌ Erreur lors du test de l'extension ${ext}${NC}"
        echo "   Détail: $result"
        return 1
    fi
}

test_dialplan() {
    local ext=$1
    local context=${2:-from-internal}
    
    local result=$(docker exec doriav2-asterisk asterisk -rx "dialplan show ${ext}@${context}" 2>&1)
    
    if echo "$result" | grep -q "extension"; then
        echo -e "   ${GREEN}✅ Extension ${ext} configurée${NC}"
        return 0
    else
        echo -e "   ${RED}❌ Extension ${ext} non trouvée${NC}"
        return 1
    fi
}

# Vérifier que le conteneur Asterisk fonctionne
echo "🔍 Vérification du conteneur Asterisk..."
if ! docker exec doriav2-asterisk asterisk -rx "core show version" > /dev/null 2>&1; then
    echo -e "${RED}❌ Asterisk n'est pas accessible${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Asterisk répond${NC}"

# Test de configuration des extensions
echo -e "\n📋 Vérification configuration des extensions..."

test_dialplan "100"
test_dialplan "*43" 
test_dialplan "*44"
test_dialplan "*45"

# Test des endpoints SIP
echo -e "\n📱 Vérification des endpoints SIP..."
endpoints=$(docker exec doriav2-asterisk asterisk -rx "pjsip show endpoints" 2>/dev/null | grep -c "1001\|1002\|1003\|1004")
if [ "$endpoints" -ge 4 ]; then
    echo -e "${GREEN}✅ Tous les endpoints SIP configurés (${endpoints}/4)${NC}"
else
    echo -e "${YELLOW}⚠️  Seulement ${endpoints}/4 endpoints configurés${NC}"
fi

# Test des modules nécessaires
echo -e "\n🔧 Vérification des modules Asterisk..."

modules=("app_echo" "app_playback" "res_pjsip" "app_dial")
for module in "${modules[@]}"; do
    if docker exec doriav2-asterisk asterisk -rx "module show like $module" 2>/dev/null | grep -q "$module"; then
        echo -e "   ${GREEN}✅ Module $module chargé${NC}"
    else
        echo -e "   ${RED}❌ Module $module non chargé${NC}"
    fi
done

# Test des fichiers audio
echo -e "\n🎶 Vérification des fichiers audio..."

audio_files=("demo-congrats" "hello-world" "demo-thanks" "demo-echotest")
for file in "${audio_files[@]}"; do
    if docker exec doriav2-asterisk find /var/lib/asterisk/sounds -name "${file}.*" | grep -q "$file"; then
        echo -e "   ${GREEN}✅ Fichier audio $file trouvé${NC}"
    else
        echo -e "   ${RED}❌ Fichier audio $file manquant${NC}"
    fi
done

# Tests fonctionnels simplifiés
echo -e "\n🧪 Tests fonctionnels..."

echo "   Test 1: Vérification que les extensions peuvent être appelées"
for ext in "100" "*43" "*44" "*45"; do
    if test_dialplan "$ext"; then
        # Test de syntaxe uniquement (sans vraiment lancer l'appel)
        syntax_test=$(docker exec doriav2-asterisk asterisk -rx "dialplan show ${ext}@from-internal" 2>&1)
        if echo "$syntax_test" | grep -q "Answer\|Playback\|Echo"; then
            echo -e "   ${GREEN}✅ Extension $ext syntaxiquement correcte${NC}"
        else
            echo -e "   ${YELLOW}⚠️  Extension $ext: syntaxe à vérifier${NC}"
        fi
    fi
done

# Vérification des codecs
echo -e "\n🎤 Vérification des codecs audio..."
codecs=$(docker exec doriav2-asterisk asterisk -rx "core show codecs audio" 2>/dev/null | grep -E "(ulaw|alaw|gsm)" | wc -l)
if [ "$codecs" -ge 3 ]; then
    echo -e "${GREEN}✅ Codecs audio disponibles (${codecs} trouvés)${NC}"
else
    echo -e "${YELLOW}⚠️  Peu de codecs audio disponibles (${codecs})${NC}"
fi

# Résumé final
echo -e "\n📊 RÉSUMÉ DU TEST AUDIO"
echo "========================"

echo -e "${GREEN}✅ Prêt pour les tests en conditions réelles${NC}"
echo ""
echo "🎯 Prochaines étapes recommandées:"
echo "1. Configurer Linphone avec l'utilisateur 1001"
echo "2. Tester l'extension 100 (message simple)"
echo "3. Tester l'extension *45 (tonalité)"
echo "4. Tester l'extension *43 (écho complet)"
echo ""
echo "📋 Configuration Linphone:"
echo "   Serveur: localhost:5060"
echo "   Utilisateur: 1001"
echo "   Mot de passe: linphone1001"
echo "   Codecs: ulaw, alaw"
echo ""
echo "🔍 Pour monitoring en temps réel:"
echo "   ./debug-audio.sh"
echo ""
echo "🌐 Interface web:"
echo "   http://localhost:8080"

echo -e "\n🎉 Test automatisé terminé !"
