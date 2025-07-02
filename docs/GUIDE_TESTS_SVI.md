# 🧪 Guide des Tests SVI DoriaV2

## 📋 Vue d'Ensemble

Ce guide présente les 3 outils de test disponibles pour valider le Serveur Vocal Interactif (SVI) multilingue de DoriaV2.

## 🛠️ Outils de Test Disponibles

### 1. 🎮 Test Navigation Interactif
**Script :** `test-svi-navigation.sh`  
**Usage :** Test manuel et interactif de la navigation SVI

```bash
# Lancement
./tests/test-svi-navigation.sh
# ou
./doria.sh test-svi-nav
```

**Fonctionnalités :**
- ✅ **Interface graphique** en mode texte
- ✅ **Navigation pas à pas** dans tous les menus
- ✅ **Simulation complète** sans audio
- ✅ **Historique** des étapes parcourues
- ✅ **Aide intégrée** et commandes spéciales

**Commandes spéciales :**
- `h, help` - Afficher l'aide
- `r, reset` - Recommencer depuis le début
- `l, log` - Historique de navigation
- `s, summary` - Résumé des contextes
- `t` - Simuler un timeout
- `i` - Simuler une touche invalide
- `q, quit` - Quitter

### 2. 🚀 Test Automatique des Chemins
**Script :** `test-svi-paths.sh`  
**Usage :** Validation automatique de tous les chemins possibles

```bash
# Lancement
./tests/test-svi-paths.sh
# ou
./doria.sh test-svi-paths
```

**Tests effectués :**
- 🌐 **Sélection langue** : 4 chemins
- 🇫🇷 **Menu français** : 9 chemins  
- 🇬🇧 **Menu anglais** : 9 chemins
- 🔄 **Chemins complexes** : 5 chemins
- 📞 **Extensions destination** : 4 chemins
- 📊 **TOTAL** : 31 chemins testés

### 3. 🔧 Test Configuration Asterisk
**Script :** `test-svi-multilingual.sh`  
**Usage :** Validation de la configuration technique

```bash
# Lancement
./tests/test-svi-multilingual.sh
# ou
./doria.sh test-svi
```

**Vérifications :**
- ✅ Configuration extension 9999
- ✅ Contextes Asterisk (ivr-language, ivr-main, ivr-main-en)
- ✅ Structure dossiers audio
- ✅ Fichiers audio requis
- ✅ Options du menu (y compris option 8)

## 🎯 Scénarios de Test

### 🌐 Tests de Sélection de Langue

| Test | Entrée | Résultat Attendu |
|------|--------|------------------|
| **Français** | 9999 → 1 | Menu français affiché |
| **Anglais** | 9999 → 2 | Menu anglais affiché |
| **Timeout** | 9999 → (rien) | Français par défaut |
| **Invalide** | 9999 → 5 | Répétition du menu |

### 🇫🇷 Tests Menu Français

| Option | Action | Destination |
|--------|--------|-------------|
| **1** | Service Commercial | Dial(PJSIP/1001) |
| **2** | Support Technique | Dial(PJSIP/1002) |
| **3** | Salle de Conférence | ConfBridge(conference1) |
| **4** | Répertoire | Directory() |
| **0** | Opérateur | Dial(PJSIP/1003) |
| **8** | Changer langue | Retour ivr-language |
| **9** | Menu principal | Répétition menu |

### 🇬🇧 Tests Menu Anglais

| Option | Action | Destination |
|--------|--------|-------------|
| **1** | Sales Department | Dial(PJSIP/1001) |
| **2** | Technical Support | Dial(PJSIP/1002) |
| **3** | Conference Room | ConfBridge(conference1) |
| **4** | Directory | Directory() |
| **0** | Operator | Dial(PJSIP/1003) |
| **8** | Change language | Return to ivr-language |
| **9** | Main menu | Menu repetition |

### 🔄 Tests Changement de Langue

