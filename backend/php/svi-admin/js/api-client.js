/**
 * Client API pour l'interface SVI Admin
 */
class ApiClient {
    constructor() {
        this.baseUrl = 'api/';
    }

    /**
     * Effectue une requête HTTP
     */
    async request(endpoint, options = {}) {
        const url = this.baseUrl + endpoint;
        const config = {
            headers: {
                'Content-Type': 'application/json',
                ...options.headers
            },
            ...options
        };

        try {
            const response = await fetch(url, config);
            const data = await response.json();
            
            if (!response.ok) {
                throw new Error(data.error || `HTTP ${response.status}`);
            }
            
            return data;
        } catch (error) {
            console.error('API Error:', error);
            throw error;
        }
    }

    /**
     * Récupère la configuration SVI actuelle
     */
    async getSviConfig() {
        return this.request('get-svi-config.php');
    }

    /**
     * Sauvegarde la configuration SVI
     */
    async saveSviConfig(config) {
        return this.request('save-svi-config.php', {
            method: 'POST',
            body: JSON.stringify(config)
        });
    }

    /**
     * Upload un fichier audio
     */
    async uploadAudio(file, language) {
        const formData = new FormData();
        formData.append('audioFile', file);
        formData.append('language', language);

        return this.request('upload-audio.php', {
            method: 'POST',
            headers: {}, // Pas de Content-Type pour FormData
            body: formData
        });
    }

    /**
     * Valide la syntaxe d'une configuration
     */
    async validateSyntax(config) {
        return this.request('validate-syntax.php', {
            method: 'POST',
            body: JSON.stringify(config)
        });
    }

    /**
     * Recharge la configuration Asterisk
     */
    async reloadAsterisk() {
        return this.request('reload-asterisk.php', {
            method: 'POST'
        });
    }

    /**
     * Liste les fichiers audio disponibles
     */
    async getAudioFiles() {
        return this.request('list-audio.php');
    }
}

// Instance globale
window.apiClient = new ApiClient();
