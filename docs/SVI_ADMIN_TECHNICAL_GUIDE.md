# Guide Technique - SVI Admin

## 🔧 Configuration Docker avec Volumes

### Avantages des volumes par rapport aux COPY

- **Développement en temps réel** : Modifications instantanées sans rebuild
- **Flexibilité** : Configuration adaptable selon l'environnement
- **Performance** : Accès direct au système de fichiers
- **Maintenance** : Mise à jour simplifiée

### Configuration actuelle

```yaml
# compose.yml
services:
  web:
    build: 
      context: .
      dockerfile: web/Dockerfile
    volumes:
      # Code source complet (développement)
      - ./src:/var/www/html
      # Configurations Asterisk pour l'admin
      - ./asterisk/config:/var/www/html/asterisk-config
      - ./asterisk/sounds:/var/www/html/asterisk-sounds
      # Logs pour debugging
      - web_logs:/var/log/apache2
```

### Script d'initialisation

Le Dockerfile utilise maintenant un script d'initialisation :

```bash
#!/bin/bash
# /docker-entrypoint.sh

set -e

# Mise à jour des permissions à chaque démarrage
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html
chmod -R 775 /var/www/html/svi-admin/uploads

# Création du fichier de redirection si nécessaire
if [ ! -f /var/www/html/index.php ]; then
    echo '<?php header("Location: /svi-admin/"); exit; ?>' > /var/www/html/index.php
fi

# Démarrage d'Apache
exec apache2-foreground
```

## 🎨 Structure du code JavaScript

### Classe principale SVIAdmin

```javascript
class SVIAdmin {
    constructor() {
        this.currentContext = 'main';
        this.steps = {};
        this.selectedStep = null;
        this.apiClient = new SVIApiClient();
        this.audioManager = new AudioManager();
        
        this.initializeUI();
        this.setupEventListeners();
        this.loadConfiguration();
    }
    
    // Initialisation des composants UI
    initializeUI() {
        this.setupDragAndDrop();
        this.setupContextTabs();
        this.setupToolbox();
        this.setupPropertiesPanel();
    }
    
    // Configuration des événements
    setupEventListeners() {
        document.getElementById('addStepBtn').addEventListener('click', () => {
            this.showAddStepDialog();
        });
        
        document.getElementById('saveBtn').addEventListener('click', () => {
            this.saveConfiguration();
        });
        
        document.getElementById('testBtn').addEventListener('click', () => {
            this.testConfiguration();
        });
    }
}
```

### Gestion du Drag & Drop

```javascript
// Configuration SortableJS
setupDragAndDrop() {
    const stepsContainer = document.getElementById('stepsContainer');
    
    // Drag & drop pour réorganiser les étapes
    new Sortable(stepsContainer, {
        animation: 150,
        ghostClass: 'sortable-ghost',
        chosenClass: 'sortable-chosen',
        dragClass: 'sortable-drag',
        
        onEnd: (evt) => {
            this.reorderSteps(evt.oldIndex, evt.newIndex);
        }
    });
    
    // Drag & drop depuis la boîte à outils
    const toolboxItems = document.querySelectorAll('.tool-item');
    toolboxItems.forEach(item => {
        item.addEventListener('dragstart', (e) => {
            e.dataTransfer.setData('text/plain', item.dataset.type);
        });
    });
    
    // Zone de drop
    stepsContainer.addEventListener('dragover', (e) => {
        e.preventDefault();
        stepsContainer.classList.add('drag-over');
    });
    
    stepsContainer.addEventListener('drop', (e) => {
        e.preventDefault();
        stepsContainer.classList.remove('drag-over');
        
        const stepType = e.dataTransfer.getData('text/plain');
        this.addStep(stepType);
    });
}
```

### Gestion des types d'étapes

```javascript
// Configuration des types d'étapes
const STEP_TYPES = {
    welcome: {
        name: 'Accueil',
        icon: 'fas fa-home',
        defaultProperties: {
            audioFile: '',
            message: 'Bienvenue',
            timeout: 5000,
            repeatCount: 1
        }
    },
    menu: {
        name: 'Menu',
        icon: 'fas fa-list',
        defaultProperties: {
            audioFile: '',
            message: 'Faites votre choix',
            options: [],
            timeout: 10000,
            invalidRetries: 3
        }
    },
    dtmf: {
        name: 'Collecte DTMF',
        icon: 'fas fa-keyboard',
        defaultProperties: {
            audioFile: '',
            message: 'Veuillez saisir',
            minDigits: 1,
            maxDigits: 10,
            timeout: 15000,
            variable: 'user_input'
        }
    },
    transfer: {
        name: 'Transfert',
        icon: 'fas fa-phone-alt',
        defaultProperties: {
            destination: '',
            announceFile: '',
            timeout: 30000,
            options: 'tr'
        }
    },
    condition: {
        name: 'Condition',
        icon: 'fas fa-code-branch',
        defaultProperties: {
            variable: '',
            operator: 'equals',
            value: '',
            trueAction: 'goto',
            trueTarget: '',
            falseAction: 'goto',
            falseTarget: ''
        }
    },
    end: {
        name: 'Fin',
        icon: 'fas fa-stop',
        defaultProperties: {
            audioFile: '',
            message: 'Au revoir',
            hangup: true
        }
    }
};
```

