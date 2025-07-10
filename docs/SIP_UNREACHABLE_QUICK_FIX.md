# 🚨 RÉSOLUTION RAPIDE - SIP "Unreachable"

## ❓ Vous voyez ces messages ?

```
Contact 1002/sip:1002@dynamic is now Unreachable. RTT: 0.000 msec
Contact 1003/sip:1003@dynamic is now Unreachable. RTT: 0.000 msec
```

## ✅ **PAS D'INQUIÉTUDE - C'EST NORMAL !**

---

## 🎯 Explication Rapide

Ces messages signifient simplement :
- 📞 **Aucun téléphone connecté** aux extensions 1002, 1003, etc.
- ⏰ **Asterisk vérifie** la disponibilité toutes les 30 secondes
- 🔍 **Comportement attendu** quand aucun client SIP n'est enregistré

## 🛠️ Solutions Rapides

### **Option 1 : Connecter un Softphone (Recommandé)**

1. **Installer Linphone** (gratuit)
2. **Configurer un compte** :
   - Utilisateur : `1001`
   - Mot de passe : `linphone1001`
   - Serveur : `localhost`
3. **Résultat** : Messages réduits, extension utilisable

### **Option 2 : Ajuster la Configuration**

```bash
# Réduire la fréquence de vérification
# Dans asterisk/config/pjsip.conf
qualify_frequency=60  # Au lieu de 30 secondes
```

### **Option 3 : Ignorer (Acceptable)**

- ✅ **Système fonctionnel** malgré les messages
- ✅ **Interface SVI** opérationnelle
- ✅ **Aucun impact** sur les performances

---

## 🔧 Diagnostic Rapide

```bash
# Voir le statut actuel
./scripts/diagnose-sip.sh status

# Explication complète
./scripts/diagnose-sip.sh explain
```

---

## 🎯 **CONCLUSION : TOUT VA BIEN !**

Les messages "Unreachable" sont **informatifs** et **normaux**.  
Votre système DoriaV2 fonctionne parfaitement.

🔗 **Interface SVI** : http://localhost:8080/svi-admin/
