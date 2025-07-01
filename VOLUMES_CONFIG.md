# 📁 Configuration par Points de Montage - DoriaV2

## 🎯 Objectif

Cette mise à jour ajoute des **points de montage directs** pour tous les fichiers de configuration, permettant de modifier les configurations **sans reconstruire les conteneurs**.

## 🔄 Nouveaux Points de Montage

### Asterisk
```yaml
# Fichiers de configuration principaux
- ./asterisk/config/extensions.conf:/etc/asterisk/extensions.conf:ro
- ./asterisk/config/pjsip.conf:/etc/asterisk/pjsip.conf:ro
- ./asterisk/config/modules.conf:/etc/asterisk/modules.conf:ro
- ./asterisk/config/asterisk.conf:/etc/asterisk/asterisk.conf:ro
- ./asterisk/config/rtp.conf:/etc/asterisk/rtp.conf:ro
- ./asterisk/config/manager.conf:/etc/asterisk/manager.conf:ro

# Fichiers de base de données
- ./asterisk/config/res_odbc.conf:/etc/asterisk/res_odbc.conf:ro
- ./asterisk/config/cdr_odbc.conf:/etc/asterisk/cdr_odbc.conf:ro
- ./asterisk/config/extconfig.conf:/etc/asterisk/extconfig.conf:ro
- ./asterisk/config/odbc.ini:/etc/odbc.ini:ro

# Fichiers audio personnalisés
- ./asterisk/sounds/custom:/var/lib/asterisk/sounds/custom:ro
```

### MySQL
```yaml
# Configuration MySQL personnalisée
- ./mysql/my.cnf:/etc/mysql/conf.d/custom.cnf:ro
```

### Web/Apache
```yaml
# Code source (déjà configuré)
- ./src:/var/www/html
```

## 🚀 Migration

### 1. Appliquer les nouveaux volumes
```bash
./update-volumes.sh
```

Ce script va :
- ✅ Sauvegarder les configurations actuelles
- ✅ Récupérer les configs depuis les conteneurs si manquantes
- ✅ Redémarrer avec les nouveaux points de montage
- ✅ Tester que tout fonctionne

### 2. Alternative manuelle
```bash
# Arrêter les conteneurs
docker-compose down

# Redémarrer avec les nouveaux volumes
docker-compose up -d
```

## ⚡ Utilisation

### Modifier une configuration
```bash
# Exemple : modifier le dialplan
nano ./asterisk/config/extensions.conf

# Recharger sans redémarrer le conteneur
./reload-config.sh asterisk
```

### Recharger les configurations
```bash
# Recharger tout
./reload-config.sh

# Recharger seulement Asterisk
./reload-config.sh asterisk

# Recharger seulement MySQL (nécessite redémarrage)
./reload-config.sh mysql

# Recharger seulement Apache
./reload-config.sh web

# Tester les configurations
./reload-config.sh test
```

## 📋 Fichiers de Configuration Disponibles

### Asterisk (`./asterisk/config/`)
- **extensions.conf** - Dialplan (extensions, contextes)
- **pjsip.conf** - Configuration SIP (endpoints, transports)
- **modules.conf** - Modules à charger
- **asterisk.conf** - Configuration générale
- **rtp.conf** - Configuration RTP/audio
- **manager.conf** - Interface de management
- **res_odbc.conf** - Connexion base de données
- **cdr_odbc.conf** - Enregistrement des appels
- **extconfig.conf** - Configuration externe
- **odbc.ini** - Configuration ODBC

### MySQL (`./mysql/`)
- **my.cnf** - Configuration MySQL personnalisée

### Audio (`./asterisk/sounds/custom/`)
- Tous vos fichiers audio personnalisés

## 🔄 Commandes de Rechargement

### Via script (recommandé)
```bash
./reload-config.sh asterisk    # Recharge Asterisk
./reload-config.sh mysql       # Info pour MySQL
./reload-config.sh web         # Recharge Apache
./reload-config.sh test        # Test les configs
```

### Manuelles dans les conteneurs
```bash
# Asterisk
docker exec doriav2-asterisk asterisk -rx "dialplan reload"
docker exec doriav2-asterisk asterisk -rx "pjsip reload"
docker exec doriav2-asterisk asterisk -rx "module reload"

# Apache
docker exec doriav2-web apache2ctl graceful

# MySQL (nécessite redémarrage)
docker-compose restart mysql
```

## 🧪 Tests

### Après modification
```bash
# Test complet
./test-stack.sh

# Test audio spécifique
./test-audio-auto.sh

# Monitoring en temps réel
./debug-audio.sh
```

## ⚠️ Notes Importantes

### Permissions
- Les fichiers sont montés en **lecture seule** (`:ro`)
- Cela empêche les conteneurs de modifier vos fichiers locaux
- Modifiez toujours depuis l'hôte, pas depuis le conteneur

### Redémarrages Nécessaires
Certaines modifications nécessitent un redémarrage :
- **MySQL** : Changements dans `my.cnf`
- **Asterisk** : Changements dans `modules.conf`
- **Réseaux** : Changements dans les transports PJSIP

### Backup Automatique
- Le script `update-volumes.sh` crée automatiquement un backup
- Les backups sont dans `./backup-configs-YYYYMMDD-HHMMSS/`

## 🎯 Avantages

### ✅ Développement Plus Rapide
- Modification directe des fichiers
- Rechargement à chaud
- Pas de reconstruction d'image

### ✅ Debugging Facilité
- Logs en temps réel avec `./debug-audio.sh`
- Modifications immédiates pour tests

### ✅ Configuration Persistante
- Configurations versionnées avec Git
- Sauvegarde automatique
- Restauration facile

## 🔍 Diagnostic

### Vérifier les montages
```bash
# Voir les volumes montés
docker inspect doriav2-asterisk | grep -A 20 "Mounts"

# Vérifier qu'un fichier est bien monté
docker exec doriav2-asterisk ls -la /etc/asterisk/extensions.conf
```

### Problèmes Courants

#### Fichier non trouvé
```bash
# Vérifier que le fichier existe côté hôte
ls -la ./asterisk/config/extensions.conf

# Le récupérer du conteneur si nécessaire
docker cp doriav2-asterisk:/etc/asterisk/extensions.conf ./asterisk/config/
```

#### Configuration non prise en compte
```bash
# Recharger la configuration
./reload-config.sh asterisk

# Ou redémarrer le conteneur spécifique
docker-compose restart asterisk
```

---

🎉 **Avec cette configuration, vous pouvez maintenant modifier les fichiers de configuration en temps réel et voir les changements immédiatement !**