| Scénario | Chemin |
|----------|--------|
| **FR → EN** | 9999 → 1 → 8 → 2 → Menu anglais |
| **EN → FR** | 9999 → 2 → 8 → 1 → Menu français |
| **Multiple** | Changements répétés entre langues |

## 📊 Exemple de Session Interactive

```
🌐 TEST SVI MULTILINGUE DORIAV2
╔══════════════════════════════════════════════╗
║        🌐 TEST SVI MULTILINGUE DORIAV2       ║
║              Navigation Simulator            ║
╚══════════════════════════════════════════════╝

Contexte actuel: ivr-language
Langue: Non sélectionnée
Étapes parcourues: 0

📋 === SÉLECTION DE LANGUE ===
🎵 Audio: "Pour français, tapez 1. For English, press 2"

Options disponibles:
  1️⃣  Français
  2️⃣  English
  ⏱️  Timeout (10s) → Français par défaut
  ❌ Touche invalide → Répétition du menu

🎯 Votre choix (ou 'h' pour aide): 1

🔹 Étape 1: Option 1 → Français sélectionné
🔹 Étape 2: Menu principal français sélectionné

📋 === MENU PRINCIPAL FRANÇAIS ===
🎵 Audio: "Bienvenue sur le serveur DoriaV2"
🎵 Audio: "Pour joindre le service commercial, tapez 1..."

Options disponibles:
  1️⃣  Service Commercial (→ 1001)
  2️⃣  Support Technique (→ 1002)
  3️⃣  Salle de Conférence (→ conference1)
  4️⃣  Répertoire téléphonique
  0️⃣  Opérateur (→ 1003)
  8️⃣  🌐 Changer de langue
  9️⃣  Retour au menu principal

🎯 Votre choix: 1

🔹 Étape 3: Service Commercial → Transfert vers 1001
✅ 🎵 Audio français: "Connexion au service commercial"
✅ 📞 Dial(PJSIP/1001,30) → Extension 1001
```

## 🎨 Codes de Couleur

Les scripts utilisent un système de couleurs pour faciliter la lecture :

- 🔵 **Bleu** : Informations générales
- 🟢 **Vert** : Succès et validations
- 🟡 **Jaune** : Avertissements et timeouts
- 🔴 **Rouge** : Erreurs
- 🟦 **Cyan** : Étapes de navigation
- 🟣 **Magenta** : Menus et options

## 🚀 Utilisation Recommandée

### Pour le Développement
1. **Pendant la configuration** : `test-svi-multilingual.sh`
2. **Pour valider la logique** : `test-svi-paths.sh`
3. **Pour tester l'UX** : `test-svi-navigation.sh`

### Pour la Production
1. **Test complet** : `doria.sh test-svi`
2. **Validation automatique** : `doria.sh test-svi-paths`

### Pour la Démonstration
1. **Présentation interactive** : `doria.sh test-svi-nav`
2. **Historique navigation** : Commande `l` dans le test interactif

## 🔧 Personnalisation

### Ajouter de Nouveaux Tests
1. Modifier `test-svi-paths.sh` pour ajouter des chemins
2. Mettre à jour `test-svi-navigation.sh` pour nouvelles options
3. Adapter `test-svi-multilingual.sh` pour nouvelles vérifications

### Modifier les Messages
- Éditer les variables dans chaque script
- Adapter les textes des menus selon vos besoins
- Maintenir la cohérence entre les 3 outils

## 📚 Ressources Complémentaires

- **Configuration** : `asterisk/config/extensions.conf`
- **Guide SVI** : `docs/GUIDE_SVI_MULTILINGUAL.md`
- **Génération audio** : `asterisk/generate_multilingual_audio.sh`
- **Documentation audio** : `asterisk/sounds/AUDIO_FILES_MULTILINGUAL.md`

---

🎯 **Ces outils garantissent un SVI robuste et bien testé avant sa mise en production !** 🧪📞
