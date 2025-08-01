# 🔧 Diagnostic - Problème de Connexions SVI

## ❌ Problème Rapporté
**"Je n'arrive pas à faire des liens entre les éléments du SVI"**

## 🔍 Analyse du Code

### ✅ Éléments Présents dans le Code
1. **Interface SviConnection** - Définie correctement ✅
2. **Points de connexion HTML** - Présents dans le template ✅
3. **Méthodes de gestion** - `startConnection()`, `endConnection()`, `createConnection()` ✅
4. **Styles CSS** - Points de connexion stylés ✅
5. **Variables d'état** - `isConnecting`, `connectionStart`, `tempConnection` ✅

### 🎯 Points de Connexion Configurés
- **Points d'entrée** : Haut des nœuds (sauf nœud 'start')
- **Points de sortie** : Bas des nœuds (sauf nœud 'end')
- **Sorties multiples** : Pour menus et conditions
- **Ligne temporaire** : Affichage en pointillés pendant connexion

## 🔍 Tests de Diagnostic

### Test 1 : Vérifier la Visibilité des Points
```bash
# Ouvrir l'application Angular
# URL: http://localhost:53536
# 1. Créer 2 nœuds (Start + Menu par exemple)
# 2. Vérifier si les points de connexion sont visibles
# 3. Observer la couleur et taille des points
```

### Test 2 : Vérifier les Events JavaScript
```javascript
// Dans la console du navigateur:
// Vérifier si les events mousedown/mouseup sont interceptés
document.addEventListener('mousedown', (e) => {
  if (e.target.classList.contains('connection-point')) {
    console.log('Point de connexion cliqué:', e.target);
  }
});
```

### Test 3 : Vérifier l'État des Connexions
```javascript
// Dans la console, vérifier l'état du composant:
// (Si vous avez accès à l'instance du composant)
console.log('isConnecting:', component.isConnecting);
console.log('connectionStart:', component.connectionStart);
console.log('flow.connections:', component.flow.connections);
```

## 🛠️ Solutions Potentielles

### Solution 1 : Problème de z-index
Les points de connexion pourraient être cachés derrière d'autres éléments.

**CSS à vérifier:**
```css
.connection-point {
  z-index: 3; /* Déjà présent dans le code */
  pointer-events: auto; /* À ajouter si nécessaire */
}
```

### Solution 2 : Conflits d'Events
Les events de drag des nœuds pourraient interférer.

**Vérification dans startConnection():**
```typescript
startConnection(node: SviNode, port: string, event: MouseEvent) {
  event.stopPropagation(); // ✅ Présent
  event.preventDefault();  // ✅ Présent
  // ...
}
```

### Solution 3 : Problème de Positionnement
Les coordonnées des points pourraient être incorrectes.

**Vérification dans getNodeRect():**
```typescript
// Cette méthode doit retourner les bonnes coordonnées
getNodeRect(node: SviNode) {
  // Implémenter si manquante
}
```

## 🔧 Actions Correctives Recommandées

### 1. Tester Visuellement
- [ ] Ouvrir http://localhost:53536
- [ ] Créer 2 nœuds différents
- [ ] Vérifier si points de connexion sont visibles
- [ ] Tester le clic sur les points

### 2. Ajouter du Debug
```typescript
startConnection(node: SviNode, port: string, event: MouseEvent) {
  console.log('startConnection appelé:', { node: node.id, port, event });
  event.stopPropagation();
  event.preventDefault();
  // ... reste du code
}
```

### 3. Vérifier les Styles
```css
.connection-point {
  width: 12px;
  height: 12px;
  border: 2px solid #007bff;
  border-radius: 50%;
  background: white;
  position: absolute;
  cursor: crosshair;
  z-index: 10; /* Augmenter si nécessaire */
  pointer-events: auto;
}

.connection-point:hover {
  background: #007bff;
  transform: scale(1.5); /* Rendre plus visible */
  border-color: #ff0000; /* Rouge pour debug */
}
```

## 🎯 Prochaines Étapes

1. **Test Immédiat** : Ouvrir l'application et tester visuellement
2. **Debug Console** : Ajouter des console.log pour tracer les events
3. **Inspection CSS** : Vérifier les styles appliqués aux points
4. **Test Fonctionnel** : Essayer de créer une connexion simple

---

> 💡 **Note** : Le code semble correctement implémenté. Le problème pourrait être visuel (points non visibles) ou d'interaction (events bloqués).
