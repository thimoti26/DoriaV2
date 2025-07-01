# 📞 Guide d'utilisation DoriaV2

## 🚀 Démarrage rapide

### 1. Démarrer la stack
```bash
cd /Users/thibaut/workspace/DoriaV2
docker-compose up -d
```

### 2. Configuration client SIP (Linphone)

> 📖 **Guide détaillé disponible** : Consultez le [TUTORIEL_LINPHONE.md](./TUTORIEL_LINPHONE.md) pour une configuration pas-à-pas complète.

**Configuration rapide :**
- **Serveur SIP :** `localhost:5060` (ou IP de votre machine)
- **Transport :** UDP
- **Utilisateur :** `1001`
- **Mot de passe :** `linphone1001`
- **Domaine :** `localhost`

**Configuration audio recommandée :**
- **Codecs audio :** ulaw (priorité 1), alaw (priorité 2)
- **Désactiver :** G722, G729 si présents
- **Echo cancellation :** Activée

## 🎵 Extensions de test audio

### Tests de base (dans l'ordre recommandé)

1. **Extension 100** - Test simple
   - **Numéro :** `100`
   - **Description :** Message de félicitations Asterisk
   - **Durée :** ~5 secondes
   - **But :** Vérifier connectivité de base

2. **Extension *45** - Test tonalité
   - **Numéro :** `*45`
   - **Description :** Tonalité 440Hz pendant 3 secondes
   - **But :** Vérifier génération audio côté serveur

3. **Extension *44** - Test messages
   - **Numéro :** `*44`
   - **Description :** "Hello World" + "Thank you"
   - **But :** Vérifier lecture fichiers audio

4. **Extension *43** - Test d'écho complet
   - **Numéro :** `*43`
   - **Description :** Test d'écho bidirectionnel
   - **But :** Vérifier audio dans les deux sens

### Extensions utilisateurs

- **1001, 1002, 1003, 1004** : Appels entre utilisateurs
- **8000** : Salle de conférence principale
- **9999** : Serveur vocal interactif (SVI)

## 🔧 Diagnostic en cas de problème

### 1. Pas d'audio (appel connecté mais silence)

```bash
# Lancer le monitoring en temps réel
./debug-audio.sh

# Dans un autre terminal, vérifier les codecs
docker exec -it doriav2-asterisk asterisk -rx "core show codecs audio"

# Vérifier la négociation de codec pendant l'appel
docker exec -it doriav2-asterisk asterisk -rx "core show channels verbose"
```

### 2. Problème de connexion SIP

```bash
# Vérifier les endpoints
docker exec -it doriav2-asterisk asterisk -rx "pjsip show endpoints"

# Vérifier les contacts
docker exec -it doriav2-asterisk asterisk -rx "pjsip show contacts"

# Logs en temps réel
docker exec -it doriav2-asterisk asterisk -rx "core set verbose 5"
docker exec -it doriav2-asterisk asterisk -rx "core set debug 5"
```

### 3. Test complet du système

```bash
./test-stack.sh
```

## 🌐 Interface Web

- **URL :** http://localhost:8080
- **Fonctionnalités :**
  - Dashboard système
  - Gestion utilisateurs SIP
  - Monitoring en temps réel

## 📊 API REST

### Utilisateurs SIP
- **GET** `/api/sip-users.php` - Liste des utilisateurs
- **POST** `/api/sip-users.php` - Créer utilisateur
- **DELETE** `/api/sip-users.php?id=X` - Supprimer utilisateur

### Exemple utilisation API
```bash
# Lister les utilisateurs
curl http://localhost:8080/api/sip-users.php

# Créer un utilisateur
curl -X POST http://localhost:8080/api/sip-users.php \
  -H "Content-Type: application/json" \
  -d '{"username":"1005","password":"test123","realname":"Test User"}'
```

## 🆘 Dépannage courant

### Audio coupé ou haché
1. Vérifier la configuration RTP dans Linphone
2. Utiliser l'IP réelle au lieu de localhost
3. Vérifier les ports UDP 10000-10100

### Pas de son du tout
1. Vérifier les codecs activés (ulaw/alaw)
2. Tester extension *45 (tonalité simple)
3. Vérifier les logs avec `./debug-audio.sh`

### Connection refused
1. Vérifier que les conteneurs sont démarrés
2. Utiliser `docker-compose ps` pour voir l'état
3. Vérifier les ports exposés

## 📋 Logs utiles

```bash
# Logs Asterisk en temps réel
docker exec -it doriav2-asterisk tail -f /var/log/asterisk/messages.log

# Logs conteneur Asterisk
docker logs -f doriav2-asterisk

# Status des services
docker-compose ps
```

---

✨ **Astuce :** Commencez toujours par l'extension 100 pour vérifier que la base fonctionne, puis progressez vers les tests plus complexes.
