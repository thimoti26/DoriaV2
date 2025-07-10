# 🖱️ Guide du Drag & Drop - SVI Admin

## 📋 Vue d'Ensemble

Le système de drag & drop de l'interface SVI Admin permet de créer et organiser visuellement les flux d'appel en glissant-déposant des éléments d'action.

---

## 🎯 Fonctionnalités Disponibles

### ✨ **Actions Glissables**

Dans la barre latérale gauche, vous trouverez 5 types d'actions disponibles :

| Action | Icône | Description |
|--------|-------|-------------|
| **Menu Audio** | 📋 | Lecture d'un fichier audio (message d'accueil, menu vocal) |
| **Transfert** | 📞 | Transfert vers une extension téléphonique |
| **Redirection** | ➡️ | Redirection vers un autre contexte SVI |
| **Raccrocher** | ❌ | Terminer l'appel |
| **Menu Précédent** | ⬅️ | Retour au menu précédent |

### 🎨 **Zone de Diagramme**

La zone centrale est votre espace de travail où vous pouvez :
- Glisser des actions pour créer des nœuds
- Repositionner les nœuds existants
- Éditer les propriétés des nœuds
- Supprimer des nœuds

---

## 🖱️ Comment Utiliser le Drag & Drop

### 1. **Créer un Nouveau Nœud**

1. **Sélectionner** une action dans la barre latérale
2. **Glisser** l'action vers la zone de diagramme
3. **Relâcher** à l'endroit souhaité
4. **Configurer** le nœud créé (extension, paramètres)

```
[Action Template] ➡️ [Zone Diagramme] = [Nouveau Nœud]
```

### 2. **Repositionner un Nœud**

1. **Cliquer** et maintenir sur un nœud existant
2. **Glisser** vers la nouvelle position
3. **Relâcher** pour valider
4. **Auto-sauvegarde** de la nouvelle position

### 3. **Éditer un Nœud**

1. **Hover** sur un nœud pour voir les boutons d'action
2. **Cliquer** sur le bouton "✏️ Éditer"
3. **Modifier** les paramètres (extension, destination, etc.)
4. **Valider** les modifications

### 4. **Supprimer un Nœud**

1. **Hover** sur un nœud pour voir les boutons d'action
2. **Cliquer** sur le bouton "🗑️ Supprimer"
3. **Confirmer** la suppression
4. **Auto-sauvegarde** après suppression

---

## 🎨 Feedback Visuel

### **Pendant le Drag**

- 🔍 **Élément source** : Devient semi-transparent et légèrement incliné
- 🎯 **Zone de drop** : Bordure bleue avec message d'aide
- ✨ **Survol de zone** : Bordure verte avec confirmation

### **États des Nœuds**

- 🟦 **Normal** : Bordure bleue, fond blanc
- 🟢 **Hover** : Bordure verte, légère élévation
- 🟡 **Édition** : Boutons d'action visibles
- 🔴 **Suppression** : Confirmation requise

---

## ⚙️ Configuration Automatique

### **Extensions Générées**

Le système génère automatiquement des extensions uniques :

- **Première action** : Extension "1"
- **Deuxième action** : Extension "2"
- **Etc.** : Incrémentation automatique
- **Conflit** : Utilisation d'un suffixe unique

### **Types de Nœuds**

Chaque type d'action génère un nœud spécialisé :

```javascript
// Exemple de nœud Menu Audio
{
    id: "node_1625123456789",
    type: "menu",
    extension: "1",
    description: "Lecture d'un menu audio",
    x: 150,
    y: 100
}
```

---

## 🔧 Intégration avec Asterisk

### **Génération automatique extensions.conf**

Chaque nœud créé contribue à la génération automatique du fichier `extensions.conf` :

```ini
[context_main_fr]
exten => 1,1,Playback(welcome-fr)
exten => 1,n,WaitExten(5)
exten => 2,1,Dial(SIP/operator)
exten => 9,1,Goto(main_menu,s,1)
```

### **Synchronisation en Temps Réel**

