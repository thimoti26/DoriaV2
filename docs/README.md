# DoriaV2 - Système Asterisk/FreePBX avec IVR

## Description

Ce projet déploie un système de téléphonie complet basé sur Asterisk et FreePBX avec serveur vocal interactif (IVR) utilisant Docker Compose.

## Architecture

- **FreePBX** : Interface web de gestion Asterisk (tiredofit/freepbx:latest)
- **MariaDB 10.5** : Base de données pour la persistance des configurations
- **Réseau Docker** : Réseau isolé `pbxnet` pour la communication inter-services

## Ports exposés

- **8080** : Interface web FreePBX (HTTP)
- **5060/UDP** : SIP (Session Initiation Protocol)
- **10000-20000/UDP** : RTP (Real-time Transport Protocol)

## Configuration

### Variables d'environnement

```yaml
# FreePBX
ADMIN_USER=admin
ADMIN_PASS=admin123
DB_HOST=db
DB_NAME=asterisk
DB_USER=asterisk
DB_PASS=asteriskpass
RTP_START=10000
RTP_FINISH=20000

# MariaDB
MYSQL_ROOT_PASSWORD=rootpass
MYSQL_DATABASE=asterisk
MYSQL_USER=asterisk
MYSQL_PASSWORD=asteriskpass
```

## Démarrage

```bash
# Démarrer les services
docker compose up -d

# Vérifier l'état
docker compose ps

# Voir les logs
docker compose logs freepbx

# Arrêter les services
docker compose down
```

## Accès à l'interface

- **URL** : http://localhost:8080/admin
- **Utilisateur** : osmo
- **Mot de passe** : osmoosmo

## Volumes persistants

- `freepbx_data` : Données FreePBX (/data)
- `db_data` : Base de données MariaDB (/var/lib/mysql)

## Configuration IVR

Une fois connecté à l'interface FreePBX :

1. Aller dans **Applications** → **IVR**
2. Créer un nouveau menu IVR
3. Configurer les options du menu vocal
4. Associer les touches aux actions (extensions, files d'attente, etc.)
5. Enregistrer les prompts vocaux personnalisés

## Configuration Linphone (Client SIP)

### Configuration rapide
```bash
# Guide interactif
./setup-linphone.sh

# Test de connectivité SIP
./manage.sh sip-test

# Voir les extensions configurées
./manage.sh extensions
```

### Paramètres Linphone
- **Serveur** : `sip:localhost:5060`
- **Utilisateur** : `osmo` (configuré dans FreePBX)
- **Mot de passe** : `osmoosmo`
- **Transport** : UDP

📚 **Guide complet** : Voir `LINPHONE_SETUP.md`

## Modules installés

- Framework & Core
- CDR (Call Detail Records)
- Backup & Restore
- Call Recording
- Conferences
- Dashboard
- Feature Code Admin
- File Store
- Voicemail
- User Control Panel (UCP)
- Certificate Manager
- User Manager

## Sécurité

⚠️ **Important** : Ce setup utilise des certificats auto-signés. Pour un environnement de production :

1. Configurez des certificats SSL valides
2. Changez les mots de passe par défaut
3. Configurez le firewall approprié
4. Activez l'authentification forte

## Troubleshooting

### Vérification des services
```bash
# État des conteneurs
docker compose ps

# Logs détaillés
docker compose logs -f freepbx
docker compose logs -f db

# Test de connectivité
curl -I http://localhost:8080
```

### Reset complet
```bash
# Arrêter et supprimer tout
docker compose down -v
docker system prune -f

# Redémarrer
docker compose up -d
```

## Support

Le système est basé sur :
- [FreePBX Official Documentation](https://wiki.freepbx.org/)
- [Asterisk Documentation](https://docs.asterisk.org/)
- [TiredOfIT FreePBX Docker](https://github.com/tiredofit/docker-freepbx)
