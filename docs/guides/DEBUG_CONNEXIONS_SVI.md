# Guide de Débogage - Connexions SVI

## 🔍 Problème : Impossible de créer des connexions entre les nœuds

### ✅ Étapes de Test Systématique

#### 1. Vérifier l'interface Web
- Ouvrir : http://localhost:53537
- Naviguer vers l'éditeur SVI
- Vérifier la console navigateur (F12) pour les erreurs

#### 2. Test Pas-à-Pas des Connexions

**Procédure de test :**
1. Ajouter un nœud "Menu" en glissant depuis la palette
2. Cliquer sur le point vert en bas du nœud "Début"
3. **Observer :** Les autres nœuds doivent s'illuminer en vert avec animation
4. **Vérifier console :** Message "🎯 Mode connexion activé"
5. Cliquer sur le nœud "Menu" illuminé
6. **Résultat attendu :** Connexion créée avec message de succès

#### 3. Signaux Visuels à Observer

**Mode Connexion Actif :**
- ✅ Curseur devient une croix (`crosshair`)
- ✅ Nœuds cibles illuminés en vert avec animation pulse
- ✅ Message "Mode connexion: cliquez sur un nœud de destination"

**Connexion Réussie :**
- ✅ Ligne bleue apparaît entre les nœuds
- ✅ Message "Connexion créée: [source] → [destination]"
- ✅ Retour au mode normal

### 🔧 Points de Vérification Technique

#### Console du Navigateur
Logs attendus lors d'une connexion :
```
🔗 Clic sur sortie: {nodeId: "node_1", nodeLabel: "Début", port: "output"}
🎯 Entrée en mode connexion: {from: "Début", port: "output"}
🎯 Mode connexion activé, nœuds surlignés: 1
🎯 Création de connexion vers: Menu
✨ Création de connexion: {from: "node_1 (Début)", to: "node_2 (Menu)", fromPort: "output", toPort: "input"}
🎉 Connexion créée avec succès: [object Object]
🚪 Sortie du mode connexion
```

#### Vérifications CSS
Classes appliquées en mode connexion :
- `.svi-node.highlighted` : Animation pulse verte
- `.svi-node.connection-target` : Style de hover bleu
- `body { cursor: crosshair }` : Curseur en mode connexion

### 🐛 Problèmes Courants et Solutions

#### Problème 1 : Clic ne déclenche pas le mode connexion
**Symptôme :** Aucune réaction au clic sur point vert
**Vérification :**
- Console : Rechercher "🔗 Clic sur sortie"
- Si absent : Problème d'event handler

**Solution :**
```typescript
// Vérifier que (click) est bien défini dans le template
<div class="connection-point output" 
     (click)="onOutputClick(node, 'output', $event)">
```

#### Problème 2 : Nœuds ne s'illuminent pas
**Symptôme :** Mode connexion actif mais pas de surbrillance
**Vérification :**
- Console : "🎯 Mode connexion activé, nœuds surlignés: X"
- Inspect : Classe `.highlighted` appliquée ?

**Solution :**
```typescript
// Vérifier le binding dans le template
[class.highlighted]="highlightedNodes.includes(node.id)"
```

#### Problème 3 : Clic sur nœud cible ne créé pas la connexion
**Symptôme :** Nœuds illuminés mais clic inefficace
**Vérification :**
- Console : "🎯 Création de connexion vers: [nom]"
- Si absent : Problème dans `onNodeClick`

#### Problème 4 : Conflit avec le drag & drop
**Symptôme :** Connexion se transforme en déplacement
**Solution :** Vérifier l'ordre des handlers d'événements

### 🎯 Tests de Validation

#### Test 1 : Connexion Simple
- Début → Menu (doit fonctionner)
- Vérifier ligne bleue avec flèche

#### Test 2 : Connexion Multiple
- Menu → Action (option 1)
- Menu → Action (option 2)
- Vérifier labels différents

#### Test 3 : Suppression de Connexion
- Cliquer sur point vert déjà connecté
- Connexion doit disparaître

#### Test 4 : Annulation
- Cliquer sur point vert
- Appuyer Échap
- Mode connexion doit se désactiver

### 📞 Support de Débogage

Si les tests échouent, vérifier dans l'ordre :
1. **Console navigateur** : Erreurs JavaScript ?
2. **Network tab** : API backend accessible ?
3. **Elements tab** : CSS classes appliquées ?
4. **Sources tab** : Points d'arrêt dans `onOutputClick` et `onNodeClick`

### 🔄 Redémarrage si Nécessaire

En cas de problème persistant :
```bash
# Terminal 1 : Redémarrer Angular
cd frontend/angular
npm start -- --port 53537

# Terminal 2 : Redémarrer Backend
docker-compose up -d backend
```

### ✅ Checklist de Fonctionnement

- [ ] Application accessible sur http://localhost:53537
- [ ] Points verts visibles sur les nœuds
- [ ] Clic sur point vert change le curseur
- [ ] Nœuds s'illuminent en vert
- [ ] Clic sur nœud illuminé créé la connexion
- [ ] Ligne bleue apparaît entre les nœuds
- [ ] Clic sur point vert connecté supprime la connexion
- [ ] Touche Échap annule le mode connexion
