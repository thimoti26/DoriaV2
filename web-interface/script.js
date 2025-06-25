/**
 * DoriaV2 Asterisk Interface - JavaScript principal
 * Gestion des interactions et communications avec l'API
 */

class DoriaInterface {
    constructor() {
        this.apiBase = '/api';
        this.refreshInterval = null;
        this.statusCheckInterval = 30000; // 30 secondes
        this.toastContainer = null;
        this.lastUpdate = null;
        
        this.init();
    }
    
    /**
     * Initialisation de l'interface
     */
    init() {
        this.setupEventListeners();
        this.initializeToasts();
        this.loadConfiguration();
        this.checkSystemStatus();
        this.loadInitialData();
        this.startAutoRefresh();
        
        // Animations d'entrée
        this.animateElements();
        
        console.log('🚀 DoriaV2 Interface initialisée');
    }
    
    /**
     * Configuration des écouteurs d'événements
     */
    setupEventListeners() {
        // Gestion des tabs
        document.querySelectorAll('[data-bs-toggle="tab"]').forEach(tab => {
            tab.addEventListener('shown.bs.tab', (e) => {
                this.onTabChange(e.target.getAttribute('data-bs-target'));
            });
        });
        
        // Gestion du redimensionnement
        window.addEventListener('resize', this.debounce(() => {
            this.handleResize();
        }, 250));
        
        // Gestion de la visibilité de la page
        document.addEventListener('visibilitychange', () => {
            if (document.hidden) {
                this.pauseAutoRefresh();
            } else {
                this.resumeAutoRefresh();
            }
        });
        
        // Gestion des raccourcis clavier
        document.addEventListener('keydown', (e) => {
            this.handleKeyboardShortcuts(e);
        });
    }
    
    /**
     * Initialisation du système de notifications
     */
    initializeToasts() {
        this.toastContainer = document.querySelector('.toast-container');
        if (!this.toastContainer) {
            // Créer le container s'il n'existe pas
            this.toastContainer = document.createElement('div');
            this.toastContainer.className = 'toast-container position-fixed bottom-0 end-0 p-3';
            document.body.appendChild(this.toastContainer);
        }
    }
    
    /**
     * Chargement de la configuration
     */
    async loadConfiguration() {
        try {
            const response = await fetch('/config.json');
            if (response.ok) {
                this.config = await response.json();
                this.updateConfigDisplay();
            }
        } catch (error) {
            console.warn('Configuration par défaut utilisée');
            this.config = this.getDefaultConfig();
        }
    }
    
    /**
     * Configuration par défaut
     */
    getDefaultConfig() {
        return {
            system: {
                name: "DoriaV2 Asterisk PBX",
                version: "2.0.0"
            },
            extensions: {
                osmo: {
                    number: "1000",
                    username: "osmo",
                    password: "osmoosmo"
                }
            },
            test_numbers: {
                "*43": "Test d'écho",
                "*97": "Messagerie vocale",
                "123": "Message de bienvenue",
                "1000": "Extension osmo"
            }
        };
    }
    
    /**
     * Mise à jour de l'affichage de la configuration
     */
    updateConfigDisplay() {
        if (this.config) {
            // Mettre à jour le titre si nécessaire
            const title = document.querySelector('.header h1');
            if (title) {
                title.innerHTML = `<i class="fas fa-phone-alt"></i> ${this.config.system.name}`;
            }
        }
    }
    
    /**
     * Vérification du statut du système
     */
    async checkSystemStatus() {
        try {
            const response = await this.apiCall('GET', '/status');
            
            if (response.success) {
                this.updateSystemStatus(response.data);
                this.updateLastRefresh();
            } else {
                this.updateSystemStatus({ status: 'error', error: response.error });
            }
        } catch (error) {
            console.warn('Statut par défaut utilisé:', error.message);
            this.updateSystemStatus({ 
                status: 'offline', 
                asterisk: false, 
                extensions: 1 
            });
        }
    }
    