### Panneau de propriétés dynamique

```javascript
// Génération du panneau de propriétés
showStepProperties(step) {
    const propertiesContent = document.getElementById('propertiesContent');
    
    if (!step) {
        propertiesContent.innerHTML = '<p>Sélectionnez une étape pour voir ses propriétés</p>';
        return;
    }
    
    let html = `
        <div class="property-group">
            <label for="stepName">Nom de l'étape</label>
            <input type="text" id="stepName" value="${step.name}" 
                   onchange="sviAdmin.updateStepProperty('name', this.value)">
        </div>
    `;
    
    // Propriétés spécifiques selon le type
    switch(step.type) {
        case 'welcome':
            html += this.generateWelcomeProperties(step);
            break;
        case 'menu':
            html += this.generateMenuProperties(step);
            break;
        case 'dtmf':
            html += this.generateDTMFProperties(step);
            break;
        case 'transfer':
            html += this.generateTransferProperties(step);
            break;
        case 'condition':
            html += this.generateConditionProperties(step);
            break;
        case 'end':
            html += this.generateEndProperties(step);
            break;
    }
    
    propertiesContent.innerHTML = html;
}
```

## 🎵 Gestion Audio Avancée

### Upload avec validation

```javascript
class AudioManager {
    constructor() {
        this.supportedFormats = ['wav', 'mp3', 'gsm', 'ulaw', 'alaw'];
        this.maxFileSize = 10 * 1024 * 1024; // 10MB
        this.uploadQueue = [];
    }
    
    async uploadFile(file) {
        // Validation préalable
        const validation = this.validateFile(file);
        if (!validation.valid) {
            throw new Error(validation.error);
        }
        
        // Ajout à la queue
        this.uploadQueue.push({
            file: file,
            status: 'pending',
            progress: 0
        });
        
        // Upload avec progress
        return this.processUpload(file);
    }
    
    async processUpload(file) {
        const formData = new FormData();
        formData.append('audio', file);
        
        const xhr = new XMLHttpRequest();
        
        return new Promise((resolve, reject) => {
            xhr.upload.addEventListener('progress', (e) => {
                if (e.lengthComputable) {
                    const progress = (e.loaded / e.total) * 100;
                    this.updateUploadProgress(file.name, progress);
                }
            });
            
            xhr.onload = () => {
                if (xhr.status === 200) {
                    const response = JSON.parse(xhr.responseText);
                    resolve(response);
                } else {
                    reject(new Error('Upload failed'));
                }
            };
            
            xhr.onerror = () => reject(new Error('Network error'));
            
            xhr.open('POST', '/svi-admin/api/upload-audio.php');
            xhr.send(formData);
        });
    }
    
    validateFile(file) {
        // Vérification du format
        const extension = file.name.split('.').pop().toLowerCase();
        if (!this.supportedFormats.includes(extension)) {
            return {
                valid: false,
                error: `Format non supporté. Formats acceptés: ${this.supportedFormats.join(', ')}`
            };
        }
        
        // Vérification de la taille
        if (file.size > this.maxFileSize) {
            return {
                valid: false,
                error: `Fichier trop volumineux. Taille maximale: ${this.maxFileSize / (1024*1024)}MB`
            };
        }
        
        // Vérification du nom
        if (!/^[a-zA-Z0-9_-]+\.[a-zA-Z0-9]+$/.test(file.name)) {
            return {
                valid: false,
                error: 'Nom de fichier invalide. Utilisez uniquement des lettres, chiffres, tirets et underscores'
            };
        }
        
        return { valid: true };
    }
}
```

### Prévisualisation audio

