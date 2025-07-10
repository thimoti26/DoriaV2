/**
 * Simulateur de parcours SVI
 */
class SviSimulator {
    constructor() {
        this.currentContext = 'language';
        this.currentStep = 's';
        this.history = [];
        this.sviConfig = null;
        
        this.initEventListeners();
    }

    static init() {
        if (!window.sviSimulator) {
            window.sviSimulator = new SviSimulator();
        }
        return window.sviSimulator;
    }

    initEventListeners() {
        document.getElementById('simulateBtn').addEventListener('click', () => this.startSimulation());
        document.getElementById('resetSimulation').addEventListener('click', () => this.resetSimulation());
        document.getElementById('closeSimulation').addEventListener('click', () => this.closeSimulation());
    }

    startSimulation() {
        // Récupérer la configuration actuelle
        if (window.sviEditor && window.sviEditor.sviConfig) {
            this.sviConfig = window.sviEditor.sviConfig;
            this.resetSimulation();
            document.getElementById('simulateModal').classList.add('show');
        } else {
            window.sviEditor.showNotification('Aucune configuration SVI chargée', 'warning');
        }
    }

    resetSimulation() {
        this.currentContext = 'language';
        this.currentStep = 's';
        this.history = [];
        this.updateSimulationDisplay();
    }

    closeSimulation() {
        document.getElementById('simulateModal').classList.remove('show');
        this.stopAllAudio();
    }

    updateSimulationDisplay() {
        this.updateCurrentStep();
        this.updateAvailableOptions();
        this.updateHistory();
    }

    updateCurrentStep() {
        const stepNameElement = document.getElementById('currentStepName');
        const stepAudioElement = document.getElementById('currentStepAudio');
        
        // Déterminer le nom de l'étape
        let stepName = '';
        switch (this.currentContext) {
            case 'language':
                stepName = 'Sélection de langue';
                break;
            case 'main_fr':
                stepName = 'Menu principal (Français)';
                break;
            case 'main_en':
                stepName = 'Menu principal (English)';
                break;
            default:
                stepName = this.currentContext;
        }

        stepNameElement.textContent = stepName;

        // Trouver l'audio associé à l'étape d'entrée
        stepAudioElement.innerHTML = '';
        const entryStep = this.findEntryStep();
        if (entryStep && entryStep.type === 'menu') {
            const audioPath = this.extractAudioPath(entryStep.action);
            if (audioPath) {
                const audioElement = document.createElement('audio');
                audioElement.controls = true;
                audioElement.src = `uploads/${audioPath}.wav`;
                audioElement.style.width = '100%';
                stepAudioElement.appendChild(audioElement);
            }
        } else {
            // Afficher un message informatif si pas d'audio
            const infoDiv = document.createElement('div');
            infoDiv.className = 'text-muted';
            infoDiv.textContent = 'Pas d\'audio associé à cette étape';
            stepAudioElement.appendChild(infoDiv);
        }
    }

    findEntryStep() {
        const contextConfig = this.sviConfig[this.currentContext];
        if (!contextConfig) return null;

        // Chercher l'étape 's' (start) ou la première étape
        return contextConfig['s'] || contextConfig[Object.keys(contextConfig)[0]] || null;
    }

    updateAvailableOptions() {
        const optionsContainer = document.getElementById('simulationOptions');
        optionsContainer.innerHTML = '';

        const contextConfig = this.sviConfig[this.currentContext];
        if (!contextConfig) return;

        // Créer les boutons pour toutes les options disponibles
        Object.values(contextConfig).forEach(step => {
            if (step.extension !== 's') { // Ignorer l'étape de démarrage
                const button = document.createElement('button');
                button.className = 'simulation-option';
                button.textContent = `${step.extension} - ${step.description}`;
                button.addEventListener('click', () => this.selectOption(step));
                optionsContainer.appendChild(button);
            }
        });
    }

    debugNavigation(step) {
        console.log('Simulation Debug:', {
            currentContext: this.currentContext,
            currentStep: this.currentStep,
            selectedOption: step.extension,
            stepDescription: step.description,
            action: step.action
        });
    }

    selectOption(step) {
        // Debug de la navigation
        this.debugNavigation(step);
        
        // Ajouter à l'historique
        this.history.push({
            context: this.currentContext,
            step: step.extension,
            description: step.description,
            timestamp: new Date().toLocaleTimeString()
        });

        // Exécuter l'action
        this.executeAction(step);
    }

    executeAction(step) {
        const action = step.action;

        // Logique de navigation basée sur le contexte et l'extension
        let nextContext = null;
        let nextStep = null;
        let shouldContinue = true;

        if (step.type === 'redirect') {
            // Extraire le contexte de destination depuis l'action Goto
            const match = action.match(/Goto\(([^,]+)/);
            if (match) {
                nextContext = this.mapContextName(match[1]);
                nextStep = 's';
            }
        } else if (step.type === 'transfer') {
            // Simulation de transfert - fin de simulation
            this.history.push({
                context: this.currentContext,
                step: 'transfer',
                description: `Appel transféré vers ${step.description}`,
                timestamp: new Date().toLocaleTimeString()
            });
            
            window.sviEditor.showNotification('Simulation: ' + step.description, 'info');
            shouldContinue = false;
        } else if (step.type === 'hangup') {
            // Simulation de raccrochage - fin de simulation
            this.history.push({
                context: this.currentContext,
                step: 'hangup',
                description: 'Fin d\'appel',
                timestamp: new Date().toLocaleTimeString()
            });
            
            window.sviEditor.showNotification('Simulation: Fin d\'appel', 'info');
            shouldContinue = false;
        } else {
            // Logique de navigation par défaut basée sur le contexte actuel
            if (this.currentContext === 'language') {
                if (step.extension === '1') {
                    nextContext = 'main_fr';
                    nextStep = 's';
                } else if (step.extension === '2') {
                    nextContext = 'main_en';
                    nextStep = 's';
                }
            } else if (this.currentContext.startsWith('main_')) {
                if (step.extension === '8') {
                    nextContext = 'language';
                    nextStep = 's';
                }
                // Pour les autres options, on reste dans le même contexte
                // (simulation d'actions internes)
            }
        }

        // Appliquer la navigation si définie
        if (nextContext && nextStep) {
            this.currentContext = nextContext;
            this.currentStep = nextStep;
        }

        // Continuer la simulation seulement si nécessaire
        if (shouldContinue) {
            this.updateSimulationDisplay();
        }
    }

    mapContextName(asteriskContext) {
        const mapping = {
            'ivr-language': 'language',
            'ivr-main': 'main_fr',
            'ivr-main-en': 'main_en'
        };
        return mapping[asteriskContext] || asteriskContext;
    }

    updateHistory() {
        const historyContainer = document.getElementById('simulationHistory');
        historyContainer.innerHTML = '';

        this.history.forEach(entry => {
            const div = document.createElement('div');
            div.className = 'log-entry';
            div.innerHTML = `
                <strong>${entry.timestamp}</strong> - 
                ${entry.context} → ${entry.step}: ${entry.description}
            `;
            historyContainer.appendChild(div);
        });

        // Scroll vers le bas
        historyContainer.scrollTop = historyContainer.scrollHeight;
    }

    extractAudioPath(action) {
        const match = action.match(/Background\((.+)\)/);
        return match ? match[1] : null;
    }

    stopAllAudio() {
        // Arrêter tous les lecteurs audio dans la modal
        const audioElements = document.querySelectorAll('#simulateModal audio');
        audioElements.forEach(audio => {
            audio.pause();
            audio.currentTime = 0;
        });
    }
}
