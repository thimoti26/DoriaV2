# 📞 DoriaV2 - Système Asterisk/FreePBX Moderne

Système de serveur vocal interactif (IVR) basé sur Asterisk avec interface web moderne et complète.

## 🚀 Démarrage rapide

```bash
# Interface web moderne (NOUVEAU)
./start-web-interface.sh     # 🌐 Interface web complète sur http://localhost:8081

# Gestion du système Asterisk
./asterisk-ctl.sh start      # ▶️  Démarrer le système
./asterisk-ctl.sh status     # 📊 Vérifier l'état
./asterisk-ctl.sh stop       # ⏹️  Arrêter le système

# Ou utiliser docker compose directement
docker compose up -d         # 🐳 Démarrer conteneurs
docker compose ps            # 📋 État des conteneurs
docker compose down          # 🛑 Arrêter conteneurs
```

## 🌐 Interface Web Moderne (NOUVEAU)

### Accès à l'interface
- **Interface web**: http://localhost:8081
- **API REST**: http://localhost:8081/api/
- **Guide complet**: [web-interface/README.md](web-interface/README.md)

### Fonctionnalités principales
- 📊 **Tableau de bord** temps réel avec métriques système
- 📞 **Gestion extensions** avec configuration Linphone intégrée
- ⚙️ **Administration système** (Docker, Asterisk, logs)
- 📄 **Journaux colorisés** en temps réel
- 📱 **Design responsive** optimisé mobile
- 🔔 **Notifications intelligentes** avec Toast
- ⌨️ **Raccourcis clavier** pour navigation rapide

### Technologies
- Bootstrap 5.3 + Font Awesome 6.4
- JavaScript ES6+ avec architecture modulaire
- API REST Python/PHP avec gestion CORS
- CSS3 avec animations et thème adaptatif

## 📋 Configuration

- **Asterisk** : Port SIP 5060/UDP, AMI 5038/TCP, RTP 10000-20000/UDP
- **Interface Web** : http://localhost:8081 (moderne) 
- **Extension test** : 1000 (osmo/osmoosmo)
- **Base de données** : MariaDB 10.5
- **Image Asterisk** : Ubuntu 20.04 avec installation personnalisée

## 📁 Structure du projet (organisée)

```
├── asterisk-ctl.sh              # 🎯 Script principal de gestion
├── start-web-interface.sh       # 🌐 Lanceur interface web moderne
├── compose.yml                  # 🐳 Configuration Docker Compose
├── README.md                    # 📖 Ce fichier
├── asterisk-config/             # ⚙️  Configuration Asterisk
│   ├── asterisk.conf            #     Configuration principale
│   ├── sip.conf                 #     Extensions SIP (osmo)
│   ├── extensions.conf          #     Plan de numérotation
│   └── manager.conf             #     Interface AMI
├── web-interface/               # 🌐 Interface web moderne (NOUVEAU)
│   ├── index.html               #     Interface principale Bootstrap 5
│   ├── styles.css               #     Styles personnalisés avec animations
│   ├── script.js                #     JavaScript ES6+ modulaire
│   ├── server.py                #     Serveur Python avec API REST
│   ├── api.php                  #     Alternative PHP pour l'API
│   └── README.md                #     Documentation complète interface
├── scripts/                     # 🛠️  Tous les scripts (50+ fichiers)
│   ├── manage.sh                #     Script historique principal
│   ├── create-osmo-extension.sh #     Création extension
│   ├── configure-linphone.sh    #     Config client SIP
│   └── ...                     #     Diagnostic, test, réparation
├── docs/                        # 📚 Documentation complète (13 fichiers)
│   ├── GUIDE_FINAL.md           #     Guide complet
│   ├── LINPHONE_SETUP.md        #     Configuration client
│   └── ...                     #     Résolution problèmes, IVR
└── backup/                      # 🗄️  Sauvegardes et fichiers obsolètes
```

## 🔧 Commandes principales

```bash
# Interface web moderne
./start-web-interface.sh     # 🌐 Lancer interface web (recommandé)
./test-web-interface.sh      # 🧪 Tester toutes les fonctionnalités

# Gestion système Asterisk
./asterisk-ctl.sh start      # ▶️  Démarrer tout le système
./asterisk-ctl.sh setup      # ⚙️  Configurer l'extension osmo
./asterisk-ctl.sh test       # 🧪 Tester la connectivité
./asterisk-ctl.sh linphone   # 📱 Guide configuration Linphone
./asterisk-ctl.sh logs       # 📄 Voir les logs Asterisk
./asterisk-ctl.sh clean      # 🧹 Nettoyage complet
```

