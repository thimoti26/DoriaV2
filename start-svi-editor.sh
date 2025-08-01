#!/bin/bash

# Script de démarrage pour l'éditeur SVI Angular

echo "🚀 Démarrage de l'éditeur SVI Angular avec Docker..."

# Arrêter les containers existants
echo "🛑 Arrêt des containers existants..."
docker stop svi-flow-editor 2>/dev/null || true
docker rm svi-flow-editor 2>/dev/null || true

# Construire l'image Docker
echo "🔨 Construction de l'image Docker..."
cd frontend/angular
docker build -t svi-angular-editor .

# Lancer le container
echo "🐳 Lancement du container..."
docker run -d \
  --name svi-flow-editor \
  -p 4200:4200 \
  -v $(pwd)/src:/app/src \
  svi-angular-editor

echo "✅ L'application Angular est maintenant accessible sur http://localhost:4200"
echo "📋 Pour voir les logs : docker logs -f svi-flow-editor"
echo "🛑 Pour arrêter : docker stop svi-flow-editor"
