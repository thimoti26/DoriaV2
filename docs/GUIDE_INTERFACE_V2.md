# Guide d'utilisation - Interface SVI Admin V2

## Vue d'ensemble

La nouvelle interface SVI Admin V2 apporte une expérience utilisateur moderne et intuitive pour la configuration des parcours d'appel. Elle intègre les dernières technologies web pour offrir un drag & drop fluide et une interface responsive.

## Fonctionnalités principales

### 🎯 Drag & Drop Moderne
- **Sortable.js** : Réorganisez les étapes par simple glisser-déposer
- **Zones de drop visuelles** : Indication claire des zones de dépôt
- **Animations fluides** : Retours visuels immédiats
- **Drag depuis la toolbox** : Glissez les outils directement dans la zone de construction

### 🛠️ Boîte à outils ergonomique
- **Actions Audio** : Lecture, Menu, Synthèse vocale
- **Actions de Routage** : Transfert, Redirection, Raccrocher
- **Actions Avancées** : Attente, Musique d'attente, Variables
- **Catégorisation claire** : Outils organisés par type d'action

### 📱 Interface responsive
- **Desktop** : Layout 3 colonnes (toolbox, canvas, propriétés)
- **Tablette** : Layout adaptatif avec panneaux repliables
- **Mobile** : Interface verticale optimisée

## Guide d'utilisation

### 1. Création d'un parcours SVI

#### Méthode 1 : Drag & Drop
1. Sélectionnez un outil dans la **Boîte à outils**
2. Glissez-le vers la **Zone de construction**
3. Déposez-le dans la zone de drop ou le conteneur d'étapes
4. L'étape est automatiquement créée avec une configuration par défaut

#### Méthode 2 : Bouton d'ajout
1. Cliquez sur **"Ajouter Étape"** dans la toolbox
2. Sélectionnez le type d'action dans la modale
3. Cliquez sur **"Ajouter"**
4. L'étape est ajoutée à la fin du parcours

### 2. Configuration des étapes

#### Sélection d'une étape
- Cliquez sur une étape dans le conteneur
- L'étape se surligne en bleu
- Le panneau de propriétés s'ouvre automatiquement

#### Modification des propriétés
- **Extension** : Touche que l'utilisateur appuiera (1, 2, 3, s, i, t...)
- **Label** : Nom descriptif de l'étape
- **Configuration spécifique** : Selon le type d'action

#### Types d'actions disponibles

**Lecture Audio**
- Fichier audio à jouer
- Timeout d'attente (3-60 secondes)

**Menu Choix**
- Fichier audio du menu
- Timeout d'attente
- Options de navigation

**Synthèse Vocale**
- Texte à prononcer
- Langue (français/anglais)

**Transfert**
- Extension de destination (1001, 1002...)
- Timeout d'appel (10-300 secondes)

**Redirection**
- Contexte de destination
- Extension dans le contexte cible

### 3. Gestion des fichiers audio

#### Upload de fichiers
1. Cliquez sur l'onglet **"Fichiers Audio"**
2. Cliquez sur **"Télécharger Audio"**
3. Glissez vos fichiers dans la zone de drop OU cliquez pour sélectionner
4. Choisissez la langue et la qualité
5. Cliquez sur **"Télécharger"**

#### Formats supportés
- **WAV** : Format recommandé pour Asterisk
- **MP3** : Converti automatiquement
- **OGG** : Support natif

#### Gestion des fichiers
- **Aperçu** : Écoute directe depuis l'interface
- **Suppression** : Suppression sécurisée avec confirmation
- **Métadonnées** : Taille, durée, langue automatiquement détectées

### 4. Simulation de parcours

#### Lancement d'une simulation
1. Cliquez sur **"Simuler"** dans la barre d'actions
2. Configurez le numéro appelant
3. Sélectionnez le contexte de départ
4. Cliquez sur **"Démarrer la simulation"**

#### Utilisation du simulateur
- **Clavier virtuel** : Testez les touches 0-9, *, #
- **Log d'appel** : Suivez le parcours en temps réel
- **Étapes exécutées** : Visualisez chaque action

### 5. Historique des appels

