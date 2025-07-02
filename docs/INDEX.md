# 📚 Documentation DoriaV2

## 📖 Index de la Documentation

### 🚀 Guides de Démarrage

| Document | Description |
|----------|-------------|
| **GUIDE_UTILISATEUR.md** | Guide d'utilisation général de DoriaV2 |
| **TUTORIEL_LINPHONE.md** | Configuration pas-à-pas de Linphone |
| **README_FINAL.md** | Résumé complet du projet |

### ⚙️ Configuration et Administration

| Document | Description |
|----------|-------------|
| **VOLUMES_CONFIG.md** | Gestion des volumes et configuration à chaud |
| **SCRIPT_CLEANUP_SUMMARY.md** | Résumé du nettoyage des scripts |

### 🔧 Dépannage et Maintenance

| Document | Description |
|----------|-------------|
| **TROUBLESHOOTING_AUDIO.md** | Résolution des problèmes audio |
| **TROUBLESHOOTING_PJSIP.md** | Correction des erreurs PJSIP |
| **FIX_SVI_9999.md** | Résolution du problème SVI 9999 |

### 📱 Guides Spécialisés

| Document | Description |
|----------|-------------|
| **GUIDE_SVI_9999.md** | Guide complet du Serveur Vocal Interactif |
| **GUIDE_SVI_MULTILINGUAL.md** | 🌐 **SVI Multilingue (FR/EN)** |
| **TUTORIEL_LINPHONE_SUMMARY.md** | Résumé du tutoriel Linphone |

### 📋 Résumés Techniques

| Document | Description |
|----------|-------------|
| **README_VOLUMES.md** | Résumé de la configuration des volumes |

## 🎯 Guides par Cas d'Usage

### Je débute avec DoriaV2
1. **GUIDE_UTILISATEUR.md** - Vue d'ensemble
2. **TUTORIEL_LINPHONE.md** - Configuration client
3. **README_FINAL.md** - Résumé complet

### Je veux configurer Linphone
1. **TUTORIEL_LINPHONE.md** - Guide détaillé
2. **TROUBLESHOOTING_PJSIP.md** - Si problèmes de connexion

### J'ai des problèmes audio
1. **TROUBLESHOOTING_AUDIO.md** - Diagnostic audio
2. **GUIDE_UTILISATEUR.md** - Extensions de test

### Je veux utiliser le SVI (9999)
1. **GUIDE_SVI_9999.md** - Guide complet du SVI
2. **FIX_SVI_9999.md** - Si problèmes d'accès

### Je veux modifier les configurations
1. **VOLUMES_CONFIG.md** - Gestion des volumes
2. **SCRIPT_CLEANUP_SUMMARY.md** - Scripts disponibles

### J'administre le serveur
1. **README_VOLUMES.md** - Architecture des volumes
2. **TROUBLESHOOTING_*.md** - Guides de dépannage

## 🛠️ Scripts Associés

Les scripts sont organisés dans deux dossiers :

### 🧪 Tests (`../tests/`)
| Script | Documentation |
|--------|---------------|
| `test-stack.sh` | Test complet de la stack |
| `test-linphone.sh` | TUTORIEL_LINPHONE.md |
| `test-audio-auto.sh` | TROUBLESHOOTING_AUDIO.md |
| `debug-audio.sh` | Monitoring temps réel |
| `test-network.sh` | Test connectivité |
| `test-volumes.sh` | README_VOLUMES.md |

### 🛠️ Utilitaires (`../scripts/`)
| Script | Documentation |
|--------|---------------|
| `reload-config.sh` | VOLUMES_CONFIG.md |
| `update-volumes.sh` | Gestion des volumes |
| `cleanup.sh` | SCRIPT_CLEANUP_SUMMARY.md |

## 📞 Support

Pour toute question :
1. Consultez le guide correspondant ci-dessus
2. Utilisez les scripts de test dans `../tests/`
3. Utilisez les scripts utilitaires dans `../scripts/`  
4. Vérifiez les logs avec `../doria.sh debug-audio`

---

💡 **Conseil** : Commencez par le **GUIDE_UTILISATEUR.md** pour une vue d'ensemble, puis consultez les guides spécialisés selon vos besoins.

📁 **Structure** : Consultez `../ARCHITECTURE.md` pour l'architecture complète du projet.
