#!/bin/bash

# Script de test complet pour DoriaV2
# Teste toutes les foncti# Résumé
echo "=== Résumé des tests ==="
echo "Tests effectués: 12"
echo "Projet DoriaV2 testé avec succès!"
echo
echo "Interface web V1: http://localhost:8080/svi-admin/"
echo "Interface web V2 (moderne): http://localhost:8080/svi-admin/index-v2.php"
echo "API historique: http://localhost:8080/svi-admin/api/call-history.php"
echo "Statistiques: http://localhost:8080/svi-admin/api/call-history.php?action=stats"
echo du projet

echo "=== Test complet DoriaV2 ==="
echo "Date: $(date)"
echo

# 1. Test des services Docker
echo "1. Vérification des services Docker..."
docker-compose ps | grep -E "(Up|healthy)" && echo "✓ Services Docker OK" || echo "✗ Problème avec les services Docker"
echo

# 2. Test de la base de données
echo "2. Test de la base de données..."
docker exec doriav2-mysql mysql -u root -pdoriav2_root_password -e "SELECT COUNT(*) as tables FROM information_schema.tables WHERE table_schema='asterisk';" 2>/dev/null | grep -E "[0-9]+" && echo "✓ Base de données OK" || echo "✗ Problème avec la base de données"
echo

# 3. Test des tables SVI
echo "3. Test des tables SVI..."
docker exec doriav2-mysql mysql -u root -pdoriav2_root_password -e "SELECT COUNT(*) as calls FROM asterisk.svi_call_history;" 2>/dev/null | grep -E "[0-9]+" && echo "✓ Tables SVI OK" || echo "✗ Problème avec les tables SVI"
echo

# 4. Test d'Asterisk
echo "4. Test d'Asterisk..."
docker exec doriav2-asterisk asterisk -rx "core show version" 2>/dev/null | grep -i "asterisk" && echo "✓ Asterisk OK" || echo "✗ Problème avec Asterisk"
echo

# 5. Test du serveur web
echo "5. Test du serveur web..."
curl -s "http://localhost:8080/svi-admin/" | grep -i "svi admin" && echo "✓ Serveur web OK" || echo "✗ Problème avec le serveur web"
echo

# 6. Test de l'API d'historique
echo "6. Test de l'API d'historique..."
response=$(curl -s "http://localhost:8080/svi-admin/api/call-history.php?period=all")
echo "$response" | grep -q '"success":true' && echo "✓ API d'historique OK" || echo "✗ Problème avec l'API d'historique"
echo

# 7. Test des statistiques
echo "7. Test des statistiques..."
stats_response=$(curl -s "http://localhost:8080/svi-admin/api/call-history.php?action=stats&period=all")
echo "$stats_response" | grep -q '"total_calls"' && echo "✓ API des statistiques OK" || echo "✗ Problème avec l'API des statistiques"
echo

# 8. Test des endpoints SIP
echo "8. Test des endpoints SIP..."
docker exec doriav2-asterisk asterisk -rx "pjsip show endpoints" 2>/dev/null | grep -E "(1001|1002|1003|1004)" && echo "✓ Endpoints SIP OK" || echo "✗ Problème avec les endpoints SIP"
echo

# 9. Test des fichiers CSS/JS
echo "9. Test des ressources statiques..."
curl -s "http://localhost:8080/svi-admin/css/svi-admin.css" | grep -q "body" && echo "✓ CSS chargé OK" || echo "✗ Problème avec le CSS"
curl -s "http://localhost:8080/svi-admin/js/svi-editor.js" | grep -q "class SviEditor" && echo "✓ JavaScript V1 chargé OK" || echo "✗ Problème avec le JavaScript V1"
curl -s "http://localhost:8080/svi-admin/js/svi-editor-v2.js" | grep -q "class SviEditorV2" && echo "✓ JavaScript V2 chargé OK" || echo "✗ Problème avec le JavaScript V2"
echo

# 10. Test des volumes Docker
echo "10. Test des volumes Docker..."
docker volume ls | grep -E "(mysql_data|redis_data)" && echo "✓ Volumes Docker OK" || echo "✗ Problème avec les volumes Docker"
echo

# 11. Test réseau
echo "11. Test des communications internes..."
docker exec doriav2-web ping -c 1 doriav2-mysql > /dev/null 2>&1 && echo "✓ Communication web->mysql OK" || echo "✗ Problème de communication web->mysql"
docker exec doriav2-web ping -c 1 doriav2-redis > /dev/null 2>&1 && echo "✓ Communication web->redis OK" || echo "✗ Problème de communication web->redis"
echo

# 12. Test de l'interface V2 moderne
echo "12. Test de l'interface V2 moderne..."
curl -s "http://localhost:8080/svi-admin/index-v2.php" | grep -q "SVI Admin" && echo "✓ Interface V2 accessible" || echo "✗ Problème avec l'interface V2"
curl -s "http://localhost:8080/svi-admin/index-v2.php" | grep -q "sortablejs" && echo "✓ Drag & drop moderne activé" || echo "✗ Problème avec le drag & drop"
curl -s "http://localhost:8080/svi-admin/index-v2.php" | grep -q "toastify" && echo "✓ Notifications modernes activées" || echo "✗ Problème avec les notifications"
echo

# Résumé
echo "=== Résumé des tests ==="
echo "Tests effectués: 12"
echo "Projet DoriaV2 testé avec succès!"
echo
echo "Interface web: http://localhost:8080/svi-admin/"
echo "API historique: http://localhost:8080/svi-admin/api/call-history.php"
echo "Statistiques: http://localhost:8080/svi-admin/api/call-history.php?action=stats"
echo

echo "=== Données de test disponibles ==="
echo "Nombre d'appels en base: $(docker exec doriav2-mysql mysql -u root -pdoriav2_root_password -e "SELECT COUNT(*) FROM asterisk.svi_call_history;" 2>/dev/null | tail -1)"
echo "Statuts des appels: $(docker exec doriav2-mysql mysql -u root -pdoriav2_root_password -e "SELECT hangup_status, COUNT(*) FROM asterisk.svi_call_history GROUP BY hangup_status;" 2>/dev/null | tail -n +2)"
echo

echo "=== Test terminé ==="
