// Variables globales
let nodes = [];
let connections = [];
let selectedNode = null;
let isConnecting = false;
let connectionStart = null;
let tempConnection = null;
let nodeCounter = 0;

// Classes et types de nœuds
const nodeTypes = {
    start: { icon: 'fas fa-play', color: '#28a745', label: 'Début' },
    welcome: { icon: 'fas fa-volume-up', color: '#17a2b8', label: 'Message d\'accueil' },
    menu: { icon: 'fas fa-list', color: '#007bff', label: 'Menu' },
    transfer: { icon: 'fas fa-phone-alt', color: '#ffc107', label: 'Transfert' },
    end: { icon: 'fas fa-stop', color: '#dc3545', label: 'Fin' }
};

function initializeSviEditor() {
    setupDragAndDrop();
    setupCanvas();
    setupSVG();
}

function setupDragAndDrop() {
    const toolItems = document.querySelectorAll('.tool-item');
    const canvas = document.getElementById('flow-canvas');

    toolItems.forEach(item => {
        item.addEventListener('dragstart', (e) => {
            e.dataTransfer.setData('text/plain', e.target.dataset.type);
        });
    });

    canvas.addEventListener('dragover', (e) => {
        e.preventDefault();
    });

    canvas.addEventListener('drop', (e) => {
        e.preventDefault();
        const nodeType = e.dataTransfer.getData('text/plain');
        const rect = canvas.getBoundingClientRect();
        const x = e.clientX - rect.left;
        const y = e.clientY - rect.top;
        createNode(nodeType, x, y);
    });
}

function setupCanvas() {
    const canvas = document.getElementById('flow-canvas');
    
    canvas.addEventListener('click', (e) => {
        if (e.target === canvas) {
            deselectAllNodes();
        }
    });
}

function setupSVG() {
    const svg = document.getElementById('connections-svg');
    svg.innerHTML = `
        <defs>
            <marker id="arrowhead" markerWidth="10" markerHeight="7" 
                    refX="9" refY="3.5" orient="auto">
                <polygon points="0 0, 10 3.5, 0 7" fill="#007bff" />
            </marker>
        </defs>
    `;
}

function createNode(type, x, y) {
    const nodeId = `node_${++nodeCounter}`;
    const nodeConfig = nodeTypes[type];
    
    const node = {
        id: nodeId,
        type: type,
        label: nodeConfig.label,
        x: x,
        y: y,
        properties: getDefaultProperties(type)
    };
    
    nodes.push(node);
    renderNode(node);
}

function getDefaultProperties(type) {
    switch (type) {
        case 'transfer':
            return { number: '100' };
        case 'welcome':
            return { audioFile: 'welcome.wav' };
        case 'menu':
            return { audioFile: 'menu.wav', timeout: 10 };
        default:
            return {};
    }
}

function renderNode(node) {
    const nodeElement = document.createElement('div');
    nodeElement.className = `svi-node node-${node.type}`;
    nodeElement.id = node.id;
    nodeElement.style.left = node.x + 'px';
    nodeElement.style.top = node.y + 'px';
    
    const nodeConfig = nodeTypes[node.type];
    
    nodeElement.innerHTML = `
        <div class="node-header">
            <div>
                <i class="${nodeConfig.icon}"></i>
                <span>${node.label}</span>
            </div>
            <div class="node-type">${node.type}</div>
        </div>
        <div class="connection-point input" data-node="${node.id}" data-type="input"></div>
        <div class="connection-point output" data-node="${node.id}" data-type="output"></div>
    `;
    
    // Événements pour le nœud
    nodeElement.addEventListener('click', (e) => {
        e.stopPropagation();
        selectNode(node.id);
    });
    
    nodeElement.addEventListener('dblclick', (e) => {
        e.stopPropagation();
        editNodeProperties(node.id);
    });
    
    // Drag & Drop pour déplacer les nœuds
    let isDragging = false;
    let dragStartX, dragStartY;
    
    nodeElement.addEventListener('mousedown', (e) => {
        if (e.target.classList.contains('connection-point')) return;
        isDragging = true;
        dragStartX = e.clientX - node.x;
        dragStartY = e.clientY - node.y;
        e.preventDefault();
    });
    
    document.addEventListener('mousemove', (e) => {
        if (!isDragging) return;
        node.x = e.clientX - dragStartX;
        node.y = e.clientY - dragStartY;
        nodeElement.style.left = node.x + 'px';
        nodeElement.style.top = node.y + 'px';
        updateConnections();
    });
    
    document.addEventListener('mouseup', () => {
        isDragging = false;
    });
    
    // Événements pour les points de connexion
    const connectionPoints = nodeElement.querySelectorAll('.connection-point');
    connectionPoints.forEach(point => {
        point.addEventListener('click', (e) => {
            e.stopPropagation();
            handleConnectionClick(point);
        });
    });
    
    document.getElementById('nodes-layer').appendChild(nodeElement);
}

