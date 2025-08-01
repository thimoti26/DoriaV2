# 🔗 Guide Visuel - Points de Connexion SVI

## 📍 **Où Trouver les Points de Connexion**

### ✅ **Points de Sortie Principaux**
- **Position :** En bas de chaque nœud (sauf "Fin")
- **Apparence :** Cercle vert avec icône 🔗
- **Taille :** 20px × 20px
- **Couleur :** Vert (#28a745) avec ombre
- **Au survol :** Devient blanc avec bordure rouge, grossit de 50%

### 🎯 **Points Spécialisés**

#### **Nœuds Menu :**
- Points de sortie supplémentaires à droite
- Un point par option (1, 2, 3...)
- Rectangles verts avec numéro/lettre
- Position : À droite du nœud, espacés verticalement

#### **Nœuds Condition :**
- Point "Vrai" (✓) : En haut à droite 
- Point "Faux" (✗) : En bas à droite
- Rectangles verts avec symboles

## 🎨 **Apparence Visuelle**

```
┌─────────────────┐
│   📋 Menu       │ ← En-tête du nœud
│                 │
│ 2 options       │ ← Contenu
│                 │ [1] ← Points menu (droite)
│                 │ [2]
└─────────┬───────┘
          🔗        ← Point principal (bas)
```

## 🔍 **Test de Visibilité**

### **Vérifications Immédiates :**
1. **Rechargez la page** : http://localhost:53537
2. **Créez un nœud** : Glissez "Menu" depuis la palette
3. **Cherchez le point vert** : En bas du nœud "Début"
4. **Vérifiez l'icône** : Doit afficher 🔗
5. **Testez le survol** : Point doit grossir et changer de couleur

### **Si Toujours Invisible :**

#### **Console Navigateur (F12) :**
Vérifiez ces éléments dans l'inspecteur :
```html
<div class="connection-point output">
  <span class="output-icon">🔗</span>
</div>
```

#### **CSS Appliqué :**
```css
.connection-point.output {
  width: 20px;
  height: 20px;
  background: #28a745;
  border: 3px solid #28a745;
  position: absolute;
  bottom: -10px;
  left: 50%;
}
```

### **Débogage Avancé :**

#### **1. Vérifier Z-Index**
```css
.connection-point { z-index: 10; }
```

#### **2. Vérifier Position**
```css
.connection-points { position: relative; }
.svi-node { position: absolute; }
```

#### **3. Forcer la Visibilité** (temporaire)
Ajoutez dans la console :
```javascript
document.querySelectorAll('.connection-point').forEach(el => {
  el.style.background = 'red !important';
  el.style.border = '3px solid yellow !important';
  el.style.zIndex = '999';
});
```

## 🛠️ **Actions de Diagnostic**

### **Si Aucun Point Visible :**
1. Ouvrir F12 → Elements
2. Rechercher ".connection-point"
3. Si trouvé mais invisible → Problème CSS
4. Si non trouvé → Problème Angular/HTML

### **Si Points Présents Mais Non Cliquables :**
1. Vérifier `pointer-events: auto`
2. Vérifier handlers `(click)="onOutputClick"`
3. Contrôler console pour erreurs JavaScript

## 🎬 **Test Final**

**Séquence de Test Complète :**
1. ✅ Voir le point vert 🔗 en bas du nœud "Début"
2. ✅ Cliquer → Curseur devient croix
3. ✅ Autres nœuds s'illuminent en vert pulsant
4. ✅ Cliquer sur nœud illuminé → Ligne bleue apparaît
5. ✅ Message de succès affiché

**Si l'étape 1 échoue :** Les points ne sont pas visibles → Problème d'affichage CSS
**Si l'étape 2 échoue :** Points visibles mais non fonctionnels → Problème JavaScript
