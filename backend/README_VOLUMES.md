# SVI Admin - Déploiement avec Volumes Docker

## 🎯 Objectif

Ce projet utilise maintenant des **volumes Docker** au lieu de copies statiques pour permettre un développement en temps réel et une configuration flexible.

## 📁 Architecture avec Volumes

```yaml
# compose.yml - Configuration des volumes
services:
  web:
    volumes:
      # Code source complet (développement en temps réel)
      - ./src:/var/www/html
      # Configurations Asterisk pour administration
      - ./asterisk/config:/var/www/html/asterisk-config
      - ./asterisk/sounds:/var/www/html/asterisk-sounds
      # Logs pour debugging
      - web_logs:/var/log/apache2
```

## ✅ Avantages des Volumes

### 🚀 Développement en Temps Réel
- **Modifications instantanées** : Aucun rebuild nécessaire
- **Debugging simplifié** : Modifications directes dans les fichiers source
- **Cycle de développement rapide** : Voir les changements immédiatement

### 🔧 Configuration Flexible
- **Environments multiples** : Facile de changer les fichiers selon l'environnement
- **Customisation** : Possibilité de monter différents dossiers selon les besoins
- **Partage de code** : Plusieurs conteneurs peuvent partager le même code

### 📊 Facilité de Maintenance
- **Mise à jour simplifiée** : Pas de rebuild pour chaque changement
- **Sauvegarde** : Code source reste sur l'hôte
- **Logs accessibles** : Fichiers de logs disponibles en temps réel

## 🛠️ Utilisation

### Démarrage
```bash
# Démarrage des services avec volumes
docker-compose up -d

# Vérification du statut
docker-compose ps
```

### Développement
1. **Modifier les fichiers** dans `src/svi-admin/`
2. **Actualiser le navigateur** → Les changements sont visibles immédiatement
3. **Pas de rebuild nécessaire**

### Exemple de Modification en Temps Réel
```bash
# Modifier un fichier
echo "console.log('Test volume');" >> src/svi-admin/js/svi-admin.js

# Vérifier immédiatement dans le navigateur
curl http://localhost:8080/svi-admin/js/svi-admin.js | tail -1
```

## 📂 Structure des Fichiers Montés

```
/var/www/html/ (dans le conteneur)
├── src/ → ./src (volume host)
│   ├── svi-admin/
│   │   ├── index.html          # Interface principale
│   │   ├── css/svi-simple.css  # Styles unifiés
│   │   ├── js/svi-admin.js     # Logique JavaScript
│   │   ├── api/                # Endpoints PHP
│   │   └── uploads/            # Fichiers audio
│   ├── index.php               # Redirection principale
│   └── ...
├── asterisk-config/ → ./asterisk/config (volume)
└── asterisk-sounds/ → ./asterisk/sounds (volume)
```

## 🔐 Permissions

Le script d'initialisation s'assure que les permissions sont correctes :

```bash
#!/bin/bash
# /docker-entrypoint.sh

# Mise à jour des permissions à chaque démarrage
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html
chmod -R 775 /var/www/html/svi-admin/uploads

# Création du fichier de redirection si nécessaire
if [ ! -f /var/www/html/index.php ]; then
    echo '<?php header("Location: /svi-admin/"); exit; ?>' > /var/www/html/index.php
fi

# Démarrage d'Apache
exec apache2-foreground
```

## 🧪 Tests et Validation

### Test de Fonctionnement
```bash
# Interface principale
curl -I http://localhost:8080/svi-admin/index.html

# API
curl http://localhost:8080/svi-admin/api/test.php

# Redirection racine
curl -I http://localhost:8080/
```

### Test de Modification en Temps Réel
```bash
# 1. Noter le titre actuel
curl -s http://localhost:8080/svi-admin/index.html | grep -i title

# 2. Modifier le fichier
sed -i 's/Interface Simplifiée/Interface Modifiée/g' src/svi-admin/index.html

# 3. Vérifier le changement immédiat
curl -s http://localhost:8080/svi-admin/index.html | grep -i title
```

## 🔧 Debugging

### Accès aux Logs
```bash
# Logs du conteneur web
docker-compose logs -f web

# Logs Apache dans le conteneur
docker-compose exec web tail -f /var/log/apache2/error.log

# Vérification des volumes montés
docker-compose exec web ls -la /var/www/html/
```

### Vérification des Permissions
```bash
# Vérifier les permissions dans le conteneur
docker-compose exec web ls -la /var/www/html/svi-admin/

# Forcer la mise à jour des permissions
docker-compose exec web chown -R www-data:www-data /var/www/html
```

## 🚀 Déploiement Production vs Développement

### Développement (Volumes)
```yaml
# compose.yml (actuel)
volumes:
  - ./src:/var/www/html  # Accès direct aux sources
```

**Avantages :**
- Modifications en temps réel
- Debugging facilité
- Cycle de développement rapide

### Production (Recommandation)
```yaml
# compose.prod.yml (exemple)
# Utiliser COPY dans le Dockerfile pour l'isolation
```

**Avantages :**
- Sécurité renforcée
- Performance optimale
- Isolation complète

## 📋 Commandes Utiles

### Gestion des Conteneurs
```bash
# Redémarrage complet
docker-compose down && docker-compose up -d

# Reconstruction si changement Dockerfile
docker-compose up -d --build

# Nettoyage complet
docker-compose down -v
```

### Monitoring
```bash
# Statut des services
docker-compose ps

# Utilisation des ressources
docker stats

# Logs en temps réel
docker-compose logs -f
```

### Backup et Restauration
```bash
# Sauvegarde des volumes
docker run --rm -v doriav2_mysql_data:/source -v $(pwd):/backup alpine tar czf /backup/mysql_backup.tar.gz -C /source .

# Restauration
docker run --rm -v doriav2_mysql_data:/target -v $(pwd):/backup alpine tar xzf /backup/mysql_backup.tar.gz -C /target
```

## 🎯 Interface SVI Admin

### Accès
- **Interface principale** : http://localhost:8080/svi-admin/
- **API Test** : http://localhost:8080/svi-admin/api/test.php
- **Redirection automatique** : http://localhost:8080/

### Fonctionnalités Actives
- ✅ **Drag & Drop** : SortableJS intégré
- ✅ **Bouton "Ajouter Étape"** : Fonctionnel
- ✅ **Panneau de propriétés** : Dynamique
- ✅ **Multi-contextes** : Onglets pour différents SVI
- ✅ **Gestion audio** : Upload et prévisualisation
- ✅ **API REST** : Endpoints complets
- ✅ **Validation** : Vérification des configurations

## 📚 Documentation

- **Documentation complète** : `docs/SVI_ADMIN_DOCUMENTATION.md`
- **Guide technique** : `docs/SVI_ADMIN_TECHNICAL_GUIDE.md`
- **Ce guide** : `README_VOLUMES.md`

---

## 🎉 Résumé

La configuration avec volumes Docker permet :

1. **Développement en temps réel** sans rebuild
2. **Flexibilité de configuration** selon l'environnement
3. **Facilité de maintenance** et de debugging
4. **Interface SVI Admin moderne** et fonctionnelle
5. **Documentation complète** pour tous les aspects

L'interface est maintenant **entièrement opérationnelle** avec toutes les fonctionnalités demandées (drag & drop, ajout d'étapes, configuration) dans un environnement Docker optimisé pour le développement.
