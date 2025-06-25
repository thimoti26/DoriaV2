# 🌐 Interface Web DoriaV2 Asterisk

Interface web moderne et complète pour la gestion du système Asterisk/FreePBX DoriaV2.

## 🚀 Fonctionnalités

### 📊 Tableau de bord
- **Statut en temps réel** du système Asterisk
- **Métriques système** (statut Asterisk, nombre d'extensions)
- **Actions rapides** (démarrer, arrêter, redémarrer)
- **Numéros de test** interactifs avec copie automatique

### 📞 Gestion des extensions
- **Configuration extension osmo** (1000) avec paramètres complets
- **Guide Linphone intégré** avec configuration automatique
- **Paramètres SIP** prêts à copier

### ⚙️ Administration système
- **Contrôle Docker** (up, down, restart, ps)
- **Commandes Asterisk** (status, reload, shell)
- **Informations système** détaillées
- **Liens vers documentation**

### 📄 Journaux temps réel
- **Logs Asterisk** avec colorisation syntaxique
- **Logs Docker** pour surveillance conteneurs
- **Actualisation automatique**
- **Formatage intelligent** des messages

## 🛠️ Technologies utilisées

- **Frontend**: HTML5, CSS3, JavaScript ES6+
- **Framework CSS**: Bootstrap 5.3
- **Icônes**: Font Awesome 6.4
- **Polices**: Inter, Fira Code
- **Backend**: Python 3 (serveur intégré)
- **API**: RESTful avec gestion d'erreurs

## 📁 Structure des fichiers

```
web-interface/
├── index.html          # Interface principale
├── styles.css          # Styles personnalisés
├── script.js           # JavaScript principal
├── server.py           # Serveur Python intégré
├── api.php             # API PHP (alternative)
└── config.json         # Configuration (généré auto)
```

## 🚀 Démarrage rapide

### Méthode 1: Script automatique (recommandé)
```bash
./start-web-interface.sh
```

### Méthode 2: Démarrage manuel
```bash
cd web-interface
python3 server.py 8080
```

### Méthode 3: Serveur PHP (si disponible)
```bash
cd web-interface
php -S localhost:8080
```

## 🌍 Accès à l'interface

Une fois démarré, l'interface est accessible sur :
- **Interface web**: http://localhost:8080
- **API REST**: http://localhost:8080/api/

## 📡 Endpoints API

### Statut système
```http
GET /api/status
```
Retourne le statut complet du système.

### Contrôle système
```http
POST /api/control/{action}
```
Actions disponibles: `start`, `stop`, `restart`, `status`

### Journaux
```http
GET /api/logs/{type}
```
Types disponibles: `asterisk`, `docker`

### Commandes Docker
```http
POST /api/docker/{action}
```
Actions disponibles: `up`, `down`, `restart`, `ps`

## 🎨 Fonctionnalités de l'interface

### 🎯 Design moderne
- **Gradient de fond** animé
- **Cards flottantes** avec effets de survol
- **Animations CSS** fluides
- **Responsive design** mobile-friendly
- **Thème sombre** automatique (selon préférences système)

### 🔔 Notifications intelligentes
- **Toast notifications** avec icônes contextuelle
- **Messages d'erreur/succès** colorisés
- **Durée d'affichage** personnalisable
- **Pile de notifications** gérée automatiquement

### ⌨️ Raccourcis clavier
- **Ctrl/Cmd + R**: Actualiser le statut
- **Ctrl/Cmd + 1-4**: Navigation entre onglets
- **ESC**: Fermer modales/notifications

### 📱 Responsivité
- **Mobile-first** design
- **Breakpoints** optimisés
- **Navigation tactile** améliorée
- **Affichage adaptatif** du contenu

## 🔧 Configuration

### Extension osmo
- **Numéro**: 1000
- **Username**: osmo
- **Password**: osmoosmo
- **Serveur**: localhost:5060
- **Transport**: UDP

### Numéros de test
- **\*43**: Test d'écho
- **\*97**: Messagerie vocale
- **123**: Message de bienvenue
- **1000**: Extension osmo

## 🐛 Dépannage

### Port déjà utilisé
Le script détecte automatiquement les ports occupés et propose des alternatives (8081, 8082, etc.).

### Python non trouvé
```bash
# macOS avec Homebrew
brew install python3

# Vérification
python3 --version
```

### Erreurs d'API
L'interface fonctionne en mode simulation si l'API n'est pas disponible, permettant de tester l'interface même sans backend.

### Logs non disponibles
L'interface génère des logs simulés pour démonstration si les vrais logs ne sont pas accessibles.

## 🔄 Actualisation automatique

- **Statut système**: Toutes les 30 secondes
- **Pause automatique**: Quand l'onglet n'est pas visible
- **Reprise automatique**: Au retour sur l'onglet
- **Gestion mémoire**: Nettoyage automatique des intervals

## 🎨 Personnalisation

### Variables CSS
```css
:root {
    --primary-color: #2c3e50;
    --secondary-color: #3498db;
    --success-color: #27ae60;
    --warning-color: #f39c12;
    --danger-color: #e74c3c;
}
```

### Configuration JavaScript
```javascript
const config = {
    statusCheckInterval: 30000,  // 30 secondes
    apiTimeout: 30,              // 30 secondes
    toastDuration: 5000          // 5 secondes
};
```

## 📊 Métriques et monitoring

L'interface affiche en temps réel :
- **Statut Asterisk** (en ligne/hors ligne)
- **Nombre d'extensions** configurées
- **Uptime système**
- **État des conteneurs Docker**
- **Dernière mise à jour**

## 🔐 Sécurité

- **Validation côté client** des entrées
- **Protection CSRF** basique
- **Timeouts** sur les requêtes API
- **Gestion d'erreurs** robuste
- **Pas de stockage** de données sensibles

## 🚀 Prochaines améliorations

- [ ] Interface WebRTC pour appels directs
- [ ] Éditeur de configuration intégré
- [ ] Monitoring avancé avec graphiques
- [ ] Support multi-langues
- [ ] Terminal web intégré
- [ ] Gestion multi-utilisateurs
- [ ] Notifications push

## 📞 Configuration Linphone

### Installation automatique
L'interface propose des liens directs vers :
- **Desktop**: [linphone.org](https://www.linphone.org/download)
- **Android**: Google Play Store
- **iOS**: App Store

### Configuration automatique
La modal intégrée fournit tous les paramètres prêts à copier pour une configuration rapide.

## 🆘 Support

Pour obtenir de l'aide :
1. Vérifiez les **journaux** dans l'onglet correspondant
2. Consultez la **documentation** dans `/docs/`
3. Utilisez les **scripts de diagnostic** dans `/scripts/`

## 📝 Notes de version

### v2.0.0 (Actuel)
- Interface web complète avec Bootstrap 5
- API REST fonctionnelle
- Gestion temps réel du statut
- Support mobile complet
- Thème moderne avec animations

---

🎯 **DoriaV2** - Interface web moderne pour Asterisk PBX