```javascript
// Lecteur audio modal
showAudioPreview(filename) {
    const modal = document.createElement('div');
    modal.className = 'audio-preview-modal';
    modal.innerHTML = `
        <div class="modal-backdrop" onclick="this.parentElement.remove()"></div>
        <div class="modal-content">
            <div class="modal-header">
                <h3>Prévisualisation Audio</h3>
                <button class="close-btn" onclick="this.closest('.audio-preview-modal').remove()">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <div class="modal-body">
                <div class="audio-info">
                    <h4>${filename}</h4>
                    <div class="audio-controls">
                        <audio controls preload="metadata">
                            <source src="/svi-admin/uploads/${filename}" type="audio/mpeg">
                            <source src="/svi-admin/uploads/${filename}" type="audio/wav">
                            Votre navigateur ne supporte pas l'audio.
                        </audio>
                    </div>
                </div>
                <div class="audio-actions">
                    <button class="btn btn-primary" onclick="sviAdmin.selectAudioFile('${filename}')">
                        Utiliser ce fichier
                    </button>
                    <button class="btn btn-secondary" onclick="this.closest('.audio-preview-modal').remove()">
                        Fermer
                    </button>
                </div>
            </div>
        </div>
    `;
    
    document.body.appendChild(modal);
    
    // Auto-focus sur l'audio
    const audio = modal.querySelector('audio');
    audio.addEventListener('loadedmetadata', () => {
        console.log(`Durée: ${audio.duration}s`);
    });
}
```

## 🔌 API Backend PHP

### Sauvegarde de configuration

```php
<?php
// /svi-admin/api/save-config.php

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

try {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($input['context']) || !isset($input['config'])) {
        throw new Exception('Paramètres manquants');
    }
    
    $context = $input['context'];
    $config = $input['config'];
    
    // Validation de la configuration
    $validation = validateConfig($config);
    if (!$validation['valid']) {
        throw new Exception('Configuration invalide: ' . $validation['error']);
    }
    
    // Sauvegarde en base de données
    $pdo = new PDO("mysql:host=mysql;dbname=doriav2", "doriav2_user", "doriav2_password");
    
    $stmt = $pdo->prepare("
        INSERT INTO svi_configurations (context, config, created_at, updated_at) 
        VALUES (?, ?, NOW(), NOW())
        ON DUPLICATE KEY UPDATE 
        config = VALUES(config), 
        updated_at = NOW()
    ");
    
    $stmt->execute([$context, json_encode($config)]);
    
    // Génération de la configuration Asterisk
    $asteriskConfig = generateAsteriskConfig($context, $config);
    
    // Sauvegarde dans le fichier extensions.conf
    $configPath = "/var/www/html/asterisk-config/extensions.conf";
    updateAsteriskConfig($configPath, $context, $asteriskConfig);
    
    echo json_encode([
        'success' => true,
        'message' => 'Configuration sauvegardée avec succès',
        'context' => $context,
        'timestamp' => date('Y-m-d H:i:s')
    ]);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}

function validateConfig($config) {
    // Validation des étapes
    if (!isset($config['steps']) || !is_array($config['steps'])) {
        return ['valid' => false, 'error' => 'Configuration des étapes manquante'];
    }
    
    foreach ($config['steps'] as $step) {
        if (!isset($step['type']) || !isset($step['name'])) {
            return ['valid' => false, 'error' => 'Étape invalide: type et nom requis'];
        }
        
        // Validation spécifique par type
        switch ($step['type']) {
            case 'menu':
                if (!isset($step['properties']['options']) || 
                    !is_array($step['properties']['options']) || 
                    count($step['properties']['options']) === 0) {
                    return ['valid' => false, 'error' => 'Menu sans options'];
                }
                break;
            case 'transfer':
                if (!isset($step['properties']['destination']) || 
                    empty($step['properties']['destination'])) {
                    return ['valid' => false, 'error' => 'Destination de transfert manquante'];
                }
                break;
        }
    }
    
    return ['valid' => true];
}

function generateAsteriskConfig($context, $config) {
    $asteriskConfig = "\n; Configuration SVI pour le contexte: $context\n";
    $asteriskConfig .= "[$context]\n";
    
    foreach ($config['steps'] as $index => $step) {
        $priority = $index + 1;
        $asteriskConfig .= generateStepConfig($step, $priority);
    }
    
    return $asteriskConfig;
}

function generateStepConfig($step, $priority) {
    switch ($step['type']) {
        case 'welcome':
            if (!empty($step['properties']['audioFile'])) {
                return "exten => s,$priority,Playback({$step['properties']['audioFile']})\n";
            } else {
                return "exten => s,$priority,SayText({$step['properties']['message']})\n";
            }
            
        case 'menu':
            $config = "exten => s,$priority,Background({$step['properties']['audioFile']})\n";
            $config .= "exten => s," . ($priority + 1) . ",WaitExten({$step['properties']['timeout']})\n";
            
            foreach ($step['properties']['options'] as $option) {
                $config .= "exten => {$option['digit']},1,Goto({$option['target']})\n";
            }
            
            return $config;
            
        case 'dtmf':
            return "exten => s,$priority,Read({$step['properties']['variable']},{$step['properties']['audioFile']},{$step['properties']['maxDigits']})\n";
            
        case 'transfer':
            return "exten => s,$priority,Dial(SIP/{$step['properties']['destination']},{$step['properties']['timeout']})\n";
            
        case 'condition':
            $variable = $step['properties']['variable'];
            $operator = $step['properties']['operator'];
            $value = $step['properties']['value'];
            $trueTarget = $step['properties']['trueTarget'];
            $falseTarget = $step['properties']['falseTarget'];
            
            return "exten => s,$priority,GotoIf(\$[\"$variable\" $operator \"$value\"]?$trueTarget:$falseTarget)\n";
            
        case 'end':
            $config = "";
            if (!empty($step['properties']['audioFile'])) {
                $config .= "exten => s,$priority,Playback({$step['properties']['audioFile']})\n";
                $priority++;
            }
            if ($step['properties']['hangup']) {
                $config .= "exten => s,$priority,Hangup()\n";
            }
            return $config;
            
        default:
            return "exten => s,$priority,NoOp(Étape non supportée: {$step['type']})\n";
    }
}
?>
```

