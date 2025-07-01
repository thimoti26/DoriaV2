# 📱 Tutoriel Linphone pour DoriaV2

## 🎯 Introduction

Ce guide vous accompagne étape par étape pour configurer Linphone avec votre serveur Asterisk DoriaV2. Linphone est un client SIP gratuit et open-source disponible sur toutes les plateformes.

## 📥 Installation de Linphone

### Windows / macOS / Linux
1. Rendez-vous sur [linphone.org](https://linphone.org/downloads)
2. Téléchargez la version correspondant à votre système
3. Installez en suivant les instructions standard

### Android / iOS
- **Android** : Google Play Store → Rechercher "Linphone"
- **iOS** : App Store → Rechercher "Linphone"

## ⚙️ Configuration Initiale

### 1. Premier Lancement

Au premier démarrage de Linphone :
1. **Choisir** : "Utiliser un compte SIP"
2. **Ne pas** utiliser l'assistant de création de compte
3. Sélectionner "Configuration manuelle"

### 2. Configuration du Compte SIP

#### Paramètres Obligatoires

| Champ | Valeur | Description |
|-------|--------|-------------|
| **Nom d'utilisateur** | `1001` | Numéro de votre extension |
| **Mot de passe** | `linphone1001` | Mot de passe défini dans DoriaV2 |
| **Domaine** | `localhost` | Adresse du serveur (ou IP réelle) |
| **Proxy SIP** | `sip:localhost:5060` | Adresse complète du serveur |

#### Paramètres Avancés

| Paramètre | Valeur | Importance |
|-----------|--------|------------|
| **Transport** | UDP | ⭐ Obligatoire |
| **Port** | 5060 | ⭐ Obligatoire |
| **Outbound proxy** | Activé | 🔸 Recommandé |
| **ICE** | Activé | 🔸 Recommandé |
| **STUN** | Désactivé | 🔸 Pour tests locaux |

### 3. Configuration Audio

#### Codecs Audio (Ordre de Priorité)
1. **PCMU (μ-law)** - Priorité 1 ⭐
2. **PCMA (a-law)** - Priorité 2 ⭐
3. **G722** - Priorité 3 (optionnel)
4. **Désactiver** : G729, Speex, Opus (pour simplifier)

#### Paramètres Audio Avancés
- **Echo cancellation** : ✅ Activé
- **Noise suppression** : ✅ Activé
- **Automatic gain control** : ✅ Activé
- **VAD (Voice Activity Detection)** : ✅ Activé

## 🔧 Configuration Étape par Étape

### Étape 1 : Accès aux Paramètres

#### Sur Desktop
1. Ouvrir Linphone
2. Menu **"Préférences"** ou **"Settings"**
3. Onglet **"Comptes SIP"** ou **"SIP Accounts"**

#### Sur Mobile
1. Ouvrir Linphone
2. Icône **"Paramètres"** (⚙️)
3. **"Comptes"** ou **"Accounts"**

### Étape 2 : Création du Compte

1. **Cliquer** sur "Nouveau compte" ou "Add account"
2. **Sélectionner** "Configuration manuelle"
3. **Remplir** les champs :

```
Nom d'utilisateur : 1001
Mot de passe : linphone1001
Domaine : localhost
```

### Étape 3 : Configuration Avancée

1. **Onglet "Réseau"** ou **"Network"** :
   - Transport : UDP
   - Port : 5060
   - Activer "Outbound proxy"

2. **Onglet "Audio"** :
   - Codec PCMU : Priorité 1
   - Codec PCMA : Priorité 2
   - Désactiver les autres codecs

3. **Onglet "NAT/Firewall"** :
   - Activer ICE
   - Désactiver STUN (pour tests locaux)

### Étape 4 : Test de Connexion

1. **Sauvegarder** la configuration
2. **Redémarrer** Linphone
3. **Vérifier** l'état : "Enregistré" ou "Registered" ✅

## 🧪 Tests de Fonctionnement

### Test 1 : Vérification de l'Enregistrement

**Objectif** : S'assurer que Linphone est connecté au serveur

**Méthode** :
- Dans l'interface Linphone, vérifier le statut
- Doit afficher : **"Enregistré"** ou **"Registered"** ✅

**En cas de problème** :
- Statut "Non enregistré" ❌
- Vérifier l'adresse IP du serveur
- Tester avec l'IP réelle au lieu de `localhost`

### Test 2 : Premier Appel (Extension 100)

**Objectif** : Test de connectivité de base

**Procédure** :
1. Composer le numéro : `100`
2. Appuyer sur **"Appeler"**
3. **Écouter** : Message de félicitations Asterisk
4. **Durée** : ~5 secondes

**Résultat attendu** : ✅ Message audio clair

### Test 3 : Test de Tonalité (*45)

**Objectif** : Vérifier la génération audio serveur

**Procédure** :
1. Composer : `*45`
2. **Écouter** : Tonalité 440Hz pendant 3 secondes

**Résultat attendu** : ✅ Tonalité pure et stable

### Test 4 : Test d'Écho (*43)

**Objectif** : Vérifier l'audio bidirectionnel

**Procédure** :
1. Composer : `*43`
2. **Parler** dans le microphone
3. **Écouter** : Votre voix en retour

**Résultat attendu** : ✅ Écho clair de votre voix

## 🎯 Comptes Utilisateurs Disponibles

| Utilisateur | Mot de passe | Usage |
|-------------|--------------|--------|
| `1001` | `linphone1001` | Utilisateur principal |
| `1002` | `linphone1002` | Test multi-utilisateurs |
| `1003` | `linphone1003` | Test multi-utilisateurs |
| `1004` | `linphone1004` | Test multi-utilisateurs |

## 🔄 Appels Entre Utilisateurs

### Configuration Multi-Comptes

Pour tester les appels entre utilisateurs :

1. **Configurer 2 comptes** sur des appareils différents
2. **Exemple** : 1001 sur ordinateur, 1002 sur mobile
3. **Tester** : Appeler 1002 depuis 1001

### Extensions Spéciales

| Extension | Fonction |
|-----------|----------|
| `8000` | Salle de conférence |
| `9999` | Serveur vocal interactif |
| `*43` | Test d'écho |
| `*44` | Test messages audio |
| `*45` | Test tonalité |
| `100` | Message de félicitations |

## 🚨 Dépannage Courant

### Problème : "Non enregistré"

**Causes possibles** :
- Serveur DoriaV2 non démarré
- Mauvaise adresse IP/domaine
- Firewall bloquant le port 5060

**Solutions** :
```bash
# Vérifier que DoriaV2 fonctionne
docker compose ps

# Tester avec l'IP réelle
ip addr show | grep inet
```

### Problème : "Pas d'audio"

**Causes possibles** :
- Codecs incompatibles
- Problème de ports RTP (10000-10100)
- Configuration NAT

**Solutions** :
1. Vérifier les codecs : ulaw/alaw uniquement
2. Tester extension *45 (tonalité simple)
3. Utiliser l'IP réelle au lieu de localhost

### Problème : "Audio coupé"

**Causes possibles** :
- Problème réseau
- Configuration RTP
- Firewall

**Solutions** :
1. Activer "RTP/AVP" dans Linphone
2. Configurer les ports UDP 10000-10100
3. Désactiver temporairement le firewall

### Problème : "Erreurs PJSIP dans les logs"

**Symptômes** :
```
ERROR[1]: Could not create an object of type 'endpoint' with id '1001'
ERROR[1]: Could not find option suitable for category '1001' named 'local_net'
```

**Cause** :
Configuration PJSIP incorrecte - paramètres de transport dans les endpoints

**Solution** :
```bash
# Recharger la configuration corrigée
./reload-config.sh asterisk

# Vérifier que les endpoints sont chargés
docker exec doriav2-asterisk asterisk -rx "pjsip show endpoints"
```

**Résultat attendu** :
```
Endpoint: 1001/1001    Unavailable   0 of 1
Endpoint: 1002/1002    Unavailable   0 of 1
...
```

### Problème : "Endpoints non disponibles"

**État normal** : `Unavailable` (avant connexion client)
**État problématique** : Endpoints absents de la liste

**Solution** :
1. Vérifier la syntaxe dans `asterisk/config/pjsip.conf`
2. Recharger la configuration : `./reload-config.sh`
3. Valider avec le script : `./test-linphone.sh`

## 🌐 Configuration pour Connexion Distante

### Obtenir l'IP Réelle du Serveur

Pour les connexions depuis d'autres machines ou réseaux :

```bash
# Afficher toutes les interfaces réseau
ip addr show

# Obtenir l'IP principale
hostname -I | awk '{print $1}'

# Alternative sur macOS
ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}'
```

### Configuration Linphone pour IP Distante

**Au lieu de localhost, utiliser l'IP réelle :**

| Champ | Valeur Locale | Valeur Distante |
|-------|---------------|-----------------|
| **Domaine** | `localhost` | `192.168.1.247` (exemple) |
| **Proxy SIP** | `sip:localhost:5060` | `sip:192.168.1.247:5060` |

### Test de Connectivité Réseau

```bash
# Tester la connectivité SIP
telnet 192.168.1.247 5060

# Vérifier les ports RTP (depuis le client)
nmap -p 10000-10100 192.168.1.247
```

### Configuration Firewall

**Ports à ouvrir sur le serveur :**
- **5060/UDP** : SIP signaling
- **5060/TCP** : SIP signaling (optionnel)
- **10000-10100/UDP** : RTP media

**Commandes firewall (Ubuntu/Debian) :**
```bash
sudo ufw allow 5060/udp
sudo ufw allow 10000:10100/udp
```

**Commandes firewall (CentOS/RHEL) :**
```bash
sudo firewall-cmd --permanent --add-port=5060/udp
sudo firewall-cmd --permanent --add-port=10000-10100/udp
sudo firewall-cmd --reload
```
