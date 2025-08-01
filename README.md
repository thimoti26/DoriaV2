# 📞 DoriaV2 - Système SVI (IVR) Avancé

**Version**: 2.0  
**Status**: ✅ **Projet organisé et prêt pour production**  
**Date**: Juillet 2025

## 🎯 Vue d'ensemble

DoriaV2 est un système complet de **Serveur Vocal Interactif (SVI/IVR)** basé sur **Asterisk**, avec une interface d'administration web moderne pour la gestion visuelle des menus vocaux, des flux d'appels et des fichiers audio multilingues.

## ✨ Fonctionnalités principales

### 🎨 Interface d'administration SVI
- **Éditeur visuel** avec drag & drop pour créer des flux d'appels
- **Navigation entre onglets** : Configuration, Audio, Simulation, Aide
- **Positionnement automatique** des nœuds avec grille anti-collision
- **Panel de visualisation** de la configuration Asterisk en temps réel
- **Gestion multilingue** (Français/Anglais) des fichiers audio
- **Simulation interactive** du parcours appelant

### 🔧 Backend robuste
- **API REST** complète pour la gestion de configuration
- **Upload sécurisé** de fichiers audio avec validation
- **Validation syntaxique** des configurations Asterisk
- **Rechargement automatique** d'Asterisk sans interruption
- **Base de données MySQL** pour la persistance des données

### 🐳 Infrastructure Docker
- **Containerisation complète** avec Docker Compose
- **Volumes persistants** pour les configurations et audio
- **Réseau isolé** pour la sécurité
- **Scripts d'automatisation** pour le déploiement

## 🚀 Démarrage rapide

### Prérequis
- Docker et Docker Compose
- Port 8080 disponible (interface web)
- Port 5060 disponible (SIP)

### Installation et lancement
```bash
# Cloner le projet
git clone <url-du-repo> DoriaV2
cd DoriaV2

# Démarrer l'environnement complet
./doria.sh start

# Vérifier le statut
./doria.sh status
```

### Accès aux interfaces
- **Interface SVI Admin** : http://localhost:8080/svi-admin/
- **Dashboard principal** : http://localhost:8080/
- **Statut système** : http://localhost:8080/system-status.html

## 🏗️ DoriaV2 - Plateforme SVI Complète

## 📁 Structure du Projet

```
DoriaV2/
├── 📄 compose.yml              # Configuration Docker Compose principale
├── � doria.sh                 # Script principal d'entrée
│
├── 📂 frontend/                # Applications Frontend
│   ├── angular/                # Éditeur SVI Angular moderne
│   │   ├── src/                # Code source TypeScript
│   │   ├── Dockerfile          # Container de développement
│   │   ├── Dockerfile.nginx    # Container de production
│   │   └── README.md           # Documentation Angular
│   └── README.md               # Documentation Frontend
│
├── 📂 backend/                 # Applications Backend
│   ├── php/                    # Code PHP/API
│   │   ├── svi-admin/          # Interface d'administration
│   │   ├── api/                # API REST
│   │   └── index.php           # Point d'entrée
│   ├── Dockerfile              # Container PHP + Apache
│   └── README.md               # Documentation Backend
│
├── 📂 asterisk/               # Configuration Asterisk
├── 📂 mysql/                  # Configuration MySQL
├── 📂 docs/                   # Documentation complète
├── 📂 tests/                  # Tests et diagnostics
└── 📂 scripts/               # Scripts d'administration
```

## � Démarrage Rapide

### Stack Complète (recommandé)
```bash
./doria.sh
# Accès :
# - SVI Admin : http://localhost:8080
# - Éditeur Angular : via docker-compose-angular.yml
```

### Frontend Angular uniquement
```bash
cd frontend/angular
npm install
npm start
# Accès : http://localhost:4200
```

### Backend PHP uniquement
```bash
docker-compose up web mysql redis
# Accès : http://localhost:8080
```

## 📚 Documentation

