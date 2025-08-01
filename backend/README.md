# 🖥️ Backend - API PHP & SVI Admin

## 📁 Structure

```
backend/
├── php/                         # Application PHP
│   ├── svi-admin/              # Interface d'administration SVI
│   ├── api/                    # API REST
│   ├── flows/                  # Gestion des flux SVI
│   ├── asterisk-config/        # Configuration Asterisk
│   ├── uploads/                # Fichiers uploadés
│   └── index.php              # Point d'entrée
├── Dockerfile                  # Container PHP + Apache
└── README.md                  # Cette documentation
```

## 🚀 Démarrage rapide

### Développement local
```bash
cd backend/php
php -S localhost:8000
# Interface disponible sur http://localhost:8000
```

### Production avec Docker
```bash
cd backend
docker build -t doria-backend .
docker run -p 8080:80 doria-backend
```

## 🔧 Technologies

- **PHP 8.2** - Langage backend
- **Apache** - Serveur web
- **MySQL** - Base de données
- **Redis** - Cache et sessions
- **Docker** - Containerisation

## 📋 Fonctionnalités

- ✅ Interface SVI Admin avec drag & drop
- ✅ API REST pour gestion des flux
- ✅ Intégration Asterisk
- ✅ Gestion des fichiers audio
- ✅ Configuration multilingue
- ✅ Tests et diagnostics intégrés
