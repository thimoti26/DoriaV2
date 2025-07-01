# Guide de Dépannage Audio - DoriaV2

## 🎯 Problème : Pas de son sur l'extension *43

### ✅ Vérifications effectuées :
1. **Fichiers audio** : ✅ Présents (demo-echotest.gsm trouvé)
2. **Codecs Asterisk** : ✅ Disponibles (ulaw, alaw, gsm, etc.)
3. **Endpoint PJSIP** : ✅ 1001 connecté et disponible
4. **Configuration extensions** : ✅ Corrigée et rechargée
5. **Synchronisation config** : ✅ Fichier copié dans le conteneur

### 🔧 Solutions à tester dans Linphone :

#### 1. Vérifier les codecs dans Linphone
Dans Linphone > Paramètres > Codecs audio :
- ✅ Activer **ulaw** (G.711 μ-law) - priorité 1
- ✅ Activer **alaw** (G.711 a-law) - priorité 2  
- ✅ Activer **GSM** - priorité 3
- ❌ Désactiver les codecs HD (opus, speex) temporairement

#### 2. Extensions de test disponibles (dans l'ordre de test) :
- **`100`** : Démonstration simple (demo-congrats) - **COMMENCER PAR CELUI-CI**
- **`*45`** : Test tonalité 440Hz (3 secondes) - simple
- **`*44`** : Test audio simple (hello-world + merci)
- **`*43`** : Test d'écho complet (message + écho)

#### 3. Diagnostic en temps réel :
```bash
# Lancer le monitoring des logs
./debug-audio.sh
```

### 🔍 Diagnostic réseau :

#### Configuration Linphone testée et validée :
```
- Utilisateur: 1001
- Mot de passe: linphone1001
- Serveur: localhost:5060 (ou IP de votre machine)
- Transport: UDP
- STUN: Désactivé pour tests locaux
- ICE: Désactivé pour tests locaux
```

#### Ports vérifiés :
- **SIP** : 5060 (signalisation) ✅
- **RTP** : 10000-10100 (audio) ✅

### 🚨 Points de vérification critiques :

1. **Volume système** : Vérifier volume système macOS
2. **Volume Linphone** : Vérifier que le volume n'est pas à 0
3. **Périphérique audio** : Vérifier micro/haut-parleur sélectionnés
4. **Firewall** : S'assurer qu'il ne bloque pas les ports RTP
5. **Réseau local** : Tester avec IP locale au lieu de localhost

### 📋 Tests de validation (ORDRE IMPORTANT) :

```bash
# 1. Test démonstration (PREMIER TEST)
100 → Doit entendre: "Congratulations! You have successfully..."

# 2. Test de tonalité simple  
*45 → Doit entendre: BIP 440Hz pendant 3 secondes

# 3. Test audio simple
*44 → Doit entendre: "Hello world" puis "Thank you"

# 4. Test écho complet (DERNIER TEST)
*43 → Doit entendre: Message d'instructions puis écho de votre voix
```

### 🔧 Si le problème persiste :

#### Option A - Vérifier la négociation de codecs :
```bash
# Voir la négociation en temps réel
docker exec doriav2-asterisk asterisk -rx "core set verbose 4"
# Puis appelez et vérifiez les codecs négociés
```

#### Option B - Test avec un autre client SIP :
- **Zoiper** (gratuit)
- **Microsip** (léger)
- **SoftPhone web** (directement dans le navigateur)

#### Option C - Vérifier les logs détaillés :
```bash
# Logs Asterisk complets
docker exec doriav2-asterisk tail -f /var/log/asterisk/full

# Logs RTP spécifiques
docker exec doriav2-asterisk asterisk -rx "rtp set debug on"
```

### 📞 Configuration Linphone finale validée :
```
Nom d'utilisateur : 1001
Mot de passe : linphone1001  
Domaine : localhost (ou IP de votre machine)
Port : 5060
Transport : UDP
Codecs audio : ulaw, alaw, gsm (dans cet ordre)
```

### 🎵 Extensions de test par niveau de complexité :
- **Niveau 1** : `100` (audio pré-enregistré simple)
- **Niveau 2** : `*45` (tonalité générée)  
- **Niveau 3** : `*44` (multiple playbacks)
- **Niveau 4** : `*43` (playback + écho interactif)
