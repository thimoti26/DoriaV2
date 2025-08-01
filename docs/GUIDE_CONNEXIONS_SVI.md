# 🔗 Guide - Comment Créer des Connexions SVI

## 🎯 Instructions Pas à Pas

### Étape 1 : Accéder à l'Éditeur
1. Ouvrir http://localhost:53536
2. L'éditeur SVI s'affiche avec la palette d'outils à gauche

### Étape 2 : Créer des Nœuds
1. **Glisser-déposer** des éléments depuis la palette vers la zone de travail
2. Commencer par un nœud **"Début"** (Start)
3. Ajouter un nœud **"Menu"** ou **"Action"**

### Étape 3 : Identifier les Points de Connexion
**Points de connexion améliorés** (visibles avec les dernières modifications) :
- 🔵 **Points d'entrée** : Cercles bleus en **haut** des nœuds
- 🔵 **Points de sortie** : Cercles bleus en **bas** des nœuds  
- 🟢 **Sorties multiples** : Carrés verts sur le côté droit (menus/conditions)

### Étape 4 : Créer une Connexion
1. **Cliquer** sur un **point de sortie** (cercle en bas du nœud source)
2. **Maintenir le clic** et voir la ligne pointillée apparaître
3. **Déplacer** la souris vers le nœud destination
4. **Cliquer** sur le **point d'entrée** (cercle en haut du nœud destination)

## 🔍 Débogage en Temps Réel

### Console du Navigateur
Ouvrir les **Outils de Développement** (F12) et surveiller la console pour :
```
🔗 startConnection: {nodeId: "node_1", nodeType: "start", port: "output"}
🔗 Mode connexion activé, tempConnection: {...}
🎯 endConnection: {nodeId: "node_2", nodeType: "menu", port: "input"}
✅ Tentative de connexion: {from: "node_1", to: "node_2", ...}
🎉 Connexion créée avec succès!
```

### Messages d'Erreur Possibles
- ❌ **"Port non valide"** : Vous avez cliqué sur un point d'entrée pour commencer
- ❌ **"Connexion invalide"** : Tentative de connexion d'un nœud vers lui-même
- ❌ **"Conditions non remplies"** : Le processus de connexion n'a pas été correctement initié

## 🎨 Amélirations Visuelles Appliquées

### Points de Connexion Plus Visibles
- **Taille augmentée** : 14px au lieu de 12px
- **Bordure plus épaisse** : 3px au lieu de 2px
- **Ombre ajoutée** : Pour améliorer la visibilité
- **Hover amélioré** : Bordure rouge et agrandissement

### Ligne de Connexion Temporaire
- **Ligne pointillée bleue** pendant la création
- **Feedback visuel immédiat** lors du déplacement de la souris

## 🛠️ Résolution de Problèmes

### Problème : Points Non Visibles
**Solution** : Recharger la page après les modifications CSS

### Problème : Clic Non Détecté  
**Solution** : S'assurer de cliquer précisément sur les petits cercles

### Problème : Connexion Ne Se Crée Pas
**Solutions** :
1. Vérifier l'ordre : **Sortie → Entrée** (pas l'inverse)
2. S'assurer que les nœuds sont différents
3. Vérifier qu'il n'y a pas déjà une connexion entre ces nœuds

## 🎯 Test Rapide

### Scénario de Test Simple
1. Créer un nœud **"Début"**
2. Créer un nœud **"Menu"** 
3. Connecter : **Début (sortie)** → **Menu (entrée)**
4. Voir la ligne apparaître entre les deux nœuds

---

> 💡 **Astuce** : Les logs dans la console vous aideront à comprendre exactement ce qui se passe lors de vos tentatives de connexion.
