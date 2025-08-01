# 🔧 Résolution de l'Erreur pjsip.conf

## ❌ Problème Initial
```
Erreur lors du chargement des utilisateurs: Fichier pjsip.conf non trouvé: /var/www/html/asterisk-config/pjsip.conf
```

## 🔍 Diagnostic Effectué

### ✅ Vérifications Backend
1. **Fichier pjsip.conf présent** dans `asterisk/config/pjsip.conf` ✅
2. **Volume Docker correctement mappé** dans `compose.yml` ✅
3. **Fichier accessible dans le conteneur** via `docker exec` ✅
4. **API PHP fonctionnelle** - test curl réussi ✅

### ❌ Problème Identifié
- **Configuration proxy Angular incorrecte** : pointait vers `host.docker.internal:8080` au lieu de `localhost:8080`
- **Restes de l'ancien dossier** `angular-svi-editor/` après réorganisation

## 🛠️ Actions Correctives

### 1. Nettoyage de la Structure
```bash
# Suppression des restes de l'ancienne structure
rm -rf angular-svi-editor/

# Redémarrage des conteneurs avec nouveaux chemins
docker-compose down && docker-compose up -d
```

### 2. Correction Configuration Proxy
**Avant** (`proxy.conf.json`) :
```json
{
  "/api/*": {
    "target": "http://host.docker.internal:8080/svi-admin/api",
    ...
  }
}
```

**Après** (`proxy.conf.json`) :
```json
{
  "/api/*": {
    "target": "http://localhost:8080/svi-admin/api",
    ...
  }
}
```

### 3. Redémarrage Angular
```bash
cd frontend/angular
npm start
# Application disponible sur http://localhost:53536
```

## ✅ Résultat

### Backend (PHP)
- **URL** : http://localhost:8080
- **API Utilisateurs** : http://localhost:8080/svi-admin/api/users-management.php?action=list
- **Statut** : ✅ Fonctionnel

### Frontend (Angular) 
- **URL** : http://localhost:53536
- **Proxy API** : `/api/*` → `http://localhost:8080/svi-admin/api/*`
- **Statut** : ✅ Fonctionnel

### Fichier pjsip.conf
- **Chemin Host** : `asterisk/config/pjsip.conf`
- **Chemin Container** : `/var/www/html/asterisk-config/pjsip.conf`
- **Statut** : ✅ Accessible et lisible

## 📋 Structure Finale Fonctionnelle

```
DoriaV2/
├── frontend/angular/          # ✅ Application Angular - Port 53536
├── backend/php/               # ✅ Backend PHP - Port 8080
├── asterisk/config/           # ✅ Configuration Asterisk accessible
└── compose.yml                # ✅ Volumes correctement mappés
```

## 🎯 Points Clés

1. **Réorganisation réussie** - Structure claire sans fichiers .unified/.frontend
2. **Configuration proxy corrigée** - host.docker.internal → localhost
3. **Volumes Docker fonctionnels** - Accès aux fichiers de configuration
4. **Applications opérationnelles** - Angular + PHP + API

> ✅ **Problème résolu** : L'erreur venait de la configuration proxy Angular, pas du fichier pjsip.conf lui-même.