### 🎯 Guides d'utilisation
- **[Guide Navigation SVI](docs/guides/GUIDE_NAVIGATION_SVI.md)** - Utilisation de l'éditeur visuel
- **[Guide Drag & Drop](docs/guides/GUIDE_DRAG_DROP_SVI.md)** - Fonctionnalités de glisser-déposer
- **[Guide Visualisation Config](docs/guides/CONFIG_VISUALIZATION_GUIDE.md)** - Panel de configuration

### 💡 Exemples
- **[Exemple Navigation Complète](docs/examples/EXEMPLE_NAVIGATION_COMPLETE.md)** - Cas d'usage détaillé

### 🧪 Tests et validation
- **[Résultats Tests SVI](docs/tests/SVI_ADMIN_TEST_RESULTS.md)** - Résultats des tests automatisés
- **[Améliorations Complétées](docs/tests/AMELIORATIONS_COMPLETEES.md)** - Changelog des améliorations

## 🧪 Tests et validation

### Tests automatisés
```bash
# Tests fonctionnalités SVI
./tests/svi/test-svi-improvements.sh

# Tests système complets
./tests/system/test-final.sh

# Tests réseau et connectivité
./tests/network/test-network.sh

# Débogage interface (onglets, drag&drop)
./tests/debug/test-tabs-quick.sh
```

### Validation manuelle
1. **Interface SVI** : Navigation entre onglets, création de nœuds, drag & drop
2. **Configuration** : Visualisation temps réel, copie de configuration
3. **Audio** : Upload de fichiers, gestion multilingue
4. **Simulation** : Test du parcours appelant

## 🔧 Commandes utiles

### Gestion du système
```bash
# Démarrer/Arrêter
./doria.sh start
./doria.sh stop

# Redémarrer un service spécifique
./doria.sh restart asterisk
./doria.sh restart web

# Voir les logs
./doria.sh logs

# Nettoyer l'environnement
./doria.sh clean
```

### Maintenance
```bash
# Organiser le projet
./scripts/organize-project.sh

# Nettoyer les fichiers temporaires
./scripts/cleanup.sh

# Recharger la configuration Asterisk
./scripts/reload-config.sh
```

## 🏗️ Architecture technique

### Stack technologique
- **Frontend** : HTML5, CSS3, JavaScript ES6+
- **Backend** : PHP 8.1, Apache
- **Base de données** : MySQL 8.0
- **PBX** : Asterisk 20
- **Containerisation** : Docker & Docker Compose
- **Reverse Proxy** : Apache (intégré)

### Composants principaux
1. **Asterisk PBX** - Moteur de téléphonie
2. **Interface Web** - Administration et configuration
3. **Base de données** - Stockage des configurations
4. **API REST** - Communication frontend/backend
5. **Gestionnaire de fichiers** - Upload et gestion audio

## 🤝 Contribution

### Standards de développement
- Code documenté et commenté
- Tests automatisés pour nouvelles fonctionnalités
- Respect de la structure de projet organisée
- Documentation mise à jour

### Workflow de développement
1. Développement en local avec Docker
2. Tests automatisés avec les scripts fournis
3. Validation manuelle de l'interface
4. Documentation des nouvelles fonctionnalités

## 📊 Status du projet

**✅ COMPLÉTÉ** :
- Interface d'administration SVI complète
- Fonctionnalités drag & drop et navigation
- Configuration multilingue
- Tests automatisés
- Documentation organisée
- Containerisation Docker

**🎯 PRÊT POUR** :
- Déploiement en production
- Formation utilisateurs
- Maintenance et évolutions

## 📞 Support

Pour toute question ou assistance :
1. Consulter la documentation dans `docs/`
2. Vérifier les guides d'utilisation
3. Exécuter les tests de diagnostic
4. Consulter les logs avec `./doria.sh logs`

---

**Projet organisé et maintenu** - Juillet 2025  
**Version stable et prête pour production** ✅
