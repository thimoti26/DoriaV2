/**
 * SVI Admin - Interface Simplifiée
 * Version unifiée et simplifiée pour éviter les duplications
 */

class SviAdmin {
    constructor() {
        this.currentContext = 'language';
        this.selectedStep = null;
        this.selectedStepType = null;
        this.sviConfig = {};
        this.audioFiles = [];
        this.availableTests = {};
        this.runningTests = new Set();
        
        this.init();
    }

    init() {
        console.log('Initialisation SVI Admin...');
        
        // Initialiser les événements
        this.initEventListeners();
        
        // Initialiser le drag & drop
        this.initDragDrop();
        
        // Charger la configuration
        this.loadConfig();
        
        // Charger les fichiers audio
        this.loadAudioFiles();
        
        // Charger les tests disponibles
        this.loadAvailableTests();
        
        // Message de bienvenue
        this.showMessage('Interface SVI Admin chargée avec succès !', 'success');
    }

    initEventListeners() {
        // Boutons principaux
        document.getElementById('saveBtn').addEventListener('click', () => this.saveConfig());
        document.getElementById('reloadBtn').addEventListener('click', () => this.loadConfig());
        document.getElementById('addStepBtn').addEventListener('click', () => this.showAddStepModal());
        document.getElementById('confirmAddStep').addEventListener('click', () => this.addSelectedStep());

        // Onglets de contexte - utiliser la délégation d'événements pour plus de robustesse
        document.addEventListener('click', (e) => {
            if (e.target.classList.contains('tab-btn') || e.target.closest('.tab-btn')) {
                const btn = e.target.classList.contains('tab-btn') ? e.target : e.target.closest('.tab-btn');
                const context = btn.dataset.context;
                console.log('Clic onglet:', context);
                this.switchContext(context);
            }
        });

        // Tests section events - utiliser la délégation d'événements
        document.addEventListener('click', (e) => {
            if (e.target.id === 'refreshTestsBtn') {
                this.loadAvailableTests();
            } else if (e.target.id === 'clearOutputBtn') {
                this.clearTestOutput();
            } else if (e.target.id === 'stopTestBtn') {
                this.stopCurrentTest();
            } else if (e.target.classList.contains('run-test-btn')) {
                const testName = e.target.dataset.test;
                console.log('Clic test:', testName);
                this.runTest(testName);
            }
        });

        // Modale d'ajout d'étape
        document.querySelectorAll('.step-type').forEach(type => {
            type.addEventListener('click', (e) => {
                // Désélectionner tous
                document.querySelectorAll('.step-type').forEach(t => t.classList.remove('selected'));
                
                // Sélectionner le type cliqué
                e.currentTarget.classList.add('selected');
                this.selectedStepType = e.currentTarget.dataset.type;
            });
        });

        // Zone de drop
        const dropZone = document.getElementById('dropZone');
        dropZone.addEventListener('click', () => this.showAddStepModal());
    }

    initDragDrop() {
        // Drag depuis la toolbox
        document.querySelectorAll('.tool-item').forEach(tool => {
            tool.addEventListener('dragstart', (e) => {
                e.dataTransfer.setData('text/plain', JSON.stringify({
                    type: tool.dataset.type,
                    source: 'toolbox'
                }));
            });
        });

        // Drop sur la zone
        const dropZone = document.getElementById('dropZone');
        const stepsList = document.getElementById('stepsList');

        [dropZone, stepsList].forEach(zone => {
            zone.addEventListener('dragover', (e) => {
                e.preventDefault();
                zone.classList.add('drag-over');
            });

            zone.addEventListener('dragleave', () => {
                zone.classList.remove('drag-over');
            });

            zone.addEventListener('drop', (e) => {
                e.preventDefault();
                zone.classList.remove('drag-over');
                
                try {
                    const data = JSON.parse(e.dataTransfer.getData('text/plain'));
                    if (data.source === 'toolbox' && data.type) {
                        this.addStep(data.type);
                    }
                } catch (error) {
                    console.error('Erreur lors du drop:', error);
                    this.showMessage('Erreur lors de l\'ajout de l\'étape', 'error');
                }
            });
        });

        // Sortable pour réorganiser les étapes
        new Sortable(stepsList, {
            animation: 150,
            ghostClass: 'sortable-ghost',
            onEnd: (evt) => {
                this.reorderSteps(evt.oldIndex, evt.newIndex);
            }
        });
    }

