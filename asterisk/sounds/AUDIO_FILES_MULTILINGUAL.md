# Liste des fichiers audio nécessaires pour le SVI multilingue DoriaV2

## 📁 Structure des Dossiers
```
asterisk/sounds/custom/
├── language-prompt.wav      # "Pour français, tapez 1. For English, press 2"
├── language-invalid.wav     # "Option invalide. Invalid option"
├── language-timeout.wav     # "Pas de réponse, français par défaut. No response, defaulting to French"
│
├── fr/                      # Fichiers français
│   ├── language-selected.wav   # "Français sélectionné"
│   ├── change-language.wav     # "Changement de langue"
│   ├── welcome.wav             # "Bienvenue sur le serveur DoriaV2"
│   ├── menu-main.wav           # Menu principal en français
│   ├── commercial.wav          # Service commercial
│   ├── support.wav             # Support technique
│   ├── conference.wav          # Salle de conférence
│   ├── directory.wav           # Répertoire téléphonique
│   ├── operator.wav            # Opérateur
│   ├── invalid.wav             # Touche invalide
│   └── timeout.wav             # Timeout
│
└── en/                      # Fichiers anglais
    ├── language-selected.wav   # "English selected"
    ├── change-language.wav     # "Language change"
    ├── welcome.wav             # "Welcome to DoriaV2 server"
    ├── menu-main.wav           # Main menu in English
    ├── commercial.wav          # Sales department
    ├── support.wav             # Technical support
    ├── conference.wav          # Conference room
    ├── directory.wav           # Directory
    ├── operator.wav            # Operator
    ├── invalid.wav             # Invalid key
    └── timeout.wav             # Timeout
```

## 🎵 Fichiers à Créer

### Sélection de Langue (racine /custom/)
1. **language-prompt.wav** 
   - FR: "Pour français, tapez 1"
   - EN: "For English, press 2"

2. **language-invalid.wav**
   - FR/EN: "Option invalide. Invalid option"

3. **language-timeout.wav**
   - FR/EN: "Pas de réponse, français par défaut. No response, defaulting to French"

### Français (/custom/fr/)
4. **language-selected.wav** - "Français sélectionné"
5. **change-language.wav** - "Changement de langue"

### Anglais (/custom/en/)
6. **language-selected.wav** - "English selected"
7. **change-language.wav** - "Language change"
8. **welcome.wav** - "Welcome to DoriaV2 server"
9. **menu-main.wav** - "For sales department, press 1. For technical support, press 2. For conference room, press 3. For directory, press 4. For operator, press 0. To change language, press 8. To return to main menu, press 9"
10. **commercial.wav** - "Connecting to sales department"
11. **support.wav** - "Connecting to technical support"
12. **conference.wav** - "Accessing conference room"
13. **directory.wav** - "Accessing directory"
14. **operator.wav** - "Connecting to operator"
15. **invalid.wav** - "Invalid option, please try again"
16. **timeout.wav** - "No response, returning to main menu"

## 🎯 Menu SVI Mis à Jour

### Extension 9999 - Flux Complet
1. **Sélection langue** (1=FR, 2=EN)
2. **Menu principal** (selon langue choisie)
3. **Options disponibles**:
   - 1: Service Commercial/Sales
   - 2: Support Technique/Technical Support  
   - 3: Conférence/Conference
   - 4: Répertoire/Directory
   - 0: Opérateur/Operator
   - 8: **Changer de langue/Change language**
   - 9: Retour menu/Return to menu

## 🔧 Commandes pour Générer les Fichiers Audio

### Utilisation de espeak (Text-to-Speech)
```bash
# Français
espeak -v fr -s 150 -w language-selected.wav "Français sélectionné"
espeak -v fr -s 150 -w change-language.wav "Changement de langue"

# Anglais  
espeak -v en -s 150 -w language-selected.wav "English selected"
espeak -v en -s 150 -w change-language.wav "Language change"
espeak -v en -s 150 -w welcome.wav "Welcome to DoriaV2 server"
```

### Conversion au format Asterisk
```bash
# Convertir en format compatible Asterisk
sox input.wav -r 8000 -c 1 -b 16 output.wav
```
