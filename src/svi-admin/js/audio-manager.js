/**
 * Gestionnaire des fichiers audio
 */
class AudioManager {
    constructor() {
        this.audioFiles = { fr: [], en: [] };
        this.currentPlayer = null;
        
        this.initEventListeners();
        this.loadAudioFiles();
    }

    static init() {
        if (!window.audioManager) {
            window.audioManager = new AudioManager();
        }
        return window.audioManager;
    }

    initEventListeners() {
        // Upload de fichiers
        document.getElementById('uploadBtn').addEventListener('click', () => this.uploadFiles());
        
        // Changement de fichier audio dans le modal
        document.getElementById('editAudioFile').addEventListener('change', (e) => {
            this.previewAudio(e.target.value);
        });
    }

    async loadAudioFiles() {
        try {
            // Pour l'instant, scanner les dossiers locaux
            // En production, cela devrait être une API
            await this.scanAudioDirectory('fr');
            await this.scanAudioDirectory('en');
            this.updateAudioList();
            this.updateAudioSelects();
        } catch (error) {
            console.error('Erreur lors du chargement des fichiers audio:', error);
        }
    }

    async scanAudioDirectory(language) {
        // Simulation - en production, utiliser une API
        const commonFiles = [
            'welcome.wav',
            'menu-main.wav',
            'invalid.wav',
            'timeout.wav',
            'commercial.wav',
            'conference.wav',
            'operator.wav',
            'support.wav',
            'test-audio.wav'
        ];

        this.audioFiles[language] = commonFiles.map(file => ({
            name: file,
            language: language,
            path: `uploads/${language}/${file}`,
            size: Math.floor(Math.random() * 100000) + 10000 // Simulation
        }));
    }

    updateAudioList() {
        const container = document.getElementById('audioList');
        container.innerHTML = '';

        ['fr', 'en'].forEach(lang => {
            this.audioFiles[lang].forEach(file => {
                const item = this.createAudioItem(file);
                container.appendChild(item);
            });
        });
    }

    createAudioItem(file) {
        const div = document.createElement('div');
        div.className = 'audio-item';
        div.innerHTML = `
            <div class="audio-info">
                <div class="audio-name">${file.name}</div>
                <div class="audio-lang">${file.language.toUpperCase()} - ${this.formatFileSize(file.size)}</div>
            </div>
            <div class="audio-controls">
                <button onclick="audioManager.playAudio('${file.path}')" title="Écouter">
                    <i class="fas fa-play"></i>
                </button>
                <button onclick="audioManager.stopAudio()" title="Arrêter">
                    <i class="fas fa-stop"></i>
                </button>
                <button onclick="audioManager.deleteAudio('${file.name}', '${file.language}')" title="Supprimer">
                    <i class="fas fa-trash"></i>
                </button>
            </div>
        `;
        return div;
    }

    updateAudioSelects() {
        const select = document.getElementById('editAudioFile');
        const currentLang = this.getCurrentLanguage();
        
        // Vider la liste
        select.innerHTML = '<option value="">Sélectionner un fichier...</option>';
        
        // Ajouter les fichiers de la langue courante
        this.audioFiles[currentLang].forEach(file => {
            const option = document.createElement('option');
            option.value = `custom/${file.language}/${file.name.replace('.wav', '')}`;
            option.textContent = file.name;
            select.appendChild(option);
        });
    }

    getCurrentLanguage() {
        // Déterminer la langue selon le contexte actuel
        if (window.sviEditor) {
            const context = window.sviEditor.currentContext;
            if (context === 'main_en') return 'en';
        }
        return 'fr';
    }

    async uploadFiles() {
        const fileInput = document.getElementById('audioFile');
        const languageSelect = document.getElementById('audioLang');
        
        if (!fileInput.files.length) {
            window.sviEditor.showNotification('Aucun fichier sélectionné', 'warning');
            return;
        }

        const language = languageSelect.value;
        
        for (const file of fileInput.files) {
            try {
                await this.uploadSingleFile(file, language);
            } catch (error) {
                window.sviEditor.showNotification(`Erreur upload ${file.name}: ${error.message}`, 'error');
            }
        }

        // Recharger la liste
        await this.loadAudioFiles();
        
        // Réinitialiser le formulaire
        fileInput.value = '';
        window.sviEditor.showNotification('Upload terminé', 'success');
    }

    async uploadSingleFile(file, language) {
        // Validation locale
        if (!file.name.toLowerCase().endsWith('.wav')) {
            throw new Error('Seuls les fichiers WAV sont autorisés');
        }

        if (file.size > 10 * 1024 * 1024) { // 10MB max
            throw new Error('Fichier trop volumineux (max 10MB)');
        }

        // Upload via API
        const response = await apiClient.uploadAudio(file, language);
        
        if (!response.success) {
            throw new Error(response.error);
        }

        return response.data;
    }

    playAudio(path) {
        this.stopAudio();
        
        this.currentPlayer = new Audio(path);
        this.currentPlayer.play().catch(error => {
            console.error('Erreur lecture audio:', error);
            window.sviEditor.showNotification('Erreur de lecture audio', 'error');
        });
    }

    stopAudio() {
        if (this.currentPlayer) {
            this.currentPlayer.pause();
            this.currentPlayer = null;
        }
    }

    previewAudio(audioPath) {
        const player = document.getElementById('previewPlayer');
        
        if (audioPath) {
            // Construire le chemin complet
            const fullPath = `uploads/${audioPath.replace('custom/', '')}.wav`;
            player.src = fullPath;
            player.style.display = 'block';
        } else {
            player.style.display = 'none';
        }
    }

    async deleteAudio(fileName, language) {
        if (!confirm(`Supprimer ${fileName} ?`)) return;

        try {
            // Ici, implémenter l'API de suppression
            // await apiClient.deleteAudio(fileName, language);
            
            // Pour l'instant, supprimer localement
            this.audioFiles[language] = this.audioFiles[language].filter(f => f.name !== fileName);
            this.updateAudioList();
            this.updateAudioSelects();
            
            window.sviEditor.showNotification('Fichier supprimé', 'success');
        } catch (error) {
            window.sviEditor.showNotification('Erreur de suppression: ' + error.message, 'error');
        }
    }

    formatFileSize(bytes) {
        if (bytes === 0) return '0 B';
        const k = 1024;
        const sizes = ['B', 'KB', 'MB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(1)) + ' ' + sizes[i];
    }
}