- ✅ **Création de nœud** → Ajout dans extensions.conf
- ✅ **Modification** → Mise à jour de la configuration
- ✅ **Suppression** → Retrait de la configuration
- ✅ **Repositionnement** → Sauvegarde de la position

---

## 📱 Exemple d'Utilisation Complète

### **Scénario : Créer un Menu Principal**

1. **Glisser "Menu Audio"** vers le diagramme
   - Extension automatique : "s" (démarrage)
   - Type : Menu audio d'accueil

2. **Glisser "Transfert"** pour l'option 1
   - Extension automatique : "1"
   - Destination : Extension opérateur

3. **Glisser "Redirection"** pour l'option 2
   - Extension automatique : "2"
   - Destination : Contexte technique

4. **Glisser "Menu Précédent"** pour l'option 9
   - Extension automatique : "9"
   - Destination : Contexte parent

### **Résultat Généré**

```ini
[main_menu_fr]
exten => s,1,Playback(menu-principal-fr)
exten => s,n,WaitExten(5)
exten => 1,1,Dial(SIP/operator)
exten => 2,1,Goto(technique,s,1)
exten => 9,1,Goto(language,s,1)
exten => i,1,Playback(option-invalide)
exten => i,n,Goto(s,1)
exten => t,1,Goto(i,1)
```

---

## 🚀 Conseils et Bonnes Pratiques

### **Organisation Visuelle**

- 📐 **Alignement** : Utilisez une grille mentale pour organiser les nœuds
- 🔄 **Flux logique** : Disposez les nœuds selon le parcours utilisateur
- 🎨 **Espacement** : Laissez suffisamment d'espace entre les nœuds
- 📱 **Lisibilité** : Évitez la surcharge visuelle

### **Gestion des Extensions**

- 🔢 **Numérotation** : Utilisez 1-9 pour les options principales
- 📞 **Raccourcis** : 0 pour opérateur, 9 pour retour
- ⚠️ **Spéciaux** : 'i' pour invalide, 't' pour timeout
- 🎯 **Logique** : Maintenez une cohérence dans tout le SVI

### **Performance**

- 💾 **Sauvegarde** : Auto-sauvegarde après chaque modification
- 🔄 **Synchronisation** : Mise à jour en temps réel
- 🧹 **Nettoyage** : Supprimez les nœuds inutilisés
- ✅ **Validation** : Vérifiez la syntaxe générée

---

## 🐛 Résolution de Problèmes

### **Le Drag ne Fonctionne Pas**

1. Vérifiez que JavaScript est activé
2. Assurez-vous d'utiliser un navigateur moderne
3. Rechargez la page (Ctrl+F5)
4. Vérifiez la console pour les erreurs

### **Les Nœuds ne s'Affichent Pas**

1. Vérifiez l'onglet de contexte actif
2. Contrôlez la configuration JSON
3. Vérifiez les permissions des fichiers
4. Consultez les logs du serveur

### **La Position ne se Sauvegarde Pas**

1. Vérifiez les permissions d'écriture
2. Contrôlez la connexion réseau
3. Vérifiez l'API de sauvegarde
4. Rechargez la configuration

---

## 📊 État des Améliorations

### ✅ **Fonctionnalités Implémentées**

- [x] Drag & drop complet
- [x] Feedback visuel en temps réel
- [x] Création automatique de nœuds
- [x] Repositionnement par glissement
- [x] Boutons d'édition et suppression
- [x] Contraintes de position
- [x] Sauvegarde automatique
- [x] Génération d'extensions uniques
- [x] Styles CSS avec animations
- [x] Intégration avec extensions.conf

### 🚧 **Améliorations Futures Possibles**

- [ ] Connexions visuelles entre nœuds
- [ ] Zoom et pan sur le diagramme
- [ ] Undo/Redo des actions
- [ ] Templates de flux pré-configurés
- [ ] Export/Import de configurations
- [ ] Mode collaboration multi-utilisateur

---

**🎉 Le système de drag & drop est maintenant pleinement fonctionnel !**

*Pour toute question ou problème, consultez la documentation technique ou les logs de l'application.*
