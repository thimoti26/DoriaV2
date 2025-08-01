# 🚀 Éditeur SVI Angular - Guide Docker

## 📁 Structure du projet

```
DoriaV2/
├── angular-svi-editor/          # Application Angular isolée
│   ├── src/                     # Code source Angular
│   ├── Dockerfile              # Configuration Docker
│   ├── package.json            # Dépendances Node.js
│   └── angular.json            # Configuration Angular
├── docker-compose-angular.yml   # Configuration Docker Compose
├── start-svi-editor.sh         # Script de démarrage
└── README_ANGULAR.md           # Ce fichier
```

## 🐳 Utilisation avec Docker

### Démarrage rapide
```bash
./start-svi-editor.sh
```

### Commandes manuelles

#### 1. Construction de l'image
```bash
cd angular-svi-editor
docker build -t svi-angular-editor .
```

#### 2. Lancement du container
```bash
docker run -d \
  --name svi-flow-editor \
  -p 4200:4200 \
  -v $(pwd)/angular-svi-editor/src:/app/src \
  svi-angular-editor
```

#### 3. Accès à l'application
- URL : http://localhost:4200
- Hot reload activé pour le développement

### Gestion du container

#### Voir les logs
```bash
docker logs -f svi-flow-editor
```

#### Arrêter le container
```bash
docker stop svi-flow-editor
```

#### Redémarrer après modifications
```bash
docker restart svi-flow-editor
```

#### Supprimer le container
```bash
docker rm svi-flow-editor
```

## 🛠️ Développement

### Structure Angular
- **Components** : Interface utilisateur modulaire
- **Services** : Logique métier avec RxJS
- **Models** : Types TypeScript pour SVI
- **D3.js** : Visualisation des flux

### Fonctionnalités
- ✅ Palette de nœuds SVI
- ✅ Canvas de flux avec D3.js
- ✅ Drag & Drop HTML5
- ✅ Propriétés des nœuds
- ✅ Sauvegarde des flux
- ✅ Interface moderne CSS

### Technologies
- **Angular 15** : Framework principal
- **TypeScript** : Langage de développement
- **D3.js** : Visualisation interactive
- **RxJS** : Programmation réactive
- **SCSS** : Styles modernes

## 🔧 Configuration

### Variables d'environnement
- `NODE_ENV=development` : Mode développement
- Port par défaut : `4200`

### Volumes Docker
- `./angular-svi-editor/src:/app/src` : Hot reload du code source

## 📊 Architecture SVI

### Types de nœuds
1. **Start** : Point d'entrée
2. **Menu** : Choix utilisateur
3. **Action** : Exécution de tâches
4. **Condition** : Tests logiques
5. **Transfer** : Transfert d'appel
6. **End** : Fin de flux

### Flux de données
```
User Input → Node Palette → Canvas → Flow Service → Backend API
```

## 🚨 Dépannage

### Container ne démarre pas
```bash
# Vérifier Docker
docker --version

# Nettoyer les containers
docker system prune -f
```

### Port déjà utilisé
```bash
# Trouver le processus
lsof -i :4200

# Changer le port
docker run -p 4201:4200 svi-angular-editor
```

### Erreurs de compilation
```bash
# Reconstruire sans cache
docker build --no-cache -t svi-angular-editor .
```

## 📝 Notes

- Le code Angular est maintenant isolé dans `angular-svi-editor/`
- Hot reload fonctionne avec les volumes Docker
- Interface accessible via http://localhost:4200
- Logs disponibles via `docker logs`
