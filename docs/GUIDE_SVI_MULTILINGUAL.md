# 🌐 Guide SVI Multilingue - Extension 9999

## 🎯 Nouveauté : Support Français / Anglais

L'extension **9999** propose maintenant un **Serveur Vocal Interactif multilingue** permettant aux utilisateurs de choisir entre le français et l'anglais.

## 📞 Accès au SVI Multilingue

**Composer :** `9999` depuis n'importe quel téléphone configuré

### 🌍 Flux d'Utilisation

```
1. Composer 9999
2. 🎵 "Pour français, tapez 1. For English, press 2"
3. Choisir la langue (1 ou 2)
4. 🎵 Menu principal dans la langue choisie
5. Naviguer selon les options disponibles
```

## 🇫🇷 Menu Français (Option 1)

### Options Disponibles

| Touche | Service | Action |
|--------|---------|--------|
| **1** | Service Commercial | Transfert vers l'extension 1001 |
| **2** | Support Technique | Transfert vers l'extension 1002 |
| **3** | Salle de Conférence | Accès à la conférence principale |
| **4** | Répertoire | Recherche d'un utilisateur par nom |
| **0** | Opérateur | Transfert vers l'extension 1003 |
| **8** | 🌐 **Changer de langue** | Retour au menu de sélection |
| **9** | Menu Principal | Retour au début du menu |

### Messages Audio Français
- **Accueil** : "Bienvenue sur le serveur DoriaV2"
- **Menu** : "Pour joindre le service commercial, tapez 1..."
- **Erreur** : "Touche invalide, veuillez réessayer"
- **Timeout** : "Pas de réponse, retour au menu principal"

## 🇬🇧 Menu Anglais (Option 2)

### Available Options

| Key | Service | Action |
|-----|---------|--------|
| **1** | Sales Department | Transfer to extension 1001 |
| **2** | Technical Support | Transfer to extension 1002 |
| **3** | Conference Room | Access to main conference |
| **4** | Directory | Search user by name |
| **0** | Operator | Transfer to extension 1003 |
| **8** | 🌐 **Change Language** | Return to language selection |
| **9** | Main Menu | Return to menu beginning |

### English Audio Messages
- **Welcome** : "Welcome to DoriaV2 server"
- **Menu** : "For sales department, press 1..."
- **Error** : "Invalid option, please try again"
- **Timeout** : "No response, returning to main menu"

## 🎵 Fichiers Audio Requis

### Structure des Dossiers
```
asterisk/sounds/custom/
├── language-prompt.wav      # Sélection initiale (bilingue)
├── language-invalid.wav     # Erreur sélection langue
├── language-timeout.wav     # Timeout sélection langue
│
├── fr/                      # Fichiers français
│   ├── language-selected.wav
│   ├── change-language.wav
│   ├── welcome.wav
│   ├── menu-main.wav
│   └── ... (autres fichiers)
│
└── en/                      # Fichiers anglais
    ├── language-selected.wav
    ├── change-language.wav
    ├── welcome.wav
    ├── menu-main.wav
    └── ... (autres fichiers)
```

## 🛠️ Configuration Technique

### Contextes Asterisk
- **`[ivr-language]`** : Sélection de langue
- **`[ivr-main]`** : Menu principal français
- **`[ivr-main-en]`** : Menu principal anglais

### Variables Utilisées
- **`LANGUAGE`** : Langue sélectionnée (fr/en)
- **`AUDIO_PREFIX`** : Préfixe pour les fichiers audio

## 🧪 Tests et Validation

### Test Manuel
```bash
# Tester le SVI multilingue
./doria.sh test-svi
```

### Scénarios de Test
1. **Test Français** : 9999 → 1 → naviguer dans le menu
2. **Test Anglais** : 9999 → 2 → navigate through menu
3. **Changement de langue** : 8 → sélection nouvelle langue
4. **Gestion d'erreurs** : touches invalides, timeouts

## 🎨 Génération des Fichiers Audio

### Script Automatique
```bash
# Générer tous les fichiers audio manquants
./asterisk/generate_multilingual_audio.sh
```

### Génération Manuelle
```bash
# Français
espeak -v fr -s 150 -w welcome_fr.wav "Bienvenue sur le serveur DoriaV2"

# Anglais
espeak -v en -s 150 -w welcome_en.wav "Welcome to DoriaV2 server"

# Conversion format Asterisk
sox input.wav -r 8000 -c 1 -b 16 output.wav
```

## 🔧 Maintenance

### Ajouter une Nouvelle Langue
1. Créer le dossier `custom/[code_langue]/`
2. Générer les fichiers audio dans la nouvelle langue
3. Ajouter le contexte `[ivr-main-[code]]` dans `extensions.conf`
4. Modifier `[ivr-language]` pour inclure la nouvelle option

### Modifier les Messages
1. Éditer le script `generate_multilingual_audio.sh`
2. Régénérer les fichiers audio
3. Recharger Asterisk : `./doria.sh reload-asterisk`

## 🚀 Fonctionnalités Avancées

### Détection Automatique de Langue
Possibilité future d'implémenter :
- Détection basée sur l'ID de l'appelant
- Mémorisation de la préférence utilisateur
- Sélection basée sur la localisation

### Langues Supplémentaires
Le système est extensible pour ajouter :
- 🇪🇸 Espagnol
- 🇩🇪 Allemand  
- 🇮🇹 Italien
- Etc.

---

## 📚 Ressources

- **Configuration** : `asterisk/config/extensions.conf`
- **Fichiers Audio** : `asterisk/sounds/custom/`
- **Tests** : `./doria.sh test-svi`
- **Génération Audio** : `./asterisk/generate_multilingual_audio.sh`
- **Documentation Audio** : `asterisk/sounds/AUDIO_FILES_MULTILINGUAL.md`

🎯 **Le SVI DoriaV2 est maintenant international !** 🌍📞