    /**
     * Mise à jour de l'affichage du statut
     */
    updateSystemStatus(data) {
        const statusBadge = document.getElementById('systemStatus');
        const asteriskStatus = document.getElementById('asteriskStatus');
        const extensionsCount = document.getElementById('extensionsCount');
        
        if (statusBadge) {
            this.updateStatusBadge(statusBadge, data.status);
        }
        
        if (asteriskStatus) {
            this.updateAsteriskStatus(asteriskStatus, data.asterisk);
        }
        
        if (extensionsCount) {
            extensionsCount.textContent = data.extensions || 1;
            this.animateCounter(extensionsCount, data.extensions || 1);
        }
        
        // Mettre à jour les indicateurs dans l'interface
        this.updateStatusIndicators(data.status);
    }
    
    /**
     * Mise à jour du badge de statut
     */
    updateStatusBadge(element, status) {
        const statusConfig = {
            online: {
                class: 'bg-success',
                icon: 'fas fa-check-circle',
                text: 'En ligne'
            },
            offline: {
                class: 'bg-danger',
                icon: 'fas fa-times-circle',
                text: 'Hors ligne'
            },
            warning: {
                class: 'bg-warning',
                icon: 'fas fa-exclamation-triangle',
                text: 'Attention'
            },
            error: {
                class: 'bg-danger',
                icon: 'fas fa-exclamation-circle',
                text: 'Erreur'
            }
        };
        
        const config = statusConfig[status] || statusConfig.offline;
        element.className = `status-badge ${config.class}`;
        element.innerHTML = `<i class="${config.icon}"></i> ${config.text}`;
    }
    
    /**
     * Mise à jour du statut Asterisk
     */
    updateAsteriskStatus(element, isOnline) {
        if (isOnline) {
            element.innerHTML = '<i class="fas fa-check-circle text-success"></i>';
            element.parentElement.classList.add('bounce-in');
        } else {
            element.innerHTML = '<i class="fas fa-times-circle text-danger"></i>';
        }
    }
    
    /**
     * Mise à jour des indicateurs de statut
     */
    updateStatusIndicators(status) {
        const indicators = document.querySelectorAll('.status-indicator');
        indicators.forEach(indicator => {
            indicator.className = 'status-indicator';
            if (status === 'online') {
                indicator.classList.add('status-online', 'pulsing');
            } else if (status === 'warning') {
                indicator.classList.add('status-warning');
            } else {
                indicator.classList.add('status-offline');
            }
        });
    }
    
    /**
     * Contrôle du système
     */
    async controlSystem(action) {
        this.showNotification(`Exécution de l'action: ${action}...`, 'info');
        
        try {
            const response = await this.apiCall('POST', `/control/${action}`);
            
            if (response.success) {
                this.showNotification(
                    response.data.message || `Action ${action} exécutée avec succès`,
                    'success'
                );
                
                // Attendre un peu puis rafraîchir le statut
                setTimeout(() => {
                    this.checkSystemStatus();
                }, 2000);
            } else {
                this.showNotification(`Erreur: ${response.error}`, 'error');
            }
        } catch (error) {
            console.warn(`Action ${action} simulée`);
            this.showNotification(`Action ${action} simulée (mode développement)`, 'warning');
        }
    }
    
    /**
     * Commandes Docker
     */
    async dockerCommand(command) {
        this.showNotification(`Exécution de docker-compose ${command}...`, 'info');
        
        try {
            const response = await this.apiCall('POST', `/docker/${command}`);
            
            if (response.success) {
                this.showNotification(response.data.message, 'success');
            } else {
                this.showNotification(`Erreur Docker: ${response.error}`, 'error');
            }
        } catch (error) {
            this.showNotification(`Docker ${command} simulé`, 'warning');
        }
    }
    
