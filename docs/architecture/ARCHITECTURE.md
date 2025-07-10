# 🏗️ Architecture DoriaV2

## 📁 Structure du Projet

```
DoriaV2/
├── 📄 compose.yml              # Configuration Docker Compose
├── 🚀 doria.sh                 # Script principal d'entrée
├── 📋 .gitignore              # Fichiers ignorés par Git
├── 📋 .dockerignore           # Fichiers ignorés par Docker
│
├── 📂 asterisk/               # Configuration Asterisk
│   ├── 🐳 Dockerfile          # Image Asterisk personnalisée
│   ├── 🎵 generate_audio.sh   # Génération fichiers audio
│   ├── 📁 config/             # Fichiers de configuration
│   │   ├── asterisk.conf
│   │   ├── extensions.conf    # Plan de numérotation (SVI 9999)
│   │   ├── pjsip.conf         # Configuration SIP
│   │   └── ...
│   └── 📁 sounds/
│       └── 📁 custom/         # Fichiers audio personnalisés
│
├── 🗄️ mysql/                  # Base de données
│   ├── 🐳 Dockerfile          # Image MySQL personnalisée
│   ├── 📄 init.sql            # Script d'initialisation
│   └── 📄 my.cnf              # Configuration MySQL
│
├── 🌐 src/                    # Interface web PHP
│   ├── 📄 index.php           # Page d'accueil
│   ├── 📄 dashboard.php       # Tableau de bord
│   └── 📁 api/               # API REST
│
├── 🛠️ scripts/               # Scripts utilitaires
│   ├── 📄 README.md           # Documentation scripts
│   ├── 🔄 reload-config.sh    # Rechargement configurations
│   ├── 📦 update-volumes.sh   # Gestion volumes
│   └── 🧹 cleanup.sh          # Nettoyage système
│
├── 🧪 tests/                 # Tests et validation
│   ├── 📄 README.md           # Documentation tests
│   ├── 🔍 test-stack.sh       # Test complet stack
│   ├── 🎵 test-audio-auto.sh  # Test audio automatique
│   ├── 📞 test-linphone.sh    # Validation Linphone
│   ├── 🌐 test-network.sh     # Test connectivité
│   ├── 💾 test-volumes.sh     # Test volumes
│   ├── ✅ test-final.sh       # Test final
│   └── 🔊 debug-audio.sh      # Monitoring audio
│
└── 📚 docs/                  # Documentation
    ├── 📄 README.md           # Documentation principale
    ├── 📋 INDEX.md            # Index de navigation
    ├── 📖 GUIDE_UTILISATEUR.md
    ├── 📱 TUTORIEL_LINPHONE.md
    ├── 🎛️ GUIDE_SVI_9999.md
    ├── 🔧 TROUBLESHOOTING_*.md
    └── ...
```

## 🎯 Composants Principaux

### 📞 Asterisk (PBX)
- **Port** : 5060 (SIP), 10000-10100 (RTP)
- **Extensions** : 1001-1004 (utilisateurs), 9999 (SVI)
- **Fonctionnalités** : IVR, conférence, messagerie vocale

### 🗄️ MySQL (Base de Données)  
- **Port** : 3306
- **Usage** : CDR, configuration, logs

### 🌐 Apache + PHP (Interface Web)
- **Port** : 8080
- **Fonctionnalités** : Dashboard, API, gestion

## 🚀 Points d'Entrée

### Script Principal
```bash
./doria.sh [commande]
```

### Commandes Principales
- **start/stop/restart** : Gestion containers
- **test** : Validation complète
- **reload** : Rechargement config
- **debug-audio** : Monitoring temps réel

### Tests Automatisés
```bash
./doria.sh test           # Test complet
./doria.sh test-audio     # Test audio
./doria.sh test-linphone  # Config client
```

## 📊 Flux de Données

```
Client SIP (Linphone) 
    ↓ SIP (5060)
Asterisk Container
    ↓ CDR/Logs
MySQL Container
    ↓ API/Web
Apache+PHP Container
    ↓ HTTP (8080)
Interface Web
```

## 🔧 Configuration

### Volumes Docker
- **asterisk-config** : `/etc/asterisk`
- **asterisk-sounds** : `/var/lib/asterisk/sounds`
- **mysql-data** : `/var/lib/mysql`
- **web-src** : `/var/www/html`

### Réseaux
- **doria-network** : Réseau interne (bridge)
- **Ports exposés** : 5060, 8080, 3306

## 📋 Maintenance

### Quotidienne
```bash
./doria.sh cleanup       # Nettoyage
```

### Hebdomadaire  
```bash
./doria.sh test          # Validation complète
./doria.sh update-volumes # Mise à jour config
```

### En cas de problème
```bash
./doria.sh debug-audio   # Monitoring audio
# Consulter docs/TROUBLESHOOTING_*.md
```

---

📚 **Documentation complète** : Consultez le dossier `docs/` pour tous les guides détaillés.