function handleConnectionClick(point) {
    const nodeId = point.dataset.node;
    const pointType = point.dataset.type;
    
    if (!isConnecting) {
        // Début de connexion
        if (pointType === 'output') {
            isConnecting = true;
            connectionStart = { nodeId, pointType };
            point.parentElement.classList.add('connecting');
            startTempConnection(point);
        }
    } else {
        // Fin de connexion
        if (pointType === 'input' && connectionStart.nodeId !== nodeId) {
            createConnection(connectionStart.nodeId, nodeId);
            endTempConnection();
        } else {
            cancelConnection();
        }
    }
}

function startTempConnection(startPoint) {
    const svg = document.getElementById('connections-svg');
    const rect = startPoint.getBoundingClientRect();
    const canvasRect = svg.getBoundingClientRect();
    
    const startX = rect.left - canvasRect.left + rect.width / 2;
    const startY = rect.top - canvasRect.top + rect.height / 2;
    
    tempConnection = document.createElementNS('http://www.w3.org/2000/svg', 'line');
    tempConnection.setAttribute('class', 'temp-connection');
    tempConnection.setAttribute('x1', startX);
    tempConnection.setAttribute('y1', startY);
    tempConnection.setAttribute('x2', startX);
    tempConnection.setAttribute('y2', startY);
    
    svg.appendChild(tempConnection);
    
    // Suivre la souris
    document.addEventListener('mousemove', updateTempConnection);
}

function updateTempConnection(e) {
    if (!tempConnection) return;
    
    const svg = document.getElementById('connections-svg');
    const rect = svg.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    
    tempConnection.setAttribute('x2', x);
    tempConnection.setAttribute('y2', y);
}

function endTempConnection() {
    if (tempConnection) {
        tempConnection.remove();
        tempConnection = null;
    }
    
    document.removeEventListener('mousemove', updateTempConnection);
    
    const connectingNode = document.querySelector('.svi-node.connecting');
    if (connectingNode) {
        connectingNode.classList.remove('connecting');
    }
    
    isConnecting = false;
    connectionStart = null;
}

function cancelConnection() {
    endTempConnection();
}

function createConnection(fromNodeId, toNodeId) {
    const connectionId = `conn_${fromNodeId}_${toNodeId}`;
    
    // Vérifier si la connexion existe déjà
    if (connections.find(c => c.from === fromNodeId && c.to === toNodeId)) {
        return;
    }
    
    const connection = {
        id: connectionId,
        from: fromNodeId,
        to: toNodeId
    };
    
    connections.push(connection);
    renderConnection(connection);
}

function renderConnection(connection) {
    const fromNode = nodes.find(n => n.id === connection.from);
    const toNode = nodes.find(n => n.id === connection.to);
    
    if (!fromNode || !toNode) return;
    
    const svg = document.getElementById('connections-svg');
    
    const fromElement = document.getElementById(fromNode.id);
    const toElement = document.getElementById(toNode.id);
    
    const fromRect = fromElement.getBoundingClientRect();
    const toRect = toElement.getBoundingClientRect();
    const svgRect = svg.getBoundingClientRect();
    
    const startX = fromRect.right - svgRect.left - 6;
    const startY = fromRect.top - svgRect.top + fromRect.height / 2;
    const endX = toRect.left - svgRect.left + 6;
    const endY = toRect.top - svgRect.top + toRect.height / 2;
    
    const path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
    const d = `M ${startX} ${startY} C ${startX + 50} ${startY} ${endX - 50} ${endY} ${endX} ${endY}`;
    
    path.setAttribute('d', d);
    path.setAttribute('class', 'connection-line');
    path.setAttribute('data-connection', connection.id);
    
    path.addEventListener('click', () => {
        if (confirm('Supprimer cette connexion ?')) {
            removeConnection(connection.id);
        }
    });
    
    svg.appendChild(path);
}

function updateConnections() {
    const svg = document.getElementById('connections-svg');
    const paths = svg.querySelectorAll('.connection-line');
    paths.forEach(path => path.remove());
    
    connections.forEach(connection => {
        renderConnection(connection);
    });
}

function removeConnection(connectionId) {
    connections = connections.filter(c => c.id !== connectionId);
    updateConnections();
}

function selectNode(nodeId) {
    deselectAllNodes();
    selectedNode = nodeId;
    document.getElementById(nodeId).classList.add('selected');
}

function deselectAllNodes() {
    selectedNode = null;
    document.querySelectorAll('.svi-node.selected').forEach(node => {
        node.classList.remove('selected');
    });
}