    /**
     * Commandes Asterisk
     */
    async asteriskCommand(command) {
        this.showNotification(`Exécution de la commande Asterisk: ${command}...`, 'info');
        
        try {
            const response = await this.apiCall('POST', `/control/${command}`);
            
            if (response.success) {
                this.showNotification(response.data.message, 'success');
            } else {
                this.showNotification(`Erreur Asterisk: ${response.error}`, 'error');
            }
        } catch (error) {
            this.showNotification(`Commande Asterisk '${command}' simulée`, 'warning');
        }
    }
    
    /**
     * Copie dans le presse-papiers
     */
    async copyToClipboard(text) {
        try {
            await navigator.clipboard.writeText(text);
            this.showNotification(`Numéro ${text} copié dans le presse-papiers`, 'success');
        } catch (error) {
            // Fallback pour les navigateurs plus anciens
            const textArea = document.createElement('textarea');
            textArea.value = text;
            document.body.appendChild(textArea);
            textArea.select();
            document.execCommand('copy');
            document.body.removeChild(textArea);
            this.showNotification(`Numéro ${text} copié`, 'success');
        }
    }
    
    /**
     * Chargement des journaux
     */
    async loadLogs(type = 'asterisk') {
        const containerId = type === 'docker' ? 'dockerLogs' : 'asteriskLogs';
        const container = document.getElementById(containerId);
        
        if (!container) return;
        
        // Affichage du loading
        container.innerHTML = '<div class="text-center loading-shimmer"><i class="fas fa-spinner fa-spin"></i> Chargement des journaux...</div>';
        
        try {
            const response = await this.apiCall('GET', `/logs/${type}`);
            
            if (response.success && response.data.logs) {
                this.displayLogs(container, response.data.logs);
            } else {
                this.displaySimulatedLogs(container, type);
            }
        } catch (error) {
            this.displaySimulatedLogs(container, type);
        }
    }
    
    /**
     * Affichage des journaux
     */
    displayLogs(container, logs) {
        const logLines = Array.isArray(logs) ? logs : logs.split('\n');
        container.innerHTML = logLines
            .filter(line => line.trim())
            .map(line => this.formatLogLine(line))
            .join('\n');
        
        // Faire défiler vers le bas
        container.scrollTop = container.scrollHeight;
    }
    
    /**
     * Affichage des journaux simulés
     */
    displaySimulatedLogs(container, type) {
        const timestamp = new Date().toLocaleTimeString();
        const logs = type === 'docker' ? [
            `[${timestamp}] docker-compose: Démarrage des conteneurs`,
            `[${timestamp}] asterisk_1: Container started`,
            `[${timestamp}] web_1: Container started`,
            `[${timestamp}] asterisk_1: Loading configurations...`,
            `[${timestamp}] asterisk_1: SIP module initialized`,
            `[${timestamp}] asterisk_1: Extension osmo configured`,
            `[${timestamp}] asterisk_1: System ready for calls`
        ] : [
            `[${timestamp}] INFO: Asterisk démarré avec succès`,
            `[${timestamp}] INFO: Extension osmo (1000) enregistrée`,
            `[${timestamp}] INFO: SIP/UDP écoute sur port 5060`,
            `[${timestamp}] INFO: Module chan_sip chargé`,
            `[${timestamp}] INFO: Dialplan chargé depuis extensions.conf`,
            `[${timestamp}] INFO: Système prêt pour les appels`,
            `[${timestamp}] DEBUG: Configuration SIP validée`,
            `[${timestamp}] STATUS: Système opérationnel`
        ];
        
        this.displayLogs(container, logs);
    }
    
