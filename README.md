# DoriaV2 - Stack Téléphonique Docker

## 📖 Description

DoriaV2 est une solution de téléphonie VoIP complète basée sur Docker, intégrant :
- **Asterisk PBX** : Serveur de téléphonie avec support PJSIP
- **MySQL** : Base de données pour les utilisateurs et configurations
- **Redis** : Cache et sessions
- **Apache/PHP** : Interface web de gestion

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Clients SIP   │    │  Interface Web  │    │    Asterisk     │
│   (Linphone)    │◄──►│   Apache/PHP    │◄──►│      PBX        │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │                        │
                                ▼                        ▼
                       ┌─────────────────┐    ┌─────────────────┐
                       │      Redis      │    │     MySQL       │
                       │     (Cache)     │    │  (Utilisateurs) │
                       └─────────────────┘    └─────────────────┘
```

## 🚀 Démarrage rapide

### 1. Pré-requis
- Docker et Docker Compose installés
- Ports libres : 3306, 5060, 6379, 8080, 5038, 10000-10100

### 2. Lancement des services
```bash
# Démarrer tous les services
docker-compose up -d

# Vérifier le statut
docker ps
```

### 3. Test de la stack
```bash
# Exécuter les tests automatiques
./test-stack.sh
```

### 4. Nettoyage (optionnel)
```bash
# Nettoyer les fichiers temporaires
./cleanup.sh
```

## 📱 Configuration Linphone

### Paramètres de connexion
- **Serveur SIP** : `localhost:5060`
- **Transport** : UDP
- **Authentification** : Mot de passe

### Comptes utilisateurs disponibles
| Utilisateur | Mot de passe    | Extension |
|-------------|-----------------|-----------|
| 1001        | linphone1001    | 1001      |
| 1002        | linphone1002    | 1002      |
| 1003        | linphone1003    | 1003      |
| 1004        | linphone1004    | 1004      |

### Configuration manuelle dans Linphone
1. **Identité SIP** : `1001@localhost:5060`
2. **Nom d'utilisateur** : `1001`
3. **Mot de passe** : `linphone1001`
4. **Domaine** : `localhost:5060`
5. **Transport** : UDP

## 📞 Extensions et fonctionnalités

### Extensions spéciales
- **\*43** : Test d'écho (pour vérifier l'audio)
- **100** : Message de démonstration
- **8000** : Salle de conférence
- **1001-1004** : Appels directs entre utilisateurs

### Tests audio
1. Composez `*43` depuis Linphone
2. Parlez dans le microphone
3. Vous devriez entendre votre voix en retour

## 🌐 Interfaces web

### Interface principale
- **URL** : http://localhost:8080
- **Fichiers** : Gestion des utilisateurs SIP

### Tests de connectivité
- **API** : http://localhost:8080/api/
- **Test connexions** : http://localhost:8080/test_connections.php

## 🗄️ Base de données

### Accès MySQL
```bash
# Connexion directe
docker exec -it doriav2-mysql mysql -u doriav2_user -p doriav2

# Mot de passe : doriav2_password
```

### Structure des données
- **Base** : `doriav2`
- **Table principale** : `users`
- **Utilisateur** : `doriav2_user`

## 🔧 Configuration avancée

### Fichiers de configuration principaux
```
asterisk/config/
├── pjsip.conf          # Configuration SIP/RTP
├── extensions.conf     # Plan de numérotation
├── odbc.ini           # Connexion base de données
├── res_odbc.conf      # Ressources ODBC
└── ...

mysql/
├── init.sql           # Initialisation base
└── my.cnf            # Configuration MySQL

src/
├── index.php         # Interface web principale
├── api/              # API REST
└── ...
```

### Paramètres NAT et réseau
La configuration utilise automatiquement la résolution DNS Docker :
- **Réseau local** : `doriav2_network`
- **Adresse externe** : `doriav2-asterisk` (nom du conteneur)

## 🛠️ Maintenance

### Commandes utiles
```bash
# Voir les logs
docker logs doriav2-asterisk
docker logs doriav2-mysql

# Redémarrer un service
docker-compose restart asterisk

# Shell dans un conteneur
docker exec -it doriav2-asterisk bash

# CLI Asterisk
docker exec -it doriav2-asterisk asterisk -r
```

### Commandes Asterisk CLI
```
# Voir les endpoints connectés
pjsip show endpoints

# Voir les appels actifs
core show channels

# Recharger la configuration
module reload res_pjsip.so

# Test ODBC
odbc show all
```

## 🐛 Résolution de problèmes

### Problèmes audio
1. Vérifier la configuration NAT dans `pjsip.conf`
2. Tester avec `*43` (écho)
3. Vérifier les ports RTP (10000-10100)

### Problèmes de connexion SIP
1. Vérifier que le port 5060 est ouvert
2. Contrôler les credentials dans Linphone
3. Consulter les logs Asterisk

### Problèmes base de données
1. Vérifier la connexion ODBC : `odbc show all`
2. Tester la connexion MySQL directement
3. Vérifier les permissions utilisateur

## 📊 Monitoring

### Ports exposés
- **3306** : MySQL
- **5038** : Asterisk Manager Interface
- **5060** : SIP (UDP/TCP)
- **6379** : Redis
- **8080** : Interface web
- **10000-10100** : RTP (UDP)

### Health checks
- MySQL et Redis ont des health checks automatiques
- Asterisk et Apache sont monitorés par Docker

## 🔒 Sécurité

### Recommandations
- Changez les mots de passe par défaut en production
- Limitez l'accès aux ports sensibles
- Utilisez HTTPS pour l'interface web
- Configurez un firewall approprié

### Variables d'environnement sensibles
- `DB_PASSWORD` : Mot de passe MySQL
- Mots de passe SIP dans `pjsip.conf`

## 📝 Développement

### Structure du projet
```
DoriaV2/
├── asterisk/           # Configuration Asterisk
├── mysql/             # Configuration MySQL  
├── src/               # Code source web
├── compose.yml        # Orchestration Docker
├── test-stack.sh      # Tests automatiques
├── cleanup.sh         # Nettoyage projet
└── README.md          # Documentation
```

### Tests automatiques
Le script `test-stack.sh` vérifie :
- État des conteneurs Docker
- Connectivité réseau
- Configuration Asterisk
- Services de base de données
- Interface web

## � Licence