    // ====== TESTS MANAGEMENT ======

    async loadAvailableTests() {
        console.log('Chargement des tests disponibles...');
        try {
            const response = await fetch('api/run-tests.php?action=list');
            const data = await response.json();
            
            if (data.success) {
                this.availableTests = data.tests;
                this.renderTestsList();
                this.showMessage('Tests chargés avec succès', 'success');
            } else {
                this.showMessage('Erreur lors du chargement des tests: ' + (data.error || 'Erreur inconnue'), 'error');
            }
        } catch (error) {
            console.error('Erreur lors du chargement des tests:', error);
            this.showMessage('Erreur de connexion pour charger les tests', 'error');
        }
    }

    renderTestsList() {
        const categories = {
            debug: document.getElementById('debugTests'),
            network: document.getElementById('networkTests'),
            svi: document.getElementById('sviTests'),
            system: document.getElementById('systemTests'),
            general: document.getElementById('generalTests')
        };

        // Vider toutes les catégories
        Object.values(categories).forEach(container => {
            if (container) container.innerHTML = '';
        });

        // Trier les tests par catégorie
        Object.entries(this.availableTests).forEach(([testName, testInfo]) => {
            const testItem = this.createTestItem(testName, testInfo);
            
            // Déterminer la catégorie basée sur le nom du test
            let category = 'general';
            if (testName.includes('debug')) category = 'debug';
            else if (testName.includes('network') || testName.includes('sip')) category = 'network';
            else if (testName.includes('svi') || testName.includes('audio')) category = 'svi';
            else if (testName.includes('system') || testName.includes('stack') || testName.includes('volume')) category = 'system';
            
            const container = categories[category];
            if (container) {
                container.appendChild(testItem);
            }
        });
    }

    createTestItem(testName, testInfo) {
        const item = document.createElement('div');
        item.className = 'test-item';
        item.setAttribute('data-test', testName);
        
        item.innerHTML = `
            <div class="test-info">
                <div class="test-name">${testInfo.display_name || testName}</div>
                <div class="test-description">${testInfo.description || 'Test système'}</div>
            </div>
            <div class="test-actions">
                <span class="test-status idle">idle</span>
                <button class="btn btn-sm btn-primary run-test-btn" data-test="${testName}">
                    <i class="fas fa-play"></i> Exécuter
                </button>
            </div>
        `;

        // Les événements sont gérés par délégation dans initEventListeners
        return item;
    }

