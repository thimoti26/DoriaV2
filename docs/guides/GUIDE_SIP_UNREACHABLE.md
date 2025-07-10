# 📞 Gestion des Contacts SIP "Unreachable" - DoriaV2

## 🎯 Situation

Vous voyez ces messages dans les logs d'Asterisk :
```
[Jul  3 08:40:06]     -- Contact 1002/sip:1002@dynamic is now Unreachable.  RTT: 0.000 msec
[Jul  3 08:40:18]     -- Contact 1003/sip:1003@dynamic is now Unreachable.  RTT: 0.000 msec
[Jul  3 08:40:25]     -- Contact 1001/sip:1001@dynamic is now Unreachable.  RTT: 0.000 msec
[Jul  3 08:40:25]     -- Contact 1004/sip:1004@dynamic is now Unreachable.  RTT: 0.000 msec
```

## ✅ **C'EST NORMAL !**

Ces messages **ne sont PAS des erreurs**. Ils indiquent simplement qu'aucun client SIP (téléphone, softphone) n'est connecté aux extensions configurées.

---

## 🔍 Explication Technique

### **Pourquoi ces messages apparaissent**

1. **Vérification périodique** : Asterisk teste la disponibilité des contacts toutes les 30 secondes (`qualify_frequency=30`)
2. **Contacts dynamiques** : Les contacts `@dynamic` sont créés automatiquement lors de l'enregistrement SIP
3. **Aucun client connecté** : Pas de téléphone/softphone enregistré sur ces extensions
4. **Comportement attendu** : Asterisk signale que les contacts ne répondent pas

### **Configuration actuelle**

```ini
; Dans pjsip.conf
[aor_template](!)
qualify_frequency=30    # Test toutes les 30 secondes
qualify_timeout=3       # Timeout de 3 secondes
default_expiration=120  # Expiration par défaut
```

---

## 📊 Statut Actuel des Extensions

| Extension | Statut | Description |
|-----------|--------|-------------|
| **1001** | 🟢 Connecté | Un client SIP est enregistré |
| **1002** | ❌ Non connecté | Aucun client SIP |
| **1003** | ❌ Non connecté | Aucun client SIP |
| **1004** | ❌ Non connecté | Aucun client SIP |

---

## 🛠️ Solutions et Actions

### **1. 📱 Connecter des Clients SIP (Recommandé)**

Pour éliminer ces messages, connectez des softphones :

#### **Configuration Linphone**
```
Serveur SIP : localhost ou IP du serveur
Port : 5060
Transport : UDP

Comptes disponibles :
• 1001 / linphone1001
• 1002 / linphone1002  
• 1003 / linphone1003
• 1004 / linphone1004
```

#### **Autres Softphones**
- **X-Lite** (gratuit)
- **Zoiper** (gratuit/payant)
- **3CX Phone** (gratuit)
- **MicroSIP** (Windows, gratuit)

### **2. ⚙️ Ajuster la Configuration (Optionnel)**

Si vous ne voulez pas connecter de clients mais réduire les messages :

#### **Réduire la fréquence de vérification**
```ini
# Dans pjsip.conf - template aor_template
qualify_frequency=60    # Au lieu de 30 secondes
```

#### **Désactiver la vérification pour certaines extensions**
```ini
[1002](aor_template)
qualify_frequency=0     # Désactive les tests pour 1002
```

### **3. 🧹 Supprimer les Extensions Inutilisées**

Si certaines extensions ne seront jamais utilisées :

```bash
# Commenter dans pjsip.conf
; [1003](endpoint_template)
; [1003](aor_template)  
; [1003](auth_template)
```

### **4. 📊 Surveillance avec Script**

Utilisez le script de diagnostic :

```bash
# Statut général
./scripts/diagnose-sip.sh status

# Explication complète
./scripts/diagnose-sip.sh explain

# Rapport complet
./scripts/diagnose-sip.sh full
```

---

## 🚀 Test Rapide - Connecter Linphone

### **Installation**
```bash
# Ubuntu/Debian
sudo apt install linphone

# macOS (avec Homebrew)
brew install --cask linphone

# Windows
# Télécharger depuis https://www.linphone.org/
```

### **Configuration**
1. **Ouvrir Linphone**
2. **Ajouter un compte SIP** :
   - Nom d'utilisateur : `1001`
   - Mot de passe : `linphone1001`
   - Domaine/Serveur : `localhost` (ou IP du serveur)
   - Port : `5060`
3. **Activer l'enregistrement automatique**
4. **Vérifier le statut** : Doit afficher "Connecté"

### **Vérification**
```bash
# Vérifier que l'extension est maintenant disponible
docker exec -it doriav2-asterisk asterisk -rx "pjsip show endpoints"
# 1001 devrait maintenant être "Not in use" au lieu de "Unavailable"
```

---

## 📈 Impact sur le Système

### **Performance**
- ✅ **Aucun impact** sur les performances
- ✅ **Messages informatifs** seulement
- ✅ **Fonctionnalité SVI** non affectée

### **Utilisation Normale**
- ✅ **Interface SVI Admin** fonctionne parfaitement
- ✅ **Génération extensions.conf** opérationnelle
- ✅ **Tests d'appels** possibles avec clients connectés

---

## 📋 Checklist de Résolution

- [ ] **Comprendre** que c'est un comportement normal
- [ ] **Décider** si des clients SIP sont nécessaires
- [ ] **Installer** Linphone ou autre softphone
- [ ] **Configurer** au moins une extension (1001 recommandée)
- [ ] **Tester** l'enregistrement SIP
- [ ] **Vérifier** que les messages "Unreachable" diminuent
- [ ] **Documenter** la configuration pour l'équipe

---

## 🔧 Commandes Utiles

### **Diagnostic**
```bash
# Statut des endpoints
./scripts/diagnose-sip.sh status

# Test de connectivité
./scripts/diagnose-sip.sh test

# Configuration client SIP
./scripts/diagnose-sip.sh config
```

### **Asterisk CLI**
```bash
# Voir les endpoints
docker exec -it doriav2-asterisk asterisk -rx "pjsip show endpoints"

# Voir les contacts AOR
docker exec -it doriav2-asterisk asterisk -rx "pjsip show aors"

# Voir les transports
docker exec -it doriav2-asterisk asterisk -rx "pjsip show transports"
```

---

## 🎯 Conclusion

**Les messages "Unreachable" sont normaux et attendus quand aucun client SIP n'est connecté.**

### **Actions recommandées :**

1. **Pour un environnement de développement** : Connecter au moins Linphone sur l'extension 1001
2. **Pour la production** : Connecter les téléphones/softphones nécessaires
3. **Pour les tests** : Utiliser le script de diagnostic pour surveiller l'état

### **Aucune action urgente requise** - Le système fonctionne correctement ! ✅

---

*Script de diagnostic disponible : `./scripts/diagnose-sip.sh`*  
*Interface SVI Admin : http://localhost:8080/svi-admin/*
