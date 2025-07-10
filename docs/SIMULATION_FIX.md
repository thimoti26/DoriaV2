# Correction du Simulateur SVI - Navigation entre Étapes

## Problème Identifié

Le simulateur SVI ne permettait pas de naviguer entre les étapes lors de la sélection d'une option dans la simulation.

## Cause du Problème

1. **Actions insuffisantes** : Les actions dans `extensions.conf` étaient toutes des `Noop()` sans logique de navigation
2. **Logique de navigation incomplète** : Le simulateur ne gérait que les actions `Goto()` explicites
3. **Mapping contexte incomplet** : Pas de navigation par défaut basée sur la logique métier du SVI

## Solution Implémentée

### 1. Amélioration de la méthode `executeAction()`

Ajout d'une logique de navigation par défaut basée sur le contexte actuel :

```javascript
// Logique de navigation par défaut basée sur le contexte actuel
if (this.currentContext === 'language') {
    if (step.extension === '1') {
        nextContext = 'main_fr';  // Option 1 -> Menu français
        nextStep = 's';
    } else if (step.extension === '2') {
        nextContext = 'main_en';  // Option 2 -> Menu anglais
        nextStep = 's';
    }
} else if (this.currentContext.startsWith('main_')) {
    if (step.extension === '8') {
        nextContext = 'language'; // Option 8 -> Retour langue
        nextStep = 's';
    }
}
```

### 2. Gestion des cas de fin de simulation

- **Transfer** : Arrête la simulation avec notification
- **Hangup** : Arrête la simulation avec message de fin d'appel
- **Actions internes** : Reste dans le même contexte

### 3. Ajout du debugging

Méthode `debugNavigation()` pour tracer les transitions dans la console :

```javascript
debugNavigation(step) {
    console.log('Simulation Debug:', {
        currentContext: this.currentContext,
        currentStep: this.currentStep,
        selectedOption: step.extension,
        stepDescription: step.description,
        action: step.action
    });
}
```

### 4. Amélioration de l'affichage

- Message informatif si pas d'audio associé
- Meilleure gestion des transitions de contexte

## Navigation Supportée

### Depuis le contexte `language` :
- **Option 1** → `main_fr` (Menu principal français)
- **Option 2** → `main_en` (Menu principal anglais)

### Depuis les contextes `main_fr` / `main_en` :
- **Option 8** → `language` (Retour sélection langue)
- **Autres options** → Reste dans le même contexte (simulation d'actions internes)

## Test de Validation

Un fichier de test automatisé a été créé : `test-svi-navigation.html`

Ce test valide :
1. Navigation langue → français
2. Navigation français → langue  
3. Navigation langue → anglais

## Utilisation

1. Accéder à l'interface SVI Admin : `http://localhost:8080/svi-admin/`
2. Cliquer sur "Simuler le Parcours"
3. Sélectionner une option dans la liste
4. Observer la navigation vers le contexte suivant
5. Vérifier l'historique des actions dans le panneau de droite

## Logs de Debug

Pour voir les détails de navigation, ouvrir la console du navigateur (F12) et observer les messages `Simulation Debug` lors de la sélection d'options.

---

**Statut** : ✅ Correction appliquée et testée
**Date** : 2 juillet 2025