## 🎯 Nouveautés Interface Web v2.0

### 🚀 Lancement rapide
```bash
./start-web-interface.sh
# Interface accessible sur http://localhost:8081
```

### ✨ Fonctionnalités clés
- **Dashboard temps réel** avec statut Asterisk/Docker
- **Configuration Linphone** intégrée avec guide pas à pas
- **API REST complète** pour automatisation
- **Logs colorisés** Asterisk et Docker en temps réel
- **Responsive design** mobile-friendly
- **Thème moderne** avec animations CSS3

### 🔌 API REST disponible
```bash
curl http://localhost:8081/api/status          # Statut système
curl -X POST http://localhost:8081/api/control/start  # Démarrer Asterisk
curl http://localhost:8081/api/logs/asterisk   # Logs Asterisk
curl -X POST http://localhost:8081/api/docker/up      # Démarrer conteneurs
```

## 📱 Configuration Linphone (automatisée)

## 📱 Configuration Linphone (automatisée)

### Via l'interface web (recommandé)
1. Aller sur http://localhost:8081
2. Cliquer sur l'onglet "Extensions"
3. Cliquer sur "Configuration Linphone"
4. Suivre le guide intégré avec paramètres pré-remplis

### Configuration manuelle
1. **Serveur** : `localhost:5060` (ou IP de votre machine)
2. **Nom d'utilisateur** : `osmo`
3. **Mot de passe** : `osmoosmo`
4. **Extension** : `1000`
5. **Transport** : `UDP`

### Numéros de test
- `*43` - Test d'écho (recommandé pour premier test)
- `*97` - Messagerie vocale
- `123` - Message de bienvenue
- `1000` - Appeler l'extension osmo

## 🆘 Résolution de problèmes

### Interface web non accessible
```bash
# Vérifier le port utilisé
./start-web-interface.sh 8082  # Essayer un autre port

# Vérifier Python
python3 --version

# Vérifier les logs
tail -f web-interface/logs/*.log
```

### Asterisk ne démarre pas
```bash
./asterisk-ctl.sh status    # Vérifier l'état
./asterisk-ctl.sh clean     # Nettoyage complet
docker compose logs asterisk  # Voir les erreurs
```

## 📚 Documentation complète

- **Interface Web** : [web-interface/README.md](web-interface/README.md)
- **Guide complet** : [docs/GUIDE_FINAL.md](docs/GUIDE_FINAL.md)
- **Configuration Linphone** : [docs/LINPHONE_SETUP.md](docs/LINPHONE_SETUP.md)
- **Configuration IVR** : [docs/IVR_CONFIGURATION.md](docs/IVR_CONFIGURATION.md)
- **Résolution problèmes** : [docs/RESOLUTION_SUCCES.md](docs/RESOLUTION_SUCCES.md)

## 🎉 État du projet

### ✅ Fonctionnel
- ✅ Interface web moderne complète
- ✅ Configuration Asterisk simplifiée
- ✅ Extension osmo (1000) avec SIP
- ✅ API REST pour automatisation
- ✅ Tests automatisés
- ✅ Documentation complète
- ✅ Scripts de gestion organisés

### 🔄 En cours / Prochaines étapes
- 🔄 Résolution démarrage conteneur Asterisk
- 📞 Tests d'appels réels avec Linphone
- 🎯 Configuration IVR avancée
- 📈 Monitoring et métriques avancées

---

🎯 **DoriaV2** - Système Asterisk moderne avec interface web complète
4. **Transport** : UDP

## 🧪 Tests d'appels

- `*43` - Test d'écho
- `*97` - Messagerie vocale
- `123` - Message de test
- `1000` - Appel vers l'extension osmo

## 📚 Documentation

- `docs/GUIDE_FINAL.md` - Guide complet
- `docs/LINPHONE_SETUP.md` - Configuration client SIP
- `docs/IVR_CONFIGURATION.md` - Configuration IVR avancée
- `docs/RESOLUTION_SUCCES.md` - Résolution des problèmes

## 🛠️ Scripts disponibles

Plus de 50 scripts dans le dossier `scripts/` pour :
- Création et gestion d'extensions
- Diagnostic et réparation
- Configuration clients SIP
- Tests de connectivité
- Gestion système

---

**Version** : Docker Compose avec Asterisk simple (andrius/asterisk:latest)
**Dernière mise à jour** : 24 juin 2025
**Statut** : Projet nettoyé et organisé ✅
