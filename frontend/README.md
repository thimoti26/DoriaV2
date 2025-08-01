# 🎨 Frontend - SVI Éditeur Angular

## 📁 Structure

```
frontend/
├── angular/                     # Application Angular SVI
│   ├── src/                     # Code source TypeScript
│   ├── Dockerfile              # Container de développement Node.js
│   ├── Dockerfile.nginx        # Container de production Nginx
│   ├── nginx.conf              # Configuration Nginx
│   ├── package.json            # Dépendances npm
│   └── README.md               # Documentation Angular
```

## 🚀 Démarrage rapide

### Développement
```bash
cd frontend/angular
npm install
npm start
# Application disponible sur http://localhost:4200
```

### Production avec Docker
```bash
# Build et déploiement avec Nginx
cd frontend/angular
docker build -f Dockerfile.nginx -t doria-frontend .
docker run -p 3000:3000 doria-frontend
```

## 🔧 Technologies

- **Angular 15** - Framework frontend
- **TypeScript** - Langage principal
- **RxJS** - Programmation réactive
- **Nginx** - Serveur web de production
- **Docker** - Containerisation

## 📋 Fonctionnalités

- ✅ Éditeur de flux SVI drag & drop
- ✅ Gestion des utilisateurs SIP
- ✅ Gestionnaire de fichiers audio
- ✅ Interface responsive moderne
- ✅ API REST intégrée