function editNodeProperties(nodeId) {
    const node = nodes.find(n => n.id === nodeId);
    if (!node) return;
    
    // Remplir le formulaire modal
    document.getElementById('nodeLabel').value = node.label;
    
    // Propriétés spécifiques selon le type
    const specificProps = document.getElementById('specificProperties');
    specificProps.innerHTML = '';
    
    if (node.type === 'transfer') {
        specificProps.innerHTML = `
            <div class="mb-3">
                <label for="transferNumber" class="form-label">Numéro de transfert</label>
                <input type="text" class="form-control" id="transferNumber" value="${node.properties.number || ''}">
            </div>
        `;
    } else if (node.type === 'welcome' || node.type === 'menu') {
        specificProps.innerHTML = `
            <div class="mb-3">
                <label for="audioFile" class="form-label">Fichier audio</label>
                <input type="text" class="form-control" id="audioFile" value="${node.properties.audioFile || ''}">
            </div>
        `;
        
        if (node.type === 'menu') {
            specificProps.innerHTML += `
                <div class="mb-3">
                    <label for="timeout" class="form-label">Timeout (secondes)</label>
                    <input type="number" class="form-control" id="timeout" value="${node.properties.timeout || 10}">
                </div>
            `;
        }
    }
    
    // Stocker l'ID du nœud pour la sauvegarde
    document.getElementById('nodePropertiesForm').dataset.nodeId = nodeId;
    
    // Afficher le modal
    const modal = new bootstrap.Modal(document.getElementById('nodePropertiesModal'));
    modal.show();
}

function saveNodeProperties() {
    const nodeId = document.getElementById('nodePropertiesForm').dataset.nodeId;
    const node = nodes.find(n => n.id === nodeId);
    if (!node) return;
    
    // Sauvegarder les propriétés
    node.label = document.getElementById('nodeLabel').value;
    
    if (node.type === 'transfer') {
        node.properties.number = document.getElementById('transferNumber').value;
    } else if (node.type === 'welcome' || node.type === 'menu') {
        node.properties.audioFile = document.getElementById('audioFile').value;
        
        if (node.type === 'menu') {
            node.properties.timeout = parseInt(document.getElementById('timeout').value) || 10;
        }
    }
    
    // Mettre à jour l'affichage
    const nodeElement = document.getElementById(nodeId);
    const labelElement = nodeElement.querySelector('.node-header span');
    if (labelElement) {
        labelElement.textContent = node.label;
    }
    
    // Fermer le modal
    const modal = bootstrap.Modal.getInstance(document.getElementById('nodePropertiesModal'));
    modal.hide();
}

function saveFlow() {
    const flowData = {
        nodes: nodes,
        connections: connections
    };
    
    fetch('/svi-admin/api/save-flow-config.php', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(flowData)
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showNotification('Configuration sauvegardée avec succès!', 'success');
        } else {
            showNotification('Erreur lors de la sauvegarde: ' + data.error, 'danger');
        }
    })
    .catch(error => {
        showNotification('Erreur de communication: ' + error.message, 'danger');
    });
}

function reloadAsterisk() {
    fetch('/svi-admin/api/reload-asterisk.php', {
        method: 'POST'
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showNotification('Asterisk rechargé avec succès!', 'success');
        } else {
            showNotification('Erreur lors du rechargement: ' + data.error, 'danger');
        }
    })
    .catch(error => {
        showNotification('Erreur de communication: ' + error.message, 'danger');
    });
}

function loadFlow() {
    fetch('/svi-admin/api/load-flow-config.php')
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            clearFlow(false); // Effacer sans confirmation
            
            // Charger les nœuds
            if (data.data.nodes) {
                data.data.nodes.forEach(nodeData => {
                    nodes.push(nodeData);
                    renderNode(nodeData);
                });
                
                // Recalculer le compteur de nœuds
                nodeCounter = Math.max(...nodes.map(n => parseInt(n.id.split('_')[1]))) || 0;
            }
            
            // Charger les connexions
            if (data.data.connections) {
                connections = data.data.connections;
                setTimeout(() => {
                    updateConnections();
                }, 100);
            }
            
            showNotification('Flux chargé avec succès!', 'success');
        } else {
            showNotification('Aucun flux sauvegardé trouvé', 'warning');
        }
    })
    .catch(error => {
        showNotification('Erreur lors du chargement: ' + error.message, 'danger');
    });
}

function clearFlow(confirm = true) {
    if (!confirm || window.confirm('Êtes-vous sûr de vouloir effacer tout le flux ?')) {
        nodes = [];
        connections = [];
        document.getElementById('nodes-layer').innerHTML = '';
        document.getElementById('connections-svg').innerHTML = `
            <defs>
                <marker id="arrowhead" markerWidth="10" markerHeight="7" 
                        refX="9" refY="3.5" orient="auto">
                    <polygon points="0 0, 10 3.5, 0 7" fill="#007bff" />
                </marker>
            </defs>
        `;
        if (confirm) {
            showNotification('Flux effacé', 'info');
        }
    }
}
