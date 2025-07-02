# 🚀 DoriaV2 - Serveur Asterisk avec Docker

## 📋 Description

DoriaV2 est une solution complète de serveur Asterisk containerisé avec Docker, incluant :
- **Asterisk** : Serveur de téléphonie IP avec PJSIP
- **MySQL** : Base de données pour la configuration
- **Apache/PHP** : Interface web de gestion
- **Redis** : Cache et sessions

## ⚡ Démarrage Rapide

```bash
# Démarrer la stack complète
./doria.sh start

# Tester la configuration
./doria.sh test-linphone

# Monitoring en temps réel
./doria.sh debug-audio
```

## 🛠️ Commandes Principales

### Gestion de la Stack
```bash
./doria.sh start           # Démarrer DoriaV2
./doria.sh stop            # Arrêter DoriaV2
./doria.sh restart         # Redémarrer DoriaV2
./doria.sh status          # État des conteneurs
```

### Configuration
```bash
./doria.sh reload          # Recharger toutes les configs
./doria.sh reload-asterisk # Recharger uniquement Asterisk
./doria.sh test-volumes    # Tester les volumes de config
```

### Tests et Validation
```bash
./doria.sh test            # Test complet de la stack
./doria.sh test-linphone   # Validation Linphone
./doria.sh test-network    # Test connectivité réseau
./doria.sh test-audio      # Test audio automatique
```

### Maintenance
```bash
./doria.sh debug-audio     # Monitoring audio temps réel
./doria.sh cleanup         # Nettoyage des fichiers temporaires
./doria.sh docs            # Accéder à la documentation
```

## 📱 Configuration Client (Linphone)

**Paramètres de base :**
- **Utilisateur** : 1001
- **Mot de passe** : linphone1001
- **Domaine** : localhost (ou IP du serveur)
- **Transport** : UDP
- **Port** : 5060

**Guide détaillé :** `./doria.sh docs` → `TUTORIEL_LINPHONE.md`

## 🎛️ Extensions Disponibles

| Extension | Fonction |
|-----------|----------|
| `1001-1004` | Utilisateurs SIP |
| `8000` | Salle de conférence |
| `9999` | Serveur vocal interactif (SVI) |
| `100` | Test de connectivité |
| `*43` | Test d'écho |
| `*44` | Test messages audio |
| `*45` | Test tonalité |
| `*97` | Messagerie vocale |

## 🌐 Interface Web

- **URL** : http://localhost:8080
- **Fonctionnalités** :
  - Dashboard système
  - Gestion utilisateurs SIP
  - Monitoring temps réel

## 📁 Structure du Projet

```
DoriaV2/
├── doria.sh              # Script principal
├── compose.yml           # Configuration Docker
├── scripts/              # Scripts de gestion
│   ├── reload-config.sh  # Rechargement configs
│   ├── test-*.sh         # Scripts de test
│   ├── debug-audio.sh    # Monitoring audio
│   └── ...
├── docs/                 # Documentation
│   ├── TUTORIEL_LINPHONE.md
│   ├── GUIDE_UTILISATEUR.md
│   ├── VOLUMES_CONFIG.md
│   └── ...
├── asterisk/             # Configuration Asterisk
│   ├── config/           # Fichiers de configuration
│   └── sounds/custom/    # Fichiers audio personnalisés
├── mysql/                # Configuration MySQL
├── src/                  # Code source web
└── README.md             # Ce fichier
```

## 🔧 Fonctionnalités Avancées

### Modification à Chaud
- ✅ Volumes Docker pour les configurations
- ✅ Rechargement sans redémarrage
- ✅ Backup automatique des configs

### Tests Automatisés
- ✅ Validation complète de la stack
- ✅ Tests audio progressifs
- ✅ Validation réseau et connectivité

### Monitoring
- ✅ Logs en temps réel
- ✅ Diagnostic automatique
- ✅ Interface web de monitoring

## 📚 Documentation

La documentation complète est disponible dans le dossier `docs/` :

```bash
./doria.sh docs    # Ouvrir le dossier documentation
```

**Guides principaux :**
- **TUTORIEL_LINPHONE.md** : Configuration client SIP
- **GUIDE_UTILISATEUR.md** : Guide d'utilisation général
- **VOLUMES_CONFIG.md** : Gestion des configurations
- **TROUBLESHOOTING_*.md** : Guides de dépannage

## 🆘 Support et Dépannage

### Problèmes Courants

**Stack ne démarre pas :**
```bash
./doria.sh status     # Vérifier l'état
docker compose logs   # Voir les logs
```

**Pas d'audio :**
```bash
./doria.sh test-audio      # Test audio automatique
./doria.sh debug-audio     # Monitoring temps réel
```

**Linphone ne se connecte pas :**
```bash
./doria.sh test-linphone   # Validation configuration
./doria.sh test-network    # Test connectivité réseau
```

### Logs Utiles
```bash
# Logs conteneurs
docker compose logs -f

# Logs Asterisk spécifiques
docker logs -f doriav2-asterisk

# Monitoring audio temps réel
./doria.sh debug-audio
```

## 🎯 Prérequis

- **Docker** et **Docker Compose**
- **Ports libres** : 5060 (SIP), 8080 (Web), 3306 (MySQL)
- **Client SIP** : Linphone recommandé
- **Système** : Linux, macOS, Windows (avec WSL2)

## 🔗 Liens Utiles

- [Linphone Download](https://linphone.org/downloads)
- [Asterisk Documentation](https://docs.asterisk.org)
- [Docker Compose Reference](https://docs.docker.com/compose/)

---

🎉 **DoriaV2 est prêt à l'emploi !** Utilisez `./doria.sh help` pour voir toutes les commandes disponibles.