#### Consultation de l'historique
1. Cliquez sur **"Historique"** dans la barre d'actions
2. Filtrez par période (aujourd'hui, semaine, mois, tout)
3. Filtrez par statut (terminé, abandonné, timeout)
4. Consultez les détails de chaque appel

#### Export des données
- **CSV** : Export complet pour analyse
- **Filtrage** : Export des données filtrées uniquement

### 6. Configuration Asterisk

#### Génération automatique
1. Cliquez sur l'onglet **"Configuration"**
2. Sélectionnez le fichier de configuration
3. La configuration est générée automatiquement
4. Prévisualisez avant sauvegarde

#### Fichiers générés
- **extensions.conf** : Configuration des contextes SVI
- **pjsip.conf** : Configuration des extensions SIP

## Raccourcis clavier

- **Ctrl + S** : Sauvegarder la configuration
- **Ctrl + Z** : Annuler la dernière action
- **Ctrl + Y** : Rétablir l'action annulée
- **Suppr** : Supprimer l'étape sélectionnée
- **Ctrl + D** : Dupliquer l'étape sélectionnée

## Notifications

L'interface utilise **Toastify** pour les notifications :
- **Vert** : Succès (sauvegarde, ajout...)
- **Bleu** : Information (chargement, status...)
- **Orange** : Avertissement (validation...)
- **Rouge** : Erreur (problème de configuration...)

## Contextualisation

### Contextes SVI
- **Sélection Langue** : Premier niveau de navigation
- **Menu Principal (FR)** : Menu français
- **Menu Principal (EN)** : Menu anglais
- **Contextes personnalisés** : Créés selon les besoins

### Navigation entre contextes
- **Onglets** : Basculez entre les contextes
- **Redirection** : Liez les contextes avec des actions de redirection
- **Cohérence** : Vérifiez la logique de navigation

## Bonnes pratiques

### Organisation des extensions
- **s** : Étape de démarrage (start)
- **1-9** : Options utilisateur
- **0** : Opérateur
- **8,9** : Retour/Menu précédent
- **i** : Option invalide
- **t** : Timeout

### Nommage des fichiers audio
- **welcome-fr.wav** : Message de bienvenue français
- **menu-main-fr.wav** : Menu principal français
- **goodbye-fr.wav** : Message de fin français

### Structure des parcours
1. **Accueil** : Message de bienvenue
2. **Menu** : Présentation des options
3. **Choix** : Traitement des sélections
4. **Action** : Transfert, redirection ou information
5. **Fin** : Message de fin ou raccrocher

## Dépannage

### Problèmes courants

**Le drag & drop ne fonctionne pas**
- Vérifiez que Sortable.js est chargé
- Actualisez la page
- Vérifiez la console pour les erreurs JavaScript

**Les fichiers audio ne s'uploadent pas**
- Vérifiez le format (WAV, MP3, OGG)
- Vérifiez la taille (max 10MB)
- Vérifiez les permissions du serveur

**La simulation ne fonctionne pas**
- Vérifiez qu'au moins une étape est configurée
- Vérifiez les extensions (s, 1, 2, 3...)
- Vérifiez la logique de navigation

### Support technique
- **Logs** : Consultez la console du navigateur (F12)
- **Tests** : Utilisez `./tests/test-interface-v2.sh`
- **Documentation** : Consultez `/docs/` pour plus d'informations

## Migration depuis la V1

### Différences principales
- **Interface** : Layout moderne vs classique
- **Drag & Drop** : Sortable.js vs HTML5 natif
- **Notifications** : Toastify vs alertes natives
- **Responsive** : Optimisé mobile vs desktop uniquement

### Étapes de migration
1. **Sauvegarde** : Exportez votre configuration V1
2. **Test** : Testez la V2 en parallèle
3. **Formation** : Habituez-vous à la nouvelle interface
4. **Bascule** : Remplacez index.php par index-v2.php
5. **Vérification** : Testez tous les parcours

## Évolutions futures

### Fonctionnalités prévues
- **Éditeur visuel** : Diagramme graphique des parcours
- **Templates** : Modèles de parcours pré-configurés
- **Collaboratif** : Édition multi-utilisateur
- **Analytics** : Statistiques avancées
- **API REST** : Intégration avec d'autres systèmes

### Améliorations continues
- **Performance** : Optimisation du rendu
- **Accessibilité** : Amélioration WCAG
- **Sécurité** : Renforcement des contrôles
- **Localisation** : Support multilingue étendu

## 🎨 Améliorations Visuelles V2

### Interface Ultra-Moderne
La nouvelle interface SVI Admin V2 a été complètement repensée avec des technologies modernes pour offrir une expérience utilisateur exceptionnelle :

- **Arrière-plan animé** : Particules interactives avec Particles.js
- **Effet glassmorphism** : Conteneurs translucides avec effet verre dépoli
- **Gradients sophistiqués** : Arrière-plan multicouches avec animations
- **Boutons modernes** : Effets de vague, brillance et transformations 3D
- **Navigation fluide** : Animations et transitions élégantes
- **Typographie moderne** : Polices Inter et JetBrains Mono

### Effets Visuels Avancés
- **Particules lumineuses** : Effets de particules dans les headers
- **Animations CSS** : Keyframes pour des mouvements fluides
- **Hover effects** : Transformations au survol sophistiquées
- **Drag & Drop visuel** : Feedback visuel pour toutes les interactions
- **Ombres modernes** : Système d'ombres multicouches
- **Transparences** : Effets de profondeur avec rgba()

### Performance et Responsivité
- **Optimisé mobile** : Design adaptatif pour tous les écrans
- **GPU accelerated** : Animations optimisées pour les performances
- **Chargement rapide** : Librairies CDN et code optimisé
- **Cross-browser** : Compatible avec tous les navigateurs modernes

---

*Interface SVI Admin V2 - DoriaV2 - Documentation mise à jour le 9 juillet 2025*