    /**
     * Formatage d'une ligne de journal
     */
    formatLogLine(line) {
        // Colorisation basique des logs
        if (line.includes('ERROR') || line.includes('FAILED')) {
            return `<span style="color: #ff6b6b;">${line}</span>`;
        } else if (line.includes('WARNING') || line.includes('WARN')) {
            return `<span style="color: #ffa726;">${line}</span>`;
        } else if (line.includes('SUCCESS') || line.includes('OK')) {
            return `<span style="color: #66bb6a;">${line}</span>`;
        } else if (line.includes('INFO')) {
            return `<span style="color: #42a5f5;">${line}</span>`;
        }
        return line;
    }
    
    /**
     * Affichage des notifications
     */
    showNotification(message, type = 'info', duration = 5000) {
        const toastId = 'toast-' + Date.now();
        const iconMap = {
            success: 'fas fa-check-circle text-success',
            error: 'fas fa-exclamation-circle text-danger',
            warning: 'fas fa-exclamation-triangle text-warning',
            info: 'fas fa-info-circle text-info'
        };
        
        const toastHTML = `
            <div id="${toastId}" class="toast fade-in-up" role="alert" aria-live="assertive" aria-atomic="true">
                <div class="toast-header">
                    <i class="${iconMap[type] || iconMap.info} me-2"></i>
                    <strong class="me-auto">DoriaV2</strong>
                    <small class="text-muted">${new Date().toLocaleTimeString()}</small>
                    <button type="button" class="btn-close" data-bs-dismiss="toast" aria-label="Close"></button>
                </div>
                <div class="toast-body">
                    ${message}
                </div>
            </div>
        `;
        
        this.toastContainer.insertAdjacentHTML('beforeend', toastHTML);
        
        const toastElement = document.getElementById(toastId);
        const toast = new bootstrap.Toast(toastElement, {
            autohide: true,
            delay: duration
        });
        
        toast.show();
        
        // Nettoyer après fermeture
        toastElement.addEventListener('hidden.bs.toast', () => {
            toastElement.remove();
        });
    }
    
    /**
     * Appel API générique
     */
    async apiCall(method, endpoint, data = null) {
        const url = this.apiBase + endpoint;
        const options = {
            method,
            headers: {
                'Content-Type': 'application/json',
            }
        };
        
        if (data && method !== 'GET') {
            options.body = JSON.stringify(data);
        }
        
        const response = await fetch(url, options);
        return await response.json();
    }
    
    /**
     * Gestion du changement d'onglet
     */
    onTabChange(tabId) {
        switch (tabId) {
            case '#dashboard':
                this.checkSystemStatus();
                break;
            case '#logs':
                this.loadLogs('asterisk');
                this.loadLogs('docker');
                break;
            case '#system':
                this.loadSystemInfo();
                break;
        }
    }
    
    /**
     * Chargement des informations système
     */
    loadSystemInfo() {
        this.updateTimestamp();
    }
    
    /**
     * Mise à jour du timestamp
     */
    updateTimestamp() {
        const timestampElement = document.getElementById('lastUpdate');
        if (timestampElement) {
            timestampElement.textContent = new Date().toLocaleString('fr-FR');
        }
        this.lastUpdate = new Date();
    }
    
    /**
     * Mise à jour de la dernière actualisation
     */
    updateLastRefresh() {
        this.updateTimestamp();
    }
    
    /**
     * Démarrage de l'actualisation automatique
     */
    startAutoRefresh() {
        this.refreshInterval = setInterval(() => {
            this.checkSystemStatus();
        }, this.statusCheckInterval);
    }
    
    /**
     * Pause de l'actualisation automatique
     */
    pauseAutoRefresh() {
        if (this.refreshInterval) {
            clearInterval(this.refreshInterval);
            this.refreshInterval = null;
        }
    }
    
    /**
     * Reprise de l'actualisation automatique
     */
    resumeAutoRefresh() {
        if (!this.refreshInterval) {
            this.startAutoRefresh();
        }
    }
    
    /**
     * Chargement des données initiales
     */
    loadInitialData() {
        this.updateTimestamp();
        this.loadLogs('asterisk');
        this.loadLogs('docker');
    }
    