    async runTest(testName) {
        if (this.runningTests.has(testName)) {
            this.showMessage('Ce test est déjà en cours d\'exécution', 'warning');
            return;
        }

        console.log('Exécution du test:', testName);
        this.runningTests.add(testName);
        this.updateTestStatus(testName, 'running');
        this.showTestOutput(testName);
        
        try {
            const response = await fetch('api/run-tests.php', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    action: 'run',
                    test: testName
                })
            });

            const data = await response.json();
            
            if (data.success) {
                this.updateTestStatus(testName, 'success');
                this.appendTestOutput(data.output || 'Test terminé avec succès');
                this.showMessage(`Test ${testName} terminé avec succès`, 'success');
            } else {
                this.updateTestStatus(testName, 'error');
                this.appendTestOutput(data.error || 'Erreur lors de l\'exécution du test');
                this.showMessage(`Test ${testName} a échoué: ${data.error}`, 'error');
            }
        } catch (error) {
            console.error('Erreur lors de l\'exécution du test:', error);
            this.updateTestStatus(testName, 'error');
            this.appendTestOutput('Erreur de connexion lors de l\'exécution du test');
            this.showMessage('Erreur de connexion', 'error');
        } finally {
            this.runningTests.delete(testName);
            this.hideStopButton();
        }
    }

    updateTestStatus(testName, status) {
        const testItem = document.querySelector(`[data-test="${testName}"]`);
        if (testItem) {
            const statusElement = testItem.querySelector('.test-status');
            const runBtn = testItem.querySelector('.run-test-btn');
            
            statusElement.className = `test-status ${status}`;
            statusElement.textContent = status;
            
            testItem.className = `test-item ${status}`;
            
            if (status === 'running') {
                runBtn.innerHTML = '<div class="test-spinner"></div> En cours...';
                runBtn.disabled = true;
                this.showStopButton();
            } else {
                runBtn.innerHTML = '<i class="fas fa-play"></i> Exécuter';
                runBtn.disabled = false;
            }
        }
    }

    showTestOutput(testName) {
        // Afficher le panneau de sortie des tests
        const outputPanel = document.getElementById('testOutputPanel');
        const propertiesPanel = document.getElementById('propertiesPanel');
        
        if (outputPanel && propertiesPanel) {
            propertiesPanel.style.display = 'none';
            outputPanel.style.display = 'block';
        }
        
        // Mettre à jour le nom du test en cours
        const currentTestName = document.getElementById('currentTestName');
        if (currentTestName) {
            currentTestName.textContent = `Test en cours: ${testName}`;
        }
        
        // Vider la sortie précédente
        this.clearTestOutput();
        this.appendTestOutput(`=== Démarrage du test: ${testName} ===`);
    }

    appendTestOutput(text) {
        const output = document.getElementById('testOutput');
        if (output) {
            const noOutput = output.querySelector('.no-output');
            if (noOutput) {
                noOutput.remove();
            }
            
            const line = document.createElement('div');
            line.className = 'test-output-line';
            line.textContent = text;
            
            // Coloriser selon le contenu
            if (text.includes('ERROR') || text.includes('FAILED')) {
                line.classList.add('error');
            } else if (text.includes('SUCCESS') || text.includes('OK')) {
                line.classList.add('success');
            } else if (text.includes('WARNING')) {
                line.classList.add('warning');
            } else if (text.includes('INFO')) {
                line.classList.add('info');
            }
            
            output.appendChild(line);
            output.scrollTop = output.scrollHeight;
        }
    }

    clearTestOutput() {
        const output = document.getElementById('testOutput');
        if (output) {
            output.innerHTML = '<div class="no-output"><p>Sélectionnez et exécutez un test pour voir les résultats</p></div>';
        }
    }

    showStopButton() {
        const stopBtn = document.getElementById('stopTestBtn');
        if (stopBtn) {
            stopBtn.style.display = 'inline-block';
        }
    }

    hideStopButton() {
        const stopBtn = document.getElementById('stopTestBtn');
        if (stopBtn) {
            stopBtn.style.display = 'none';
        }
    }

    stopCurrentTest() {
        // Pour l'instant, juste masquer le bouton et réinitialiser les statuts
        this.runningTests.clear();
        this.hideStopButton();
        
        // Réinitialiser tous les tests en cours
        document.querySelectorAll('.test-item.running').forEach(item => {
            const testName = item.getAttribute('data-test');
            this.updateTestStatus(testName, 'idle');
        });
        
        this.appendTestOutput('=== Test arrêté par l\'utilisateur ===');
        this.showMessage('Test arrêté', 'warning');
    }

    switchContext(context) {
        console.log('Switch context to:', context);
        this.currentContext = context;
        
        // Mettre à jour les onglets
        document.querySelectorAll('.tab-btn').forEach(btn => {
            btn.classList.toggle('active', btn.dataset.context === context);
        });
        
        // Afficher/masquer les conteneurs appropriés
        const sviContainer = document.getElementById('sviContainer');
        const testsContainer = document.getElementById('testsContainer');
        const propertiesPanel = document.getElementById('propertiesPanel');
        const testOutputPanel = document.getElementById('testOutputPanel');
        
        console.log('Elements found:', {
            sviContainer: !!sviContainer,
            testsContainer: !!testsContainer,
            propertiesPanel: !!propertiesPanel,
            testOutputPanel: !!testOutputPanel
        });
        
        if (context === 'tests') {
            if (sviContainer) sviContainer.style.display = 'none';
            if (testsContainer) {
                testsContainer.style.display = 'block';
                // Charger les tests si ce n'est pas déjà fait
                if (Object.keys(this.availableTests).length === 0) {
                    this.loadAvailableTests();
                }
            }
            if (propertiesPanel) propertiesPanel.style.display = 'none';
            if (testOutputPanel) testOutputPanel.style.display = 'block';
        } else {
            if (sviContainer) sviContainer.style.display = 'block';
            if (testsContainer) testsContainer.style.display = 'none';
            if (propertiesPanel) propertiesPanel.style.display = 'block';
            if (testOutputPanel) testOutputPanel.style.display = 'none';
            
            // Recharger les étapes pour les autres contextes
            this.renderSteps();
        }
        
        // Vider le panneau de propriétés
        this.clearProperties();
    }

    loadConfig() {
        console.log('Chargement de la configuration...');
        this.showMessage('Chargement de la configuration...', 'info');
        
        fetch('api/get-svi-config.php')
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    this.sviConfig = data.data || {};
                    this.renderSteps();
                    this.showMessage('Configuration chargée avec succès', 'success');
                } else {
                    this.showMessage('Erreur lors du chargement: ' + (data.error || 'Erreur inconnue'), 'error');
                }
            })
            .catch(error => {
                console.error('Erreur:', error);
                this.showMessage('Erreur de connexion', 'error');
                
                // Configuration par défaut
                this.sviConfig = {
                    language: {},
                    main_fr: {},
                    main_en: {}
                };
                this.renderSteps();
            });
    }

    saveConfig() {
        console.log('Sauvegarde de la configuration...');
        this.showMessage('Sauvegarde en cours...', 'info');
        
        fetch('api/save-svi-config.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(this.sviConfig)
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                this.showMessage('Configuration sauvegardée avec succès', 'success');
            } else {
                this.showMessage('Erreur lors de la sauvegarde: ' + (data.error || 'Erreur inconnue'), 'error');
            }
        })
        .catch(error => {
            console.error('Erreur:', error);
            this.showMessage('Erreur de connexion lors de la sauvegarde', 'error');
        });
    }

    loadAudioFiles() {
        fetch('api/list-audio.php')
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    this.audioFiles = data.files || [];
                }
            })
            .catch(error => {
                console.error('Erreur lors du chargement des fichiers audio:', error);
            });
    }

    loadAvailableTests() {
        fetch('api/run-tests.php?action=list')
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    this.availableTests = data.tests || {};
                    this.renderTestsList();
                    this.showMessage('Tests chargés avec succès', 'success');
                } else {
                    this.showMessage('Erreur lors du chargement des tests: ' + (data.error || 'Erreur inconnue'), 'error');
                }
            })
            .catch(error => {
                console.error('Erreur lors du chargement des tests:', error);
                this.showMessage('Erreur de connexion pour charger les tests', 'error');
            });
    }

    renderSteps() {
        const stepsList = document.getElementById('stepsList');
        const dropZone = document.getElementById('dropZone');
        
        stepsList.innerHTML = '';
        
        const contextSteps = this.sviConfig[this.currentContext] || {};
        const hasSteps = Object.keys(contextSteps).length > 0;
        
        // Afficher/cacher la zone de drop
        dropZone.style.display = hasSteps ? 'none' : 'block';
        
        // Créer les éléments d'étapes
        Object.entries(contextSteps).forEach(([extension, stepData]) => {
            const stepElement = this.createStepElement(extension, stepData);
            stepsList.appendChild(stepElement);
        });
    }

    createStepElement(extension, stepData) {
        const stepDiv = document.createElement('div');
        stepDiv.className = 'step-item';
        stepDiv.dataset.extension = extension;
        
        const icon = this.getStepIcon(stepData.type || 'other');
        const title = stepData.description || extension;
        
        stepDiv.innerHTML = `
            <div class="step-header">
                <div class="step-icon">
                    <i class="fas ${icon}"></i>
                </div>
                <div class="step-info">
                    <h4>${title}</h4>
                    <p>Extension: ${extension}</p>
                </div>
                <div class="step-actions">
                    <button class="btn-step-edit" title="Modifier">
                        <i class="fas fa-edit"></i>
                    </button>
                    <button class="btn-step-delete" title="Supprimer">
                        <i class="fas fa-trash"></i>
                    </button>
                </div>
            </div>
            <div class="step-content">
                <p><strong>Action:</strong> ${stepData.action || 'Non définie'}</p>
            </div>
        `;
        
        // Événements
        stepDiv.addEventListener('click', () => this.selectStep(extension));
        
        stepDiv.querySelector('.btn-step-edit').addEventListener('click', (e) => {
            e.stopPropagation();
            this.selectStep(extension);
        });
        
        stepDiv.querySelector('.btn-step-delete').addEventListener('click', (e) => {
            e.stopPropagation();
            this.deleteStep(extension);
        });
        
        return stepDiv;
    }

    getStepIcon(type) {
        const icons = {
            'playback': 'fa-play',
            'menu': 'fa-list',
            'say': 'fa-comment',
            'transfer': 'fa-phone-forwarded',
            'hangup': 'fa-phone-slash',
            'goto': 'fa-arrow-right',
            'other': 'fa-cog'
        };
        return icons[type] || 'fa-cog';
    }

    selectStep(extension) {
        // Désélectionner toutes les étapes
        document.querySelectorAll('.step-item').forEach(item => {
            item.classList.remove('selected');
        });
        
        // Sélectionner l'étape
        const stepElement = document.querySelector(`[data-extension="${extension}"]`);
        if (stepElement) {
            stepElement.classList.add('selected');
            this.selectedStep = extension;
            this.showStepProperties(extension);
        }
    }

    showStepProperties(extension) {
        const stepData = this.sviConfig[this.currentContext][extension];
        if (!stepData) return;
        
        const propertiesContent = document.getElementById('propertiesContent');
        
        propertiesContent.innerHTML = `
            <div class="properties-form">
                <h4>Propriétés de l'étape</h4>
                
                <div class="form-group">
                    <label>Extension</label>
                    <input type="text" id="prop-extension" value="${extension}" readonly>
                </div>
                
                <div class="form-group">
                    <label>Description</label>
                    <input type="text" id="prop-description" value="${stepData.description || ''}" placeholder="Description de l'étape">
                </div>
                
                <div class="form-group">
                    <label>Action</label>
                    <textarea id="prop-action" placeholder="Action Asterisk">${stepData.action || ''}</textarea>
                </div>
                
                <div class="form-group">
                    <label>Type</label>
                    <select id="prop-type">
                        <option value="other" ${stepData.type === 'other' ? 'selected' : ''}>Autre</option>
                        <option value="playback" ${stepData.type === 'playback' ? 'selected' : ''}>Lecture</option>
                        <option value="menu" ${stepData.type === 'menu' ? 'selected' : ''}>Menu</option>
                        <option value="say" ${stepData.type === 'say' ? 'selected' : ''}>Dire</option>
                        <option value="transfer" ${stepData.type === 'transfer' ? 'selected' : ''}>Transfert</option>
                        <option value="hangup" ${stepData.type === 'hangup' ? 'selected' : ''}>Raccrocher</option>
                    </select>
                </div>
                
                <div class="form-actions">
                    <button id="prop-save" class="btn btn-primary">Enregistrer</button>
                    <button id="prop-cancel" class="btn btn-secondary">Annuler</button>
                </div>
            </div>
        `;
        
        // Événements
        document.getElementById('prop-save').addEventListener('click', () => this.saveStepProperties(extension));
        document.getElementById('prop-cancel').addEventListener('click', () => this.clearProperties());
    }

    saveStepProperties(extension) {
        const description = document.getElementById('prop-description').value;
        const action = document.getElementById('prop-action').value;
        const type = document.getElementById('prop-type').value;
        
        // Mettre à jour la configuration
        this.sviConfig[this.currentContext][extension] = {
            ...this.sviConfig[this.currentContext][extension],
            description: description,
            action: action,
            type: type
        };
        
        // Rafraîchir l'affichage
        this.renderSteps();
        this.clearProperties();
        
        this.showMessage('Propriétés mises à jour', 'success');
    }

    clearProperties() {
        const propertiesContent = document.getElementById('propertiesContent');
        propertiesContent.innerHTML = `
            <div class="no-selection">
                <p>Sélectionnez une étape pour modifier ses propriétés</p>
            </div>
        `;
        this.selectedStep = null;
    }

    showAddStepModal() {
        const modal = document.getElementById('addStepModal');
        modal.style.display = 'block';
        
        // Réinitialiser la sélection
        document.querySelectorAll('.step-type').forEach(t => t.classList.remove('selected'));
        this.selectedStepType = null;
    }

    addSelectedStep() {
        if (!this.selectedStepType) {
            this.showMessage('Veuillez sélectionner un type d\'étape', 'error');
            return;
        }
        
        this.addStep(this.selectedStepType);
        this.closeModal('addStepModal');
    }

    addStep(type) {
        // Trouver une extension disponible
        const existingExtensions = Object.keys(this.sviConfig[this.currentContext] || {});
        let extension = '1';
        
        for (let i = 1; i <= 9; i++) {
            if (!existingExtensions.includes(i.toString())) {
                extension = i.toString();
                break;
            }
        }
        
        // Créer l'étape
        if (!this.sviConfig[this.currentContext]) {
            this.sviConfig[this.currentContext] = {};
        }
        
        this.sviConfig[this.currentContext][extension] = {
            extension: extension,
            type: type,
            description: this.getStepLabel(type),
            action: this.getDefaultAction(type)
        };
        
        // Rafraîchir l'affichage
        this.renderSteps();
        
        this.showMessage(`Étape "${this.getStepLabel(type)}" ajoutée`, 'success');
    }

    getStepLabel(type) {
        const labels = {
            'playback': 'Lecture Audio',
            'menu': 'Menu',
            'say': 'Dire',
            'transfer': 'Transfert',
            'hangup': 'Raccrocher'
        };
        return labels[type] || 'Étape';
    }

    getDefaultAction(type) {
        const actions = {
            'playback': 'Playback(hello)',
            'menu': 'Background(menu)',
            'say': 'SayNumber(123)',
            'transfer': 'Dial(SIP/100)',
            'hangup': 'Hangup()'
        };
        return actions[type] || 'Noop()';
    }

    deleteStep(extension) {
        if (confirm(`Êtes-vous sûr de vouloir supprimer l'étape "${extension}" ?`)) {
            delete this.sviConfig[this.currentContext][extension];
            this.renderSteps();
            this.clearProperties();
            this.showMessage('Étape supprimée', 'success');
        }
    }

    reorderSteps(oldIndex, newIndex) {
        // Pour une implémentation future
        console.log('Réorganisation:', oldIndex, '->', newIndex);
    }

    closeModal(modalId) {
        document.getElementById(modalId).style.display = 'none';
    }

    showMessage(message, type = 'info') {
        console.log(type.toUpperCase() + ':', message);
        
        if (typeof Toastify !== 'undefined') {
            const colors = {
                success: 'linear-gradient(to right, #00b09b, #96c93d)',
                error: 'linear-gradient(to right, #ff5f6d, #ffc371)',
                info: 'linear-gradient(to right, #667eea, #764ba2)',
                warning: 'linear-gradient(to right, #f093fb, #f5576c)'
            };
            
            Toastify({
                text: message,
                duration: 3000,
                gravity: 'top',
                position: 'right',
                backgroundColor: colors[type] || colors.info,
                stopOnFocus: true
            }).showToast();
        } else {
            alert(message);
        }
    }
}

// Fermer les modales en cliquant à l'extérieur
window.onclick = function(event) {
    const modals = document.querySelectorAll('.modal');
    modals.forEach(modal => {
        if (event.target === modal) {
            modal.style.display = 'none';
        }
    });
};

// Fonction globale pour fermer les modales
function closeModal(modalId) {
    document.getElementById(modalId).style.display = 'none';
}

// Initialiser l'application
document.addEventListener('DOMContentLoaded', () => {
    window.sviAdmin = new SviAdmin();
});
