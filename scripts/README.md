# 🛠️ Scripts Utilitaires DoriaV2

## 📋 Scripts de Gestion et Maintenance

Ce dossier contient les scripts utilitaires pour la gestion, maintenance et configuration de la stack DoriaV2.

### ⚙️ Scripts Disponibles

| Script | Description | Usage |
|--------|-------------|-------|
| **reload-config.sh** | Rechargement des configurations | `./reload-config.sh [service]` |
| **update-volumes.sh** | Mise à jour des volumes | `./update-volumes.sh` |
| **cleanup.sh** | Nettoyage du système | `./cleanup.sh` |

### 🚀 Utilisation

#### Rechargement des Configurations
```bash
# Recharger toutes les configurations
./reload-config.sh

# Recharger un service spécifique
./reload-config.sh asterisk
./reload-config.sh apache
./reload-config.sh mysql
```

#### Mise à Jour des Volumes
```bash
# Mettre à jour les volumes de configuration
./update-volumes.sh
```

#### Nettoyage Système
```bash
# Nettoyer les fichiers temporaires et logs
./cleanup.sh
```

### 🎯 Usage depuis la Racine

Utilisez le script principal pour plus de simplicité :

```bash
# Depuis /Users/thibaut/workspace/DoriaV2/
./doria.sh reload          # Rechargement complet
./doria.sh reload-asterisk # Asterisk uniquement
./doria.sh cleanup         # Nettoyage
```

### 📚 Documentation Associée

- `../docs/VOLUMES_CONFIG.md` - Configuration des volumes
- `../docs/SCRIPT_CLEANUP_SUMMARY.md` - Détails du nettoyage
- `../docs/GUIDE_UTILISATEUR.md` - Guide général

### 🔧 Maintenance Préventive

Scripts recommandés pour la maintenance régulière :

1. **Quotidienne** : `cleanup.sh`
2. **Hebdomadaire** : `update-volumes.sh`
3. **Après modification** : `reload-config.sh`

---

💡 **Conseil** : Ces scripts sont intégrés dans `../doria.sh` pour une utilisation centralisée.