## 🧪 Tests et Validation

### Tests unitaires JavaScript

```javascript
// Tests pour la validation des étapes
describe('Step Validation', () => {
    test('should validate welcome step', () => {
        const step = {
            type: 'welcome',
            name: 'Test Welcome',
            properties: {
                audioFile: 'welcome.wav',
                message: 'Hello',
                timeout: 5000
            }
        };
        
        const errors = validateStepProperties(step);
        expect(errors).toHaveLength(0);
    });
    
    test('should reject menu without options', () => {
        const step = {
            type: 'menu',
            name: 'Test Menu',
            properties: {
                audioFile: 'menu.wav',
                options: []
            }
        };
        
        const errors = validateStepProperties(step);
        expect(errors).toContain('Le menu doit avoir au moins une option');
    });
});

// Tests pour l'API
describe('API Client', () => {
    test('should save configuration', async () => {
        const client = new SVIApiClient();
        const config = {
            steps: [
                { type: 'welcome', name: 'Test', properties: {} }
            ]
        };
        
        const result = await client.saveConfig('test', config);
        expect(result.success).toBe(true);
    });
});
```

### Tests d'intégration

```bash
#!/bin/bash
# test-integration.sh

echo "Test d'intégration SVI Admin"

# Test de l'interface
echo "1. Test d'accès à l'interface..."
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/svi-admin/)
if [ $response -eq 200 ]; then
    echo "✅ Interface accessible"
else
    echo "❌ Interface non accessible (code: $response)"
    exit 1
fi

# Test des APIs
echo "2. Test des APIs..."
response=$(curl -s -X POST http://localhost:8080/svi-admin/api/test.php)
if echo "$response" | grep -q "success"; then
    echo "✅ API fonctionnelle"
else
    echo "❌ API non fonctionnelle"
    exit 1
fi

# Test de sauvegarde
echo "3. Test de sauvegarde..."
response=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -d '{"context":"test","config":{"steps":[{"type":"welcome","name":"Test"}]}}' \
  http://localhost:8080/svi-admin/api/save-config.php)

if echo "$response" | grep -q "success"; then
    echo "✅ Sauvegarde fonctionnelle"
else
    echo "❌ Sauvegarde non fonctionnelle"
    exit 1
fi

echo "🎉 Tous les tests d'intégration sont passés!"
```

## 📊 Monitoring et Performance

### Métriques importantes

```javascript
// Monitoring des performances
class PerformanceMonitor {
    constructor() {
        this.metrics = {
            loadTime: 0,
            apiCalls: 0,
            errors: 0,
            userActions: 0
        };
        
        this.startTime = performance.now();
    }
    
    recordLoadTime() {
        this.metrics.loadTime = performance.now() - this.startTime;
        console.log(`Interface chargée en ${this.metrics.loadTime}ms`);
    }
    
    recordAPICall(endpoint, duration) {
        this.metrics.apiCalls++;
        console.log(`API ${endpoint}: ${duration}ms`);
    }
    
    recordError(error) {
        this.metrics.errors++;
        console.error('Erreur:', error);
    }
    
    recordUserAction(action) {
        this.metrics.userActions++;
        console.log(`Action utilisateur: ${action}`);
    }
    
    getReport() {
        return {
            ...this.metrics,
            uptime: performance.now() - this.startTime,
            timestamp: new Date().toISOString()
        };
    }
}
```

### Optimisations recommandées

1. **Lazy Loading** pour les fichiers audio
2. **Debouncing** pour les sauvegardes automatiques
3. **Caching** des configurations fréquemment utilisées
4. **Compression** des réponses API
5. **Minification** des assets JavaScript/CSS

Cette documentation technique couvre tous les aspects du développement et de la maintenance de l'interface SVI Admin avec la nouvelle architecture basée sur les volumes Docker.
