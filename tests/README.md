# 🧪 Tests DoriaV2

## 📋 Scripts de Test et Validation

Ce dossier contient tous les scripts de test et de diagnostic pour valider le bon fonctionnement de la stack DoriaV2.

### 🎯 Scripts Disponibles

| Script | Description | Usage |
|--------|-------------|-------|
| **test-stack.sh** | Test complet de la stack Docker | `./test-stack.sh` |
| **test-audio-auto.sh** | Test automatique de l'audio | `./test-audio-auto.sh` |
| **test-linphone.sh** | Validation configuration Linphone | `./test-linphone.sh` |
| **test-network.sh** | Test connectivité réseau | `./test-network.sh` |
| **test-volumes.sh** | Validation des volumes | `./test-volumes.sh` |
| **test-final.sh** | Test final de validation | `./test-final.sh` |
| **debug-audio.sh** | Monitoring audio temps réel | `./debug-audio.sh` |

### 🚀 Utilisation Rapide

```bash
# Depuis la racine du projet
./doria.sh test           # Test complet
./doria.sh test-audio     # Test audio spécifique
./doria.sh debug-audio    # Monitoring audio

# Directement depuis ce dossier
cd tests/
./test-stack.sh          # Test de la stack
./debug-audio.sh         # Debug audio
```

### 📊 Tests par Catégorie

#### Tests Infrastructure
- `test-stack.sh` - Conteneurs Docker
- `test-network.sh` - Connectivité réseau
- `test-volumes.sh` - Volumes et configurations

#### Tests Audio/SIP
- `test-audio-auto.sh` - Validation audio automatique
- `test-linphone.sh` - Configuration clients SIP
- `debug-audio.sh` - Monitoring en temps réel

#### Tests Finaux
- `test-final.sh` - Validation complète du système

### 📚 Documentation Associée

Consultez le dossier `../docs/` pour la documentation détaillée :
- `TROUBLESHOOTING_AUDIO.md` - Pour les problèmes audio
- `TUTORIEL_LINPHONE.md` - Configuration Linphone
- `GUIDE_SVI_9999.md` - Tests du SVI

---

💡 **Conseil** : Utilisez le script principal `../doria.sh` pour lancer les tests de manière centralisée.
