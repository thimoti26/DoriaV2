# Système SVI Asterisk et FreePBX

Ce projet met en place un système de Serveur Vocal Interactif (SVI) utilisant Asterisk et FreePBX, orchestré avec Docker Compose. Voici les détails pour configurer et exécuter le projet.

## Structure du Projet

Le projet se compose des composants principaux suivants :

- **Asterisk** : Le moteur téléphonique central qui gère le routage et le traitement des appels.
- **FreePBX** : Une interface web graphique pour gérer les configurations Asterisk.
- **MySQL** : La base de données utilisée pour stocker les configurations et données de FreePBX.
- **Nginx** : Un serveur web qui sert l'interface FreePBX et gère les requêtes HTTP.

## Prérequis

- Docker et Docker Compose installés sur votre machine.
- Connaissances de base d'Asterisk et FreePBX.

## Instructions de Configuration

1. **Cloner le Dépôt** : 
   Clonez ce dépôt sur votre machine locale.

   ```bash
   git clone <url-du-depot>
   cd asterisk-freepbx-ivr
   ```

2. **Configurer les Variables d'Environnement** : 
   Modifiez le fichier `.env` pour définir vos identifiants de base de données et autres configurations nécessaires.

3. **Construire et Démarrer les Services** : 
   Utilisez Docker Compose pour construire et démarrer les services.

   ```bash
   docker-compose up -d
   ```

4. **Accéder à FreePBX** : 
   Une fois les services en cours d'exécution, vous pouvez accéder à l'interface web FreePBX en naviguant vers `http://localhost` dans votre navigateur web.

5. **Configurer Asterisk** : 
   Modifiez les fichiers de configuration situés dans le répertoire `asterisk/config` pour configurer votre plan de numérotation, paramètres SIP et options de messagerie vocale.

6. **Ajouter des Fichiers Audio** : 
   Placez tous les fichiers audio personnalisés dans le répertoire `asterisk/sounds` pour les utiliser dans vos messages SVI.

## Configuration du SVI (Serveur Vocal Interactif)

### Structure de l'Arbre de Décision

Le SVI est configuré dans le fichier `asterisk/config/extensions.conf`. Voici la structure recommandée :

```
Menu Principal
├── 1 - Ventes / Commercial
├── 2 - Support Technique  
├── 3 - Informations Générales
├── 4 - Urgences
├── 9 - Répéter le menu
└── 0 - Opérateur
```

### Personnalisation des Messages Vocaux

1. **Enregistrement des Messages** :
   - Placez vos fichiers audio au format WAV dans `asterisk/sounds/`
   - Nommage recommandé : `menu_principal.wav`, `option_ventes.wav`, etc.

2. **Configuration des Extensions** :
   - Modifiez `asterisk/config/extensions.conf` pour définir votre logique d'appel
   - Utilisez les directives Asterisk comme `Background()`, `WaitExten()`, `Goto()`

3. **Gestion des Erreurs** :
   - Messages pour options invalides
   - Gestion des timeouts
   - Nombre maximum de tentatives

### Exemple de Configuration SVI Multi-niveaux

```asterisk
[menu-principal]
exten => s,1,Answer()
 same => n,Wait(1)
 same => n,Background(bienvenue)
 same => n,Background(menu-principal)
 same => n,WaitExten(10)

exten => 1,1,Goto(ventes,s,1)
exten => 2,1,Goto(support,s,1)
exten => 3,1,Goto(infos,s,1)
exten => 0,1,Dial(SIP/operateur,30)

[ventes]
exten => s,1,Background(menu-ventes)
 same => n,WaitExten(10)

exten => 1,1,Dial(SIP/commercial1,30)
exten => 2,1,Dial(SIP/commercial2,30)
exten => #,1,Goto(menu-principal,s,1)
```

## Utilisation

- Utilisez l'interface FreePBX pour gérer les extensions, routes et autres fonctionnalités téléphoniques.
- Surveillez les logs Asterisk pour le traitement des appels et le dépannage.

## Contribution

N'hésitez pas à soumettre des issues ou des pull requests si vous avez des suggestions ou des améliorations pour le projet.

## Licence

Ce projet est sous licence MIT. Voir le fichier LICENSE pour plus de détails.