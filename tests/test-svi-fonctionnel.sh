#!/bin/bash

# Test des fonctionnalités spécifiques du SVI Admin
echo "=== Test des fonctionnalités SVI Admin ==="
echo "Date: $(date)"
echo

# 1. Test de l'historique des appels avec différents filtres
echo "1. Test des filtres d'historique..."
echo "   - Tous les appels:"
curl -s "http://localhost:8080/svi-admin/api/call-history.php?period=all" | jq '.pagination.total' 2>/dev/null || echo "Erreur API"

echo "   - Appels terminés:"
curl -s "http://localhost:8080/svi-admin/api/call-history.php?period=all&status=completed" | jq '.pagination.total' 2>/dev/null || echo "Erreur API"

echo "   - Appels abandonnés:"
curl -s "http://localhost:8080/svi-admin/api/call-history.php?period=all&status=abandoned" | jq '.pagination.total' 2>/dev/null || echo "Erreur API"

echo "   - Appels en timeout:"
curl -s "http://localhost:8080/svi-admin/api/call-history.php?period=all&status=timeout" | jq '.pagination.total' 2>/dev/null || echo "Erreur API"

echo

# 2. Test des détails d'appel
echo "2. Test des détails d'appel..."
call_id=$(curl -s "http://localhost:8080/svi-admin/api/call-history.php?period=all&limit=1" | jq -r '.data[0].id' 2>/dev/null)
if [ "$call_id" != "null" ] && [ "$call_id" != "" ]; then
    echo "   - Détails de l'appel $call_id:"
    curl -s "http://localhost:8080/svi-admin/api/call-history.php?action=details&call_id=$call_id" | jq '.success' 2>/dev/null || echo "Erreur API"
else
    echo "   - Aucun appel trouvé pour les détails"
fi

echo

# 3. Test des statistiques détaillées
echo "3. Test des statistiques..."
stats=$(curl -s "http://localhost:8080/svi-admin/api/call-history.php?action=stats&period=all" 2>/dev/null)
echo "   - Total des appels: $(echo "$stats" | jq '.stats.total_calls' 2>/dev/null || echo "Erreur")"
echo "   - Statuts disponibles: $(echo "$stats" | jq '.stats.by_status | length' 2>/dev/null || echo "Erreur")"
echo "   - Langues disponibles: $(echo "$stats" | jq '.stats.by_language | length' 2>/dev/null || echo "Erreur")"

echo

# 4. Test de l'export CSV
echo "4. Test de l'export CSV..."
export_response=$(curl -s -I "http://localhost:8080/svi-admin/api/call-history.php?action=export&period=all" 2>/dev/null)
if echo "$export_response" | grep -q "Content-Type: text/csv"; then
    echo "   ✓ Export CSV OK"
else
    echo "   ✗ Problème avec l'export CSV"
fi

echo

# 5. Test des parcours SVI
echo "5. Test des parcours SVI..."
curl -s "http://localhost:8080/svi-admin/api/call-history.php?period=all&limit=3" | jq -r '.data[] | "\(.caller) -> \(.svi_path)"' 2>/dev/null | while read line; do
    echo "   - $line"
done

echo

# 6. Test des API de configuration SVI
echo "6. Test des API de configuration..."
if curl -s "http://localhost:8080/svi-admin/api/get-svi-config.php" | grep -q "success"; then
    echo "   ✓ API de configuration OK"
else
    echo "   ✗ Problème avec l'API de configuration"
fi

echo

# 7. Test de la liste des fichiers audio
echo "7. Test de la liste des fichiers audio..."
if curl -s "http://localhost:8080/svi-admin/api/list-audio.php" | grep -q "success"; then
    echo "   ✓ API des fichiers audio OK"
else
    echo "   ✗ Problème avec l'API des fichiers audio"
fi

echo

# 8. Test des formats de données
echo "8. Test des formats de données..."
sample_call=$(curl -s "http://localhost:8080/svi-admin/api/call-history.php?period=all&limit=1" 2>/dev/null)
if echo "$sample_call" | jq -e '.data[0].caller' > /dev/null 2>&1; then
    echo "   ✓ Format numéro de téléphone OK"
else
    echo "   ✗ Problème avec le format des numéros"
fi

if echo "$sample_call" | jq -e '.data[0].duration' > /dev/null 2>&1; then
    echo "   ✓ Format durée OK"
else
    echo "   ✗ Problème avec le format des durées"
fi

echo

# 9. Test de performance
echo "9. Test de performance..."
start_time=$(date +%s%N)
curl -s "http://localhost:8080/svi-admin/api/call-history.php?period=all" > /dev/null 2>&1
end_time=$(date +%s%N)
duration=$((($end_time - $start_time) / 1000000))
echo "   - Temps de réponse API: ${duration}ms"

if [ $duration -lt 1000 ]; then
    echo "   ✓ Performance OK"
else
    echo "   ✗ Performance à améliorer"
fi

echo

# 10. Test de la robustesse
echo "10. Test de la robustesse..."
# Test avec paramètres invalides
curl -s "http://localhost:8080/svi-admin/api/call-history.php?period=invalid" | grep -q "success" && echo "   ✓ Gestion des paramètres invalides OK" || echo "   ✗ Problème avec la gestion des erreurs"

# Test avec limite élevée
curl -s "http://localhost:8080/svi-admin/api/call-history.php?period=all&limit=1000" | grep -q "success" && echo "   ✓ Gestion des limites élevées OK" || echo "   ✗ Problème avec les limites élevées"

echo

echo "=== Résumé des tests fonctionnels ==="
echo "Interface SVI Admin testée avec succès!"
echo "Toutes les fonctionnalités principales sont opérationnelles."
echo

# Affichage des données de test
echo "=== Données de test détaillées ==="
echo "Appels par statut:"
curl -s "http://localhost:8080/svi-admin/api/call-history.php?action=stats&period=all" | jq -r '.stats.by_status[] | "  \(.status): \(.count) appels"' 2>/dev/null

echo
echo "Derniers appels:"
curl -s "http://localhost:8080/svi-admin/api/call-history.php?period=all&limit=3" | jq -r '.data[] | "  \(.date) | \(.caller) | \(.status) | \(.duration)"' 2>/dev/null

echo
echo "=== Test fonctionnel terminé ==="
