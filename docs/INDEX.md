# Documentation DoriaV2 - Index

## 📁 Structure de la Documentation

### 🏗️ Architecture
- [architecture/](architecture/) - Diagrammes et documentation d'architecture

### 📖 Guides Utilisateur
- [guides/GUIDE_NAVIGATION_SVI.md](guides/GUIDE_NAVIGATION_SVI.md) - Guide complet de navigation SVI
- [guides/GUIDE_DRAG_DROP_SVI.md](guides/GUIDE_DRAG_DROP_SVI.md) - Guide du drag & drop ✨ NOUVEAU
- [guides/CONFIG_VISUALIZATION_GUIDE.md](guides/CONFIG_VISUALIZATION_GUIDE.md) - Visualisation de configuration
- [guides/GUIDE_SIP_UNREACHABLE.md](guides/GUIDE_SIP_UNREACHABLE.md) - Gestion contacts SIP "Unreachable" ✨ NOUVEAU

### 🧪 Tests et Validation
- [tests/SVI_ADMIN_TEST_RESULTS.md](tests/SVI_ADMIN_TEST_RESULTS.md) - Résultats des tests SVI Admin
- [tests/TABS_FIX_COMPLETE.md](tests/TABS_FIX_COMPLETE.md) - Correction des onglets
- [tests/AMELIORATIONS_COMPLETEES.md](tests/AMELIORATIONS_COMPLETEES.md) - Améliorations complétées
- [tests/DRAG_DROP_FIX_COMPLETE.md](tests/DRAG_DROP_FIX_COMPLETE.md) - Correction drag & drop ✨ NOUVEAU

### 💡 Exemples
- [examples/EXEMPLE_NAVIGATION_COMPLETE.md](examples/EXEMPLE_NAVIGATION_COMPLETE.md) - Exemple complet de navigation

## 🚀 Démarrage Rapide

1. **Installation**: `docker-compose up -d`
2. **Interface SVI**: http://localhost:8080/svi-admin/
3. **Tests**: `./tests/test-final.sh`

## 🔧 Scripts Utiles

- `./scripts/organize-project.sh` - Organisation du projet
- `./scripts/cleanup.sh` - Nettoyage
- `./scripts/reload-config.sh` - Rechargement configuration
- `./scripts/diagnose-sip.sh` - Diagnostic contacts SIP ✨ NOUVEAU

## 🚨 Résolution Rapide

- [SIP_UNREACHABLE_QUICK_FIX.md](SIP_UNREACHABLE_QUICK_FIX.md) - Messages "Unreachable" normaux ⚡

## 📞 Interface SVI Admin

L'interface d'administration SVI est accessible à : http://localhost:8080/svi-admin/

### Fonctionnalités Principales:
- ✅ Éditeur visuel de flux SVI
- ✅ Drag & drop des actions
- ✅ Simulation de parcours
- ✅ Génération automatique extensions.conf
- ✅ Upload de fichiers audio
- ✅ Gestion multilingue

---
*Dernière mise à jour: 3 juillet 2025*
