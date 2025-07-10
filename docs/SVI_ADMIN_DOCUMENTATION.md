# Documentation SVI Admin - Interface d'Administration

## 📋 Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Architecture technique](#architecture-technique)
3. [Fonctionnalités principales](#fonctionnalités-principales)
4. [Interface utilisateur](#interface-utilisateur)
5. [Gestion des étapes](#gestion-des-étapes)
6. [Propriétés et configuration](#propriétés-et-configuration)
7. [Gestion des fichiers audio](#gestion-des-fichiers-audio)
8. [API et endpoints](#api-et-endpoints)
9. [Déploiement avec Docker](#déploiement-avec-docker)
10. [Développement et maintenance](#développement-et-maintenance)

---

## 🎯 Vue d'ensemble

L'interface SVI Admin est une application web moderne permettant de créer, configurer et gérer des Serveurs Vocaux Interactifs (SVI) basés sur Asterisk. Elle offre une interface graphique intuitive avec fonctionnalités de glisser-déposer pour construire des flux d'appels complexes.

### Objectifs principaux :
- **Simplicité** : Interface unifiée sans duplication de code
- **Fonctionnalité** : Drag & Drop, ajout/édition/suppression d'étapes
- **Modernité** : Technologies web actuelles (HTML5, CSS3, JavaScript ES6+)
- **Containerisation** : Déploiement Docker complet

---

## 🏗️ Architecture technique

### Structure des fichiers :
```
src/svi-admin/
├── index.html              # Interface principale
├── css/
│   └── svi-simple.css      # Styles unifiés
├── js/
│   ├── svi-admin.js        # Logique principale
│   ├── api-client.js       # Client API
│   ├── audio-manager.js    # Gestion audio
│   └── svi-simulator.js    # Simulateur SVI
├── api/                    # Endpoints PHP
│   ├── save-config.php     # Sauvegarde config
│   ├── load-config.php     # Chargement config
│   ├── upload-audio.php    # Upload fichiers audio
│   └── ...
├── uploads/                # Fichiers audio uploadés
└── includes/              # Utilitaires PHP
```

### Technologies utilisées :
- **Frontend** : HTML5, CSS3, JavaScript ES6+
- **Backend** : PHP 8.2, MySQL 8.0, Redis
- **Bibliothèques** : SortableJS, Toastify, Font Awesome
- **Serveur** : Apache 2.4, Asterisk 20
- **Containerisation** : Docker, Docker Compose

---

## ⚡ Fonctionnalités principales

### 1. **Interface de conception visuelle**
- **Drag & Drop** : Glisser-déposer des composants depuis la boîte à outils
- **Éditeur graphique** : Organisation visuelle des étapes du flux d'appels
- **Prévisualisation** : Aperçu en temps réel de la configuration

### 2. **Gestion des étapes SVI**
- **Ajout d'étapes** : Bouton "Ajouter Étape" avec sélection de type
- **Édition** : Modification des propriétés via le panneau latéral
- **Suppression** : Suppression sécurisée avec confirmation
- **Réorganisation** : Drag & drop pour changer l'ordre

### 3. **Types d'étapes supportés**
- **Accueil** : Message d'accueil personnalisé
- **Menu** : Menu à choix multiples avec navigation
- **Collecte DTMF** : Saisie de codes/numéros
- **Transfert** : Redirection vers numéro/poste
- **Condition** : Logique conditionnelle
- **Fin** : Terminaison du flux

### 4. **Gestion audio**
- **Upload** : Téléchargement de fichiers audio (.wav, .mp3, .gsm)
- **Prévisualisation** : Écoute des fichiers avant utilisation
- **Gestion** : Liste, suppression, remplacement des fichiers
- **Formats supportés** : WAV, MP3, GSM, ULAW, ALAW

### 5. **Multi-contextes**
- **Contextes séparés** : Différents flux SVI (accueil, support, etc.)
- **Onglets** : Navigation entre contextes
- **Configuration indépendante** : Chaque contexte a sa propre config

---

## 🖥️ Interface utilisateur

### Header (En-tête)
```html
<header class="app-header">
    <h1>SVI Admin</h1>
    <div class="header-actions">
        <button id="saveBtn">Sauvegarder</button>
        <button id="testBtn">Tester</button>
        <button id="reloadBtn">Recharger Asterisk</button>
    </div>
</header>
```

**Fonctionnalités :**
- **Sauvegarde** : Enregistrement de la configuration courante
- **Test** : Simulation du flux d'appels
- **Reload** : Rechargement de la configuration Asterisk

### Sidebar (Panneau latéral)
```html
<aside class="sidebar">
    <div class="toolbox">
        <h3>Boîte à outils</h3>
        <div class="tool-item" data-type="welcome">Accueil</div>
        <div class="tool-item" data-type="menu">Menu</div>
        <div class="tool-item" data-type="dtmf">Collecte DTMF</div>
        <div class="tool-item" data-type="transfer">Transfert</div>
        <div class="tool-item" data-type="condition">Condition</div>
        <div class="tool-item" data-type="end">Fin</div>
    </div>
</aside>
```

**Fonctionnalités :**
- **Drag & Drop** : Glisser les éléments vers l'éditeur
- **Types d'étapes** : Différents composants SVI
- **Icônes** : Représentation visuelle des types

### Zone principale
```html
<main class="main-content">
    <div class="context-tabs">
        <button class="tab-button active" data-context="main">Principal</button>
        <button class="tab-button" data-context="support">Support</button>
        <button class="tab-button" data-context="sales">Ventes</button>
    </div>
    
    <div class="editor-container">
        <div id="stepsContainer" class="steps-container"></div>
        <button id="addStepBtn">+ Ajouter Étape</button>
    </div>
</main>
```

**Fonctionnalités :**
- **Onglets contextes** : Navigation entre différents SVI
- **Conteneur d'étapes** : Zone de construction du flux
- **Bouton d'ajout** : Ajout rapide d'étapes

### Panneau de propriétés
```html
<div class="properties-panel">
    <h3>Propriétés</h3>
    <div id="propertiesContent">
        <!-- Contenu dynamique selon l'étape sélectionnée -->
    </div>
</div>
```

**Fonctionnalités :**
- **Édition contextuelle** : Propriétés de l'étape sélectionnée
- **Validation** : Vérification des données saisies
- **Sauvegarde auto** : Mise à jour automatique

---

## 📝 Gestion des étapes

### Ajout d'étapes

#### Méthode 1 : Drag & Drop
```javascript
// Depuis la boîte à outils
const toolItem = document.querySelector('.tool-item[data-type="welcome"]');
// Glisser vers la zone d'édition
// → Création automatique d'une étape "Accueil"
```

#### Méthode 2 : Bouton "Ajouter Étape"
```javascript
document.getElementById('addStepBtn').addEventListener('click', function() {
    // Affichage d'un menu de sélection
    // → Choix du type d'étape
    // → Ajout à la fin de la liste
});
```

### Types d'étapes détaillés

#### 1. Étape "Accueil"
```javascript
{
    type: 'welcome',
    name: 'Accueil',
    properties: {
        audioFile: 'welcome.wav',
        message: 'Bienvenue sur notre serveur vocal',
        timeout: 5000,
        repeatCount: 2
    }
}
```

#### 2. Étape "Menu"
```javascript
{
    type: 'menu',
    name: 'Menu principal',
    properties: {
        audioFile: 'menu.wav',
        message: 'Tapez 1 pour..., 2 pour...',
        options: [
            { digit: '1', action: 'goto', target: 'step_2' },
            { digit: '2', action: 'goto', target: 'step_3' },
            { digit: '0', action: 'transfer', target: '100' }
        ],
        timeout: 10000,
        invalidRetries: 3
    }
}
```

#### 3. Étape "Collecte DTMF"
```javascript
{
    type: 'dtmf',
    name: 'Saisie code',
    properties: {
        audioFile: 'enter_code.wav',
        message: 'Veuillez saisir votre code',
        minDigits: 4,
        maxDigits: 8,
        timeout: 15000,
        variable: 'user_code',
        validation: 'numeric'
    }
}
```

#### 4. Étape "Transfert"
```javascript
{
    type: 'transfer',
    name: 'Transfert',
    properties: {
        destination: '100',
        announceFile: 'transfer.wav',
        timeout: 30000,
        options: 'tr'  // t = transfert, r = enregistrement
    }
}
```

#### 5. Étape "Condition"
```javascript
{
    type: 'condition',
    name: 'Condition',
    properties: {
        variable: 'user_code',
        operator: 'equals',
        value: '1234',
        trueAction: 'goto',
        trueTarget: 'step_success',
        falseAction: 'goto',
        falseTarget: 'step_error'
    }
}
```

#### 6. Étape "Fin"
```javascript
{
    type: 'end',
    name: 'Fin',
    properties: {
        audioFile: 'goodbye.wav',
        message: 'Merci de votre appel',
        hangup: true
    }
}
```

---

## ⚙️ Propriétés et configuration

### Panneau de propriétés dynamique

Le panneau de propriétés s'adapte selon le type d'étape sélectionnée :

```javascript
function showStepProperties(step) {
    const propertiesContent = document.getElementById('propertiesContent');
    
    switch(step.type) {
        case 'welcome':
            propertiesContent.innerHTML = `
                <div class="property-group">
                    <label>Nom de l'étape</label>
                    <input type="text" id="stepName" value="${step.name}">
                </div>
                <div class="property-group">
                    <label>Fichier audio</label>
                    <select id="audioFile">
                        <option value="">Sélectionner...</option>
                        <!-- Options dynamiques -->
                    </select>
                </div>
                <div class="property-group">
                    <label>Message TTS</label>
                    <textarea id="message">${step.properties.message || ''}</textarea>
                </div>
                <div class="property-group">
                    <label>Timeout (ms)</label>
                    <input type="number" id="timeout" value="${step.properties.timeout || 5000}">
                </div>
            `;
            break;
        // ... autres types
    }
}
```

### Validation des propriétés

```javascript
function validateStepProperties(step) {
    const errors = [];
    
    // Validation commune
    if (!step.name || step.name.trim() === '') {
        errors.push('Le nom de l\'étape est requis');
    }
    
    // Validation spécifique par type
    switch(step.type) {
        case 'menu':
            if (!step.properties.options || step.properties.options.length === 0) {
                errors.push('Le menu doit avoir au moins une option');
            }
            break;
        case 'dtmf':
            if (step.properties.minDigits > step.properties.maxDigits) {
                errors.push('Le nombre minimum de chiffres ne peut pas être supérieur au maximum');
            }
            break;
        case 'transfer':
            if (!step.properties.destination) {
                errors.push('La destination du transfert est requise');
            }
            break;
    }
    
    return errors;
}
```

---

## 🎵 Gestion des fichiers audio

### Upload de fichiers

```javascript
class AudioManager {
    constructor() {
        this.supportedFormats = ['wav', 'mp3', 'gsm', 'ulaw', 'alaw'];
        this.maxFileSize = 10 * 1024 * 1024; // 10MB
    }
    
    async uploadFile(file) {
        // Validation du fichier
        if (!this.validateFile(file)) {
            throw new Error('Format de fichier non supporté');
        }
        
        // Upload via API
        const formData = new FormData();
        formData.append('audio', file);
        
        const response = await fetch('/svi-admin/api/upload-audio.php', {
            method: 'POST',
            body: formData
        });
        
        return await response.json();
    }
    
    validateFile(file) {
        const extension = file.name.split('.').pop().toLowerCase();
        return this.supportedFormats.includes(extension) && 
               file.size <= this.maxFileSize;
    }
}
```

### Prévisualisation audio

```javascript
function previewAudio(filename) {
    const audio = new Audio(`/svi-admin/uploads/${filename}`);
    audio.controls = true;
    
    const modal = document.createElement('div');
    modal.className = 'audio-preview-modal';
    modal.innerHTML = `
        <div class="modal-content">
            <h3>Prévisualisation : ${filename}</h3>
            <div class="audio-player">
                ${audio.outerHTML}
            </div>
            <button onclick="closeModal()">Fermer</button>
        </div>
    `;
    
    document.body.appendChild(modal);
}
```

### Gestion des fichiers

```javascript
class AudioFileManager {
    async listFiles() {
        const response = await fetch('/svi-admin/api/list-audio.php');
        return await response.json();
    }
    
    async deleteFile(filename) {
        const response = await fetch('/svi-admin/api/delete-audio.php', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ filename })
        });
        return await response.json();
    }
    
    async renameFile(oldName, newName) {
        const response = await fetch('/svi-admin/api/rename-audio.php', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ oldName, newName })
        });
        return await response.json();
    }
}
```

---

## 🔌 API et endpoints

### Endpoints disponibles

#### Configuration SVI
```php
// /svi-admin/api/save-config.php
POST /svi-admin/api/save-config.php
{
    "context": "main",
    "steps": [...],
    "settings": {...}
}

// /svi-admin/api/load-config.php
GET /svi-admin/api/load-config.php?context=main
```

#### Gestion audio
```php
// /svi-admin/api/upload-audio.php
POST /svi-admin/api/upload-audio.php
Content-Type: multipart/form-data
File: audio

// /svi-admin/api/list-audio.php
GET /svi-admin/api/list-audio.php
```

#### Contrôle Asterisk
```php
// /svi-admin/api/reload-asterisk.php
POST /svi-admin/api/reload-asterisk.php

// /svi-admin/api/validate-syntax.php
POST /svi-admin/api/validate-syntax.php
{
    "config": "..."
}
```

#### Historique et monitoring
```php
// /svi-admin/api/call-history.php
GET /svi-admin/api/call-history.php?limit=100&offset=0

// /svi-admin/api/get-statistics.php
GET /svi-admin/api/get-statistics.php?period=today
```

### Client API JavaScript

```javascript
class SVIApiClient {
    constructor() {
        this.baseUrl = '/svi-admin/api';
    }
    
    async saveConfig(context, config) {
        const response = await fetch(`${this.baseUrl}/save-config.php`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ context, config })
        });
        return await response.json();
    }
    
    async loadConfig(context) {
        const response = await fetch(`${this.baseUrl}/load-config.php?context=${context}`);
        return await response.json();
    }
    
    async reloadAsterisk() {
        const response = await fetch(`${this.baseUrl}/reload-asterisk.php`, {
            method: 'POST'
        });
        return await response.json();
    }
    
    async validateSyntax(config) {
        const response = await fetch(`${this.baseUrl}/validate-syntax.php`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ config })
        });
        return await response.json();
    }
}
```

---

## 🐳 Déploiement avec Docker

### Structure des volumes

```yaml
# compose.yml
services:
  web:
    build: 
      context: .
      dockerfile: web/Dockerfile
    volumes:
      # Code source (développement)
      - ./src:/var/www/html
      # Configurations Asterisk
      - ./asterisk/config:/var/www/html/asterisk-config
      - ./asterisk/sounds:/var/www/html/asterisk-sounds
      # Logs
      - web_logs:/var/log/apache2
```

### Avantages des volumes vs COPY

| Aspect | Volumes | COPY |
|--------|---------|------|
| **Développement** | ✅ Modifications en temps réel | ❌ Rebuild nécessaire |
| **Performance** | ✅ Accès direct au système de fichiers | ⚠️ Légèrement plus lent |
| **Sécurité** | ⚠️ Accès au système hôte | ✅ Isolation complète |
| **Déploiement** | ✅ Flexible, configurable | ✅ Prédictible |
| **Maintenance** | ✅ Mise à jour sans rebuild | ❌ Rebuild pour chaque changement |

### Script d'initialisation

```bash
#!/bin/bash
# /docker-entrypoint.sh

set -e

# Mise à jour des permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html
chmod -R 775 /var/www/html/svi-admin/uploads

# Création du fichier de redirection si nécessaire
if [ ! -f /var/www/html/index.php ]; then
    echo '<?php header("Location: /svi-admin/"); exit; ?>' > /var/www/html/index.php
fi

# Démarrage d'Apache
exec apache2-foreground
```

### Commandes de déploiement

```bash
# Arrêt des services
docker-compose down

# Reconstruction avec volumes
docker-compose up -d --build

# Vérification du statut
docker-compose ps

# Suivi des logs
docker-compose logs -f web
```

---

## 👨‍💻 Développement et maintenance

### Structure de développement

```
DoriaV2/
├── src/svi-admin/           # Code source principal
├── web/Dockerfile           # Configuration Apache/PHP
├── compose.yml             # Orchestration Docker
├── docs/                   # Documentation
└── tests/                  # Tests et scripts
```

### Workflow de développement

1. **Modification des fichiers** dans `src/svi-admin/`
2. **Rechargement automatique** grâce aux volumes
3. **Tests** via l'interface web
4. **Validation** avec les API endpoints
5. **Commit** des changements

### Debugging et logs

```bash
# Logs Apache
docker-compose logs web

# Logs PHP
docker-compose exec web tail -f /var/log/apache2/error.log

# Logs MySQL
docker-compose logs mysql

# Logs Asterisk
docker-compose logs asterisk
```

### Tests et validation

```javascript
// Test de l'API
async function testAPI() {
    const client = new SVIApiClient();
    
    try {
        // Test de sauvegarde
        const saveResult = await client.saveConfig('test', {
            steps: [
                { type: 'welcome', name: 'Test' }
            ]
        });
        console.log('Save:', saveResult);
        
        // Test de chargement
        const loadResult = await client.loadConfig('test');
        console.log('Load:', loadResult);
        
        // Test de validation
        const validateResult = await client.validateSyntax('test config');
        console.log('Validate:', validateResult);
        
    } catch (error) {
        console.error('Test failed:', error);
    }
}
```

### Maintenance et monitoring

```bash
# Nettoyage des volumes
docker-compose down -v

# Sauvegarde des données
docker-compose exec mysql mysqldump -u root -p doriav2 > backup.sql

# Restauration
docker-compose exec mysql mysql -u root -p doriav2 < backup.sql

# Monitoring des ressources
docker stats doriav2-web doriav2-mysql doriav2-asterisk
```

---

## 🎯 Résumé des fonctionnalités

### ✅ Fonctionnalités implémentées

1. **Interface unifiée** - Une seule page d'administration
2. **Drag & Drop** - Glisser-déposer fonctionnel avec SortableJS
3. **Bouton "Ajouter Étape"** - Ajout rapide d'éléments
4. **Gestion des propriétés** - Panneau de configuration dynamique
5. **Multi-contextes** - Onglets pour différents SVI
6. **Gestion audio** - Upload, prévisualisation, gestion des fichiers
7. **API REST** - Endpoints pour toutes les opérations
8. **Containerisation** - Docker avec volumes pour le développement
9. **Validation** - Vérification des configurations
10. **Monitoring** - Logs et diagnostics

### 🚀 Utilisation recommandée

1. **Accès** : http://localhost:8080/svi-admin/
2. **Créer un flux** : Glisser des éléments depuis la boîte à outils
3. **Configurer** : Sélectionner une étape et modifier ses propriétés
4. **Tester** : Utiliser le bouton "Tester" pour valider
5. **Sauvegarder** : Cliquer sur "Sauvegarder" pour enregistrer
6. **Déployer** : Utiliser "Recharger Asterisk" pour appliquer

Cette documentation couvre toutes les fonctionnalités de l'interface SVI Admin et fournit un guide complet pour son utilisation, développement et maintenance.
