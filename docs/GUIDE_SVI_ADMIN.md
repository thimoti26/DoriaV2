# 🌐 SVI Admin - Interface d'Administration

Interface web moderne pour la gestion du Serveur Vocal Interactif (SVI) de DoriaV2.

## 🎯 Fonctionnalités

### 📋 Éditeur Visuel SVI
- **Diagramme de flux interactif** : Représentation graphique du SVI
- **Édition par glisser-déposer** : Interface intuitive pour créer les menus
- **Contextes multilingues** : Gestion français/anglais séparée
- **Types d'actions supportés** :
  - Menu audio avec options
  - Transfert vers extension
  - Redirection vers autre menu
  - Raccrocher
  - Retour au menu précédent

### 🎵 Gestionnaire Audio
- **Upload WAV** : Glisser-déposer de fichiers audio
- **Classification automatique** : Organisation par langue (FR/EN)
- **Lecteur intégré** : Prévisualisation des fichiers audio
- **Validation format** : Vérification automatique des fichiers WAV

### 🎭 Simulateur de Parcours
- **Navigation interactive** : Test du SVI sans téléphone
- **Historique complet** : Traçage de toutes les étapes
- **Lecture audio** : Écoute des prompts dans l'ordre
- **Reset facile** : Recommencer la simulation

### ⚙️ Contrôles Asterisk
- **Validation syntaxe** : Vérification avant application
- **Rechargement automatique** : Mise à jour en temps réel
- **Gestion d'erreurs** : Messages d'erreur détaillés

## 🚀 Utilisation

### Accès Direct
```bash
./doria.sh svi-admin
```

### Accès Manuel
1. Démarrer la stack : `./doria.sh start`
2. Ouvrir : http://localhost:8080/svi-admin/

## 📱 Interface

### Onglets Principaux
- **Sélection Langue** : Menu d'entrée FR/EN
- **Menu Principal (FR)** : SVI français
- **Menu Principal (EN)** : SVI anglais

### Panneau Latéral
- **Fichiers Audio** : Upload et gestion des fichiers WAV
- **Actions Disponibles** : Templates pour créer les étapes

### Barre d'Outils
- **Valider Syntaxe** : Vérifier la configuration
- **Recharger Asterisk** : Appliquer les modifications
- **Simuler Parcours** : Tester la navigation

## 🎨 Création d'un Menu SVI

### 1. Ajouter une Étape
1. Cliquer sur "Ajouter Étape"
2. Choisir le numéro d'option (1, 2, 3...)
3. Sélectionner le type d'action
4. Configurer les paramètres spécifiques

### 2. Types d'Actions

#### Menu Audio
- **Fichier requis** : Sélectionner un fichier WAV uploadé
- **Utilisation** : Pour les prompts vocaux avec options

#### Transfert Extension
- **Extension** : Numéro de l'extension de destination (1001, 1002...)
- **Utilisation** : Rediriger l'appel vers un utilisateur

#### Redirection Menu
- **Contexte** : Choisir le menu de destination
- **Utilisation** : Navigation entre menus

#### Raccrocher
- **Aucun paramètre** : Termine l'appel
- **Utilisation** : Fin de parcours

#### Menu Précédent
- **Automatique** : Retour au contexte parent
- **Utilisation** : Option "retour" dans les menus

### 3. Gestion Audio
1. Sélectionner la langue (FR/EN)
2. Glisser-déposer les fichiers WAV
3. Cliquer "Upload"
4. Utiliser dans les menus via le sélecteur

## 🔧 Configuration Technique

### Structure Fichiers
```
svi-admin/
├── index.php              # Interface principale
├── api/                   # Backend PHP
│   ├── get-svi-config.php # Chargement config
│   ├── save-svi-config.php# Sauvegarde config
│   ├── upload-audio.php   # Upload fichiers
│   ├── validate-syntax.php# Validation
│   └── reload-asterisk.php# Rechargement
├── js/                    # Frontend JavaScript
│   ├── svi-editor.js      # Éditeur principal
│   ├── audio-manager.js   # Gestion audio
│   ├── svi-simulator.js   # Simulateur
│   └── api-client.js      # Client API
├── css/
│   └── svi-admin.css      # Styles interface
├── uploads/               # Fichiers uploadés
│   ├── fr/               # Audio français
│   └── en/               # Audio anglais
└── includes/
    └── ExtensionsParser.php# Parser Asterisk
```

### Formats Supportés
- **Audio** : WAV uniquement (format natif Asterisk)
- **Taille max** : 10MB par fichier
- **Qualité** : Pas de validation qualité automatique

## 🐛 Dépannage

### Erreurs Communes

#### "Fichier extensions.conf non trouvé"
- Vérifier que les conteneurs sont démarrés
- Contrôler les permissions de fichiers

#### "Impossible de sauvegarder"
- Vérifier les droits d'écriture sur `/var/lib/asterisk/`
- Contrôler l'espace disque disponible

#### "Erreur upload audio"
- Vérifier le format WAV
- Contrôler la taille du fichier (< 10MB)
- Vérifier les permissions du dossier uploads/

### Logs Debug
```bash
# Logs conteneur web
docker compose logs web

# Logs Asterisk
docker compose logs asterisk

# Test rechargement manuel
docker compose exec asterisk asterisk -rx "dialplan reload"
```

## 🎯 Roadmap

### Fonctionnalités Prévues
- [ ] Import/Export de configurations SVI
- [ ] Templates de menus prédéfinis
- [ ] Éditeur de texte TTS intégré
- [ ] Statistiques d'utilisation des menus
- [ ] Versioning des configurations
- [ ] Multi-utilisateurs avec authentification

## 📞 Support

L'interface SVI Admin fait partie de l'écosystème DoriaV2. 
Pour le support technique, consulter la documentation principale dans `/docs/`.

---
**Version** : 1.0  
**Compatibilité** : Asterisk 18+, PHP 8.2+, Navigateurs modernes