    /**
     * Animation des éléments
     */
    animateElements() {
        // Animer les cartes avec un délai
        const cards = document.querySelectorAll('.card');
        cards.forEach((card, index) => {
            card.style.animationDelay = `${index * 0.1}s`;
            card.classList.add('fade-in-up');
        });
        
        // Animer les métriques
        const metrics = document.querySelectorAll('.system-metric');
        metrics.forEach((metric, index) => {
            setTimeout(() => {
                metric.classList.add('bounce-in');
            }, index * 200);
        });
    }
    
    /**
     * Animation des compteurs
     */
    animateCounter(element, targetValue) {
        const startValue = parseInt(element.textContent) || 0;
        const duration = 1000;
        const stepTime = Math.abs(Math.floor(duration / targetValue));
        
        let currentValue = startValue;
        const timer = setInterval(() => {
            currentValue += (targetValue > startValue) ? 1 : -1;
            element.textContent = currentValue;
            
            if (currentValue === targetValue) {
                clearInterval(timer);
            }
        }, stepTime);
    }
    
    /**
     * Gestion du redimensionnement
     */
    handleResize() {
        // Réajuster les éléments si nécessaire
        console.log('Redimensionnement détecté');
    }
    
    /**
     * Gestion des raccourcis clavier
     */
    handleKeyboardShortcuts(event) {
        if (event.ctrlKey || event.metaKey) {
            switch (event.key) {
                case 'r':
                    event.preventDefault();
                    this.checkSystemStatus();
                    this.showNotification('Statut actualisé', 'info');
                    break;
                case '1':
                    event.preventDefault();
                    document.getElementById('dashboard-tab').click();
                    break;
                case '2':
                    event.preventDefault();
                    document.getElementById('extensions-tab').click();
                    break;
                case '3':
                    event.preventDefault();
                    document.getElementById('system-tab').click();
                    break;
                case '4':
                    event.preventDefault();
                    document.getElementById('logs-tab').click();
                    break;
            }
        }
    }
    
    /**
     * Utilitaire de debounce
     */
    debounce(func, wait) {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                clearTimeout(timeout);
                func(...args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
        };
    }
    
    /**
     * Nettoyage lors de la fermeture
     */
    cleanup() {
        this.pauseAutoRefresh();
        console.log('🧹 Interface nettoyée');
    }
}

// Fonctions globales pour la compatibilité avec l'HTML
let doriaInterface;

// Initialisation automatique
document.addEventListener('DOMContentLoaded', () => {
    doriaInterface = new DoriaInterface();
});

// Nettoyage avant fermeture
window.addEventListener('beforeunload', () => {
    if (doriaInterface) {
        doriaInterface.cleanup();
    }
});

// Fonctions exposées globalement pour l'interface
window.controlSystem = (action) => doriaInterface?.controlSystem(action);
window.dockerCommand = (command) => doriaInterface?.dockerCommand(command);
window.asteriskCommand = (command) => doriaInterface?.asteriskCommand(command);
window.copyToClipboard = (text) => doriaInterface?.copyToClipboard(text);
window.refreshLogs = () => doriaInterface?.loadLogs('asterisk');
window.refreshDockerLogs = () => doriaInterface?.loadLogs('docker');
window.refreshStatus = () => doriaInterface?.checkSystemStatus();
window.testExtension = () => doriaInterface?.showNotification('Test de l\'extension osmo en cours...', 'info');
window.openShell = () => doriaInterface?.showNotification('Ouverture de la console Asterisk...', 'info');
window.openLinphoneGuide = () => {
    const modal = new bootstrap.Modal(document.getElementById('linphoneModal'));
    modal.show();
};
window.openDocumentation = () => doriaInterface?.showNotification('Ouverture de la documentation...', 'info');
window.openConfigFiles = () => doriaInterface?.showNotification('Accès aux fichiers de configuration...', 'info');
