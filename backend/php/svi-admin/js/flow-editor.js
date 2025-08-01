// Éditeur de flux SVI avec Konva.js
class FlowEditor {
    constructor() {
        this.stage = null;
        this.layer = null;
        this.selectedNode = null;
        this.connectionMode = false;
        this.connectionStart = null;
        this.connectionDrag = {
            isActive: false,
            fromNodeId: null,
            fromPoint: null,
            previewLine: null
        };
        this.nodes = new Map();
        this.connections = new Map();
        this.nodeCounter = 0;
        this.scale = 1;
        this.debugMode = true; // Activer le mode debug pour voir les zones
        
        // NOUVEAU: Système de sélection séquentielle pour connexions (plus fiable)
        this.selectedOutputNode = null; // Nœud de sortie sélectionné pour connexion
        
        // Système de prévisualisation de connexion
        this.previewLine = null;
        this.isCreatingConnection = false;
        this.connectionStartPoint = null;
        
        // Système de drag & drop pour connexions
        this.isDraggingConnection = false;
        this.dragStartNode = null;
        this.dragStartPoint = null;
        
        // Système d'infobulles
        this.tooltip = null;
        this.createTooltip();
        
        this.init();
    }

    init() {
        this.setupCanvas();
        this.setupEventListeners();
        this.setupDragAndDrop();
    }

    setupCanvas() {
        const container = document.getElementById('canvas-container');
        
        // Attendre que le container soit bien dimensionné
        setTimeout(() => {
            const containerRect = container.getBoundingClientRect();
            console.log('📐 Container rect:', containerRect);
            
            // S'assurer que les dimensions sont valides
            const width = Math.max(containerRect.width, 800);
            const height = Math.max(containerRect.height, 600);
            
            console.log('🎨 Creating stage with dimensions:', width, 'x', height);
            
            this.stage = new Konva.Stage({
                container: 'canvas-container',
                width: width,
                height: height,
                draggable: true
            });

            this.layer = new Konva.Layer();
            this.stage.add(this.layer);

            // Gestion du redimensionnement
            window.addEventListener('resize', () => {
                const newRect = container.getBoundingClientRect();
                const newWidth = Math.max(newRect.width, 800);
                const newHeight = Math.max(newRect.height, 600);
                this.stage.width(newWidth);
                this.stage.height(newHeight);
            });

            // Gestion des clics sur le canvas vide
            this.stage.on('click', (e) => {
                if (e.target === this.stage) {
                    this.deselectAll();
                    // Arrêter la prévisualisation si on clique dans le vide
                    if (this.isCreatingConnection) {
                        this.stopConnectionPreview();
                        this.clearOutputSelection();
                        this.showNotification('❌ Création de connexion annulée', 'info');
                    }
                }
            });
            
            // Gestion du mouvement de souris pour la prévisualisation de connexion
            this.stage.on('mousemove', (e) => {
                if (this.isCreatingConnection && !this.isDraggingConnection) {
                    // Mode clic simple : mise à jour de la prévisualisation
                    const mousePos = this.stage.getPointerPosition();
                    if (mousePos) {
                        this.updateConnectionPreview(mousePos);
                    }
                }
            });
            
            console.log('✅ Canvas setup complete');
        }, 100); // Petit délai pour s'assurer que le DOM est prêt
    }

    setupEventListeners() {
        // Boutons de la toolbar
        document.getElementById('zoomIn').addEventListener('click', () => this.zoom(1.2));
        document.getElementById('zoomOut').addEventListener('click', () => this.zoom(0.8));
        document.getElementById('resetZoom').addEventListener('click', () => this.resetZoom());
        document.getElementById('clearCanvas').addEventListener('click', () => this.clearCanvas());
        document.getElementById('cancelSelection').addEventListener('click', () => this.clearOutputSelection());
        document.getElementById('toggleDebug').addEventListener('click', () => this.toggleDebugMode());
        document.getElementById('toggleDarkMode').addEventListener('click', () => this.toggleDarkMode());
        
        // Boutons de génération
        document.getElementById('saveFlow').addEventListener('click', () => this.saveFlow());
        document.getElementById('generateAsterisk').addEventListener('click', () => this.generateAsterisk());
        document.getElementById('deployFlow').addEventListener('click', () => this.deployFlow());
    }

    setupDragAndDrop() {
        console.log('🔧 Setting up drag and drop...');
        const toolItems = document.querySelectorAll('.tool-item');
        console.log('📋 Found', toolItems.length, 'tool items');
        
        let draggedType = null;
        let isDragging = false;
        let currentGhost = null;
        const editor = this; // Stocker la référence pour les callbacks
        
        toolItems.forEach((item, index) => {
            console.log(`🔗 Setting up item ${index}:`, item.dataset.type);
            // Désactiver le drag HTML5 par défaut
            item.draggable = false;
            
            item.addEventListener('mousedown', (e) => {
                console.log('🖱️ MOUSEDOWN on:', item.dataset.type);
                draggedType = item.dataset.type;
                isDragging = true;
                
                // Créer un élément fantôme pour le drag visuel
                currentGhost = item.cloneNode(true);
                currentGhost.style.position = 'fixed';
                currentGhost.style.pointerEvents = 'none';
                currentGhost.style.opacity = '0.7';
                currentGhost.style.zIndex = '9999';
                currentGhost.style.transform = 'rotate(5deg) scale(0.9)';
                currentGhost.id = 'drag-ghost';
                document.body.appendChild(currentGhost);
                console.log('👻 Ghost element created');
                
                e.preventDefault();
            });
        });

        // Suivre la souris globalement
        document.addEventListener('mousemove', (e) => {
            if (isDragging && currentGhost) {
                currentGhost.style.left = (e.clientX + 10) + 'px';
                currentGhost.style.top = (e.clientY + 10) + 'px';
            }
        });

        const canvasContainer = document.getElementById('canvas-container');
        console.log('🎨 Canvas container found:', !!canvasContainer);
        
        // Nettoyage global sur mouseup
        document.addEventListener('mouseup', (e) => {
            if (isDragging) {
                console.log('🎯 Global MOUSEUP - checking if over canvas');
                
                const rect = canvasContainer.getBoundingClientRect();
                console.log('🎨 Canvas bounds (detailed):', {
                    x: rect.x,
                    y: rect.y,
                    width: rect.width,
                    height: rect.height,
                    top: rect.top,
                    bottom: rect.bottom,
                    left: rect.left,
                    right: rect.right
                });
                
                const isOverCanvas = e.clientX >= rect.left && 
                                   e.clientX <= rect.right && 
                                   e.clientY >= rect.top && 
                                   e.clientY <= rect.bottom;
                
                console.log('📍 Mouse position:', e.clientX, e.clientY);
                console.log('✅ Is over canvas:', isOverCanvas);
                
                if (isOverCanvas && draggedType) {
                    console.log('✅ Processing drop on canvas');
                    
                    const x = e.clientX - rect.left;
                    const y = e.clientY - rect.top;
                    
                    console.log('📍 Raw position:', x, y);
                    
                    // Convertir en coordonnées du stage
                    const stage = editor.stage;
                    let stagePos;
                    if (stage && stage.getRelativePointerPosition) {
                        stagePos = stage.getRelativePointerPosition() || { x: x, y: y };
                    } else {
                        stagePos = { x: x, y: y };
                    }
                    
                    console.log('🎯 Creating node:', draggedType, 'at position:', stagePos);
                    editor.createNode(draggedType, stagePos.x, stagePos.y);
                } else {
                    console.log('❌ Drop outside canvas or no drag type');
                    console.log('   - Mouse X in range?', e.clientX >= rect.left && e.clientX <= rect.right, '(', e.clientX, 'between', rect.left, '-', rect.right, ')');
                    console.log('   - Mouse Y in range?', e.clientY >= rect.top && e.clientY <= rect.bottom, '(', e.clientY, 'between', rect.top, '-', rect.bottom, ')');
                    console.log('   - Has drag type?', !!draggedType);
                }
                
                // Nettoyage
                console.log('🧹 Cleaning up drag operation');
                if (currentGhost) {
                    document.body.removeChild(currentGhost);
                    currentGhost = null;
                }
                isDragging = false;
                draggedType = null;
            }
        });
        
        // Empêcher la sélection de texte pendant le drag
        canvasContainer.addEventListener('selectstart', (e) => {
            if (isDragging) {
                e.preventDefault();
            }
        });
        
        console.log('✅ Drag and drop setup complete');
    }

    startSimpleConnection(fromNodeId, fromPoint) {
        console.log('🚀 Starting SIMPLE connection from node:', fromNodeId);
        
        // Réinitialiser tout état précédent
        this.cleanupConnectionDrag();
        
        // Configurer le nouvel état de connexion
        this.connectionDrag = {
            isActive: true,
            fromNodeId: fromNodeId,
            fromPoint: fromPoint,
            previewLine: null
        };
        
        // Mettre en évidence le point de départ
        fromPoint.fill('#e74c3c');
        fromPoint.radius(12);
        fromPoint.stroke('#ffffff');
        fromPoint.strokeWidth(3);
        
        // Créer une ligne de prévisualisation qui suit la souris
        const fromPos = fromPoint.getAbsolutePosition();
        this.connectionDrag.previewLine = new Konva.Line({
            points: [fromPos.x, fromPos.y, fromPos.x, fromPos.y],
            stroke: '#667eea',
            strokeWidth: 3,
            dash: [8, 4],
            opacity: 0.8,
            lineCap: 'round'
        });
        
        this.layer.add(this.connectionDrag.previewLine);
        this.layer.draw();
        
        // Changer le curseur pour indiquer le mode connexion
        this.stage.container().style.cursor = 'crosshair';
        
        // Afficher les instructions
        this.showNotification('Cliquez sur un point d\'entrée VERT pour terminer la connexion', 'info');
        
        // Mettre en évidence toutes les zones d'entrée disponibles
        this.highlightInputZones(true);
        
        // Écouter les mouvements de souris pour la ligne de prévisualisation
        this.stage.on('mousemove.connectionPreview', (e) => {
            if (this.connectionDrag.isActive && this.connectionDrag.previewLine) {
                const pos = this.stage.getPointerPosition();
                const fromPos = this.connectionDrag.fromPoint.getAbsolutePosition();
                
                this.connectionDrag.previewLine.points([fromPos.x, fromPos.y, pos.x, pos.y]);
                this.layer.draw();
            }
        });
        
        // Annuler la connexion si on clique sur le fond du canvas (pas sur les nœuds)
        // SOLUTION: Retarder l'annulation pour laisser le temps aux zones de réagir
        this.stage.on('click.connectionCancel', (e) => {
            if (this.connectionDrag.isActive) {
                const targetName = e.target.name();
                console.log('🎯 Click detected during connection, target:', targetName, 'className:', e.target.className);
                
                // Retarder la vérification pour laisser le temps aux zones de réagir
                setTimeout(() => {
                    // Vérifier si la connexion est toujours active (pas annulée par une zone)
                    if (this.connectionDrag && this.connectionDrag.isActive) {
                        const currentTargetName = e.target.name();
                        
                        // Ne pas annuler si on clique sur une zone d'entrée, un nœud ou ses composants
                        if (currentTargetName === 'inputZone' || 
                            currentTargetName === 'outputZone' || 
                            e.target.parent?.name() === 'nodeGroup' ||
                            e.target.className === 'Rect' ||
                            e.target.className === 'Text' ||
                            e.target.className === 'Circle') {
                            console.log('🔄 Valid target detected after delay - keeping connection active');
                            return;
                        }
                        
                        console.log('❌ Clicking on background after delay - cancelling connection');
                        this.cancelSimpleConnection();
                    } else {
                        console.log('✅ Connection already handled by zone click');
                    }
                }, 50); // 50ms de délai pour laisser les zones réagir
            }
        });
    }

    finishSimpleConnection(toNodeId, toPoint) {
        console.log('🎯 Finishing SIMPLE connection on node:', toNodeId);
        
        if (this.connectionDrag.isActive && this.connectionDrag.fromNodeId) {
            console.log('✅ Creating connection from', this.connectionDrag.fromNodeId, 'to', toNodeId);
            
            // Vérifier qu'on ne connecte pas un nœud à lui-même
            if (this.connectionDrag.fromNodeId === toNodeId) {
                console.log('❌ Cannot connect node to itself');
                this.showNotification('Impossible de connecter un nœud à lui-même', 'error');
                this.cancelSimpleConnection();
                return;
            }
            
            // Créer la connexion
            this.createConnection(
                this.connectionDrag.fromNodeId,
                toNodeId,
                this.connectionDrag.fromPoint,
                toPoint
            );
            
            this.showNotification('✅ Connexion créée avec succès !', 'success');
        } else {
            console.log('❌ Cannot create connection - invalid state');
            this.showNotification('Erreur lors de la création de la connexion', 'error');
        }
        
        this.cleanupSimpleConnection();
    }

    cancelSimpleConnection() {
        console.log('❌ Cancelling SIMPLE connection');
        this.showNotification('Création de connexion annulée', 'warning');
        this.cleanupSimpleConnection();
    }

    cleanupSimpleConnection() {
        // Nettoyer la ligne de prévisualisation
        if (this.connectionDrag && this.connectionDrag.previewLine) {
            this.connectionDrag.previewLine.destroy();
            this.connectionDrag.previewLine = null;
        }
        
        // Remettre le point de départ à la normale
        if (this.connectionDrag && this.connectionDrag.fromPoint) {
            this.connectionDrag.fromPoint.fill('#dc3545');
            this.connectionDrag.fromPoint.radius(8);
            this.connectionDrag.fromPoint.stroke(null);
            this.connectionDrag.fromPoint.strokeWidth(0);
        }
        
        // Désactiver la mise en évidence des zones d'entrée
        this.highlightInputZones(false);
        
        // Réinitialiser l'état
        this.connectionDrag = {
            isActive: false,
            fromNodeId: null,
            fromPoint: null,
            previewLine: null
        };
        
        // Remettre le curseur normal
        this.stage.container().style.cursor = 'default';
        
        // Supprimer les événements temporaires
        this.stage.off('mousemove.connectionPreview');
        this.stage.off('click.connectionCancel');
        
        this.layer.draw();
    }

    highlightInputZones(highlight) {
        // Mettre en évidence ou désactiver toutes les zones d'entrée
        this.nodes.forEach((nodeData, nodeId) => {
            const inputZone = nodeData.inputZone;
            const inputPoint = nodeData.inputPoint;
            
            if (inputZone && inputPoint) {
                if (highlight) {
                    // Éviter de mettre en évidence le nœud source
                    if (nodeId !== this.connectionDrag.fromNodeId) {
                        inputPoint.fill('#27ae60');
                        inputPoint.radius(12);
                        inputPoint.stroke('#ffffff');
                        inputPoint.strokeWidth(2);
                        
                        // Faire briller la zone
                        if (this.debugMode) {
                            inputZone.fill('rgba(46, 204, 113, 0.3)');
                            inputZone.stroke('rgba(46, 204, 113, 0.8)');
                            inputZone.strokeWidth(3);
                        }
                    }
                } else {
                    // Remettre à la normale
                    inputPoint.fill('#28a745');
                    inputPoint.radius(8);
                    inputPoint.stroke(null);
                    inputPoint.strokeWidth(0);
                    
                    if (this.debugMode) {
                        inputZone.fill('rgba(46, 204, 113, 0.1)');
                        inputZone.stroke('rgba(46, 204, 113, 0.5)');
                        inputZone.strokeWidth(2);
                    }
                }
            }
        });
        
        this.layer.draw();
    }

    // Anciennes fonctions maintenues pour compatibilité (redirigent vers les nouvelles)
    startConnectionDrag(fromNodeId, fromPoint, event) {
        console.log('🔄 Redirecting old startConnectionDrag to new simple system');
        this.startSimpleConnection(fromNodeId, fromPoint);
    }

    endConnectionDrag(toNodeId, toPoint) {
        console.log('🔄 Redirecting old endConnectionDrag to new simple system');
        this.finishSimpleConnection(toNodeId, toPoint);
    }

    cancelConnectionDrag() {
        console.log('🔄 Redirecting old cancelConnectionDrag to new simple system');
        this.cancelSimpleConnection();
    }

    cleanupConnectionDrag() {
        console.log('🔄 Redirecting old cleanupConnectionDrag to new simple system');
        this.cleanupSimpleConnection();
    }

    createNode(type, x, y) {
        console.log('🎨 Creating node:', type, 'at position:', x, y);
        
        const nodeId = `node_${++this.nodeCounter}`;
        const nodeConfig = this.getNodeConfig(type);
        
        console.log('📋 Node config:', nodeConfig);
        
        // Créer le groupe pour le nœud
        const group = new Konva.Group({
            x: x,
            y: y,
            draggable: true,
            id: nodeId,
            name: 'nodeGroup'
        });

        // Empêcher le drag du groupe pendant la création de connexion
        group.on('dragstart', (e) => {
            console.log('🚫 Trying to drag group during connection mode?', this.connectionDrag?.isActive);
            if (this.connectionDrag && this.connectionDrag.isActive) {
                console.log('❌ Preventing drag - connection mode active');
                e.evt.preventDefault();
                e.evt.stopPropagation();
                return false;
            }
            console.log('✅ Group drag allowed');
        });

        // S'assurer que le drag s'arrête toujours proprement
        group.on('dragend', (e) => {
            console.log('🏁 Group drag ended for:', nodeId);
            // Force l'arrêt du drag au cas où
            group.draggable(true);
            this.stage.container().style.cursor = 'default';
        });

        // Gérer les clics sur le groupe pour éviter les conflits
        group.on('mousedown', (e) => {
            // Si on clique directement sur le groupe (pas sur les zones), s'assurer qu'aucune connexion n'est active
            if (e.target === group || e.target.parent === group) {
                if (this.connectionDrag && this.connectionDrag.isActive && 
                    e.target.name() !== 'inputZone' && e.target.name() !== 'outputZone') {
                    console.log('❌ Clicking on group during connection - cancelling connection');
                    this.cancelSimpleConnection();
                }
            }
        });

        // Rectangle principal
        const rect = new Konva.Rect({
            width: nodeConfig.width,
            height: nodeConfig.height,
            fill: nodeConfig.color,
            stroke: '#dee2e6',
            strokeWidth: 2,
            cornerRadius: 8,
            shadowColor: 'rgba(0,0,0,0.1)',
            shadowBlur: 4,
            shadowOffset: { x: 0, y: 2 }
        });

        // Icône
        const icon = new Konva.Text({
            x: 15,
            y: 15,
            text: nodeConfig.icon,
            fontSize: 16,
            fontFamily: 'Font Awesome 6 Free',
            fontStyle: 'bold',
            fill: 'white'
        });

        // Titre
        const title = new Konva.Text({
            x: 45,
            y: 18,
            text: nodeConfig.title,
            fontSize: 14,
            fontFamily: 'Arial',
            fontStyle: 'bold',
            fill: 'white',
            width: nodeConfig.width - 60
        });

        // Points de connexion avec zones plus grandes
        const inputPoint = new Konva.Circle({
            x: 0,
            y: nodeConfig.height / 2,
            radius: 8, // Plus grand pour être plus facile à cibler
            fill: '#28a745',
            stroke: 'white',
            strokeWidth: 2,
            visible: type !== 'start'
        });

        const outputPoint = new Konva.Circle({
            x: nodeConfig.width,
            y: nodeConfig.height / 2,
            radius: 8, // Plus grand pour être plus facile à cibler
            fill: '#dc3545',
            stroke: 'white',
            strokeWidth: 2,
            visible: type !== 'hangup'
        });

        // Zones invisibles étendues pour capturer plus facilement les événements
        const inputZone = new Konva.Circle({
            x: 0,
            y: nodeConfig.height / 2,
            radius: 25, // Zone étendue plus large pour faciliter le ciblage
            fill: 'transparent',
            visible: type !== 'start',
            listening: true,
            name: 'inputZone'
        });

        const outputZone = new Konva.Circle({
            x: nodeConfig.width,
            y: nodeConfig.height / 2,
            radius: 25, // Zone étendue plus large pour faciliter le ciblage
            fill: 'transparent',
            visible: type !== 'hangup',
            listening: true,
            name: 'outputZone'
        });

        // Mode debug : rendre les zones visibles temporairement
        if (this.debugMode) {
            inputZone.stroke('rgba(46, 204, 113, 0.5)');
            inputZone.strokeWidth(2);
            inputZone.fill('rgba(46, 204, 113, 0.1)');
            outputZone.stroke('rgba(220, 53, 69, 0.5)');
            outputZone.strokeWidth(2);
            outputZone.fill('rgba(220, 53, 69, 0.1)');
        }

        // Ajouter les éléments au groupe dans le bon ordre (zones en dernier pour être au-dessus)
        group.add(rect, icon, title, inputPoint, outputPoint);
        
        // Ajouter les zones en dernier pour qu'elles soient au-dessus et captent les événements
        group.add(inputZone, outputZone);

            // ÉVÉNEMENTS SUR LES ZONES DE CONNEXION (PRIORITÉ MAXIMUM)
            // NOUVEAU SYSTÈME: Sélection séquentielle (plus fiable que le drag temporaire)
            if (type !== 'hangup') {
                outputZone.on('click', (e) => {
                    e.cancelBubble = true;
                    e.evt && e.evt.stopPropagation && e.evt.stopPropagation();
                    console.log('🔴 CLIC NŒUD DE SORTIE:', nodeId);
                    
                    // Vérifier si ce nœud a déjà une connexion sortante
                    const existingConnection = this.findConnectionFromNode(nodeId);
                    
                    if (existingConnection) {
                        // Supprimer la connexion existante
                        console.log('🗑️ Suppression connexion existante:', existingConnection);
                        this.removeConnection(existingConnection);
                        this.showNotification('🗑️ Connexion supprimée - Sélectionnez maintenant une zone VERTE pour créer une nouvelle connexion', 'success');
                        
                        // IMPORTANT: Après suppression, sélectionner automatiquement ce nœud pour créer une nouvelle connexion
                        // Désélectionner l'ancien nœud s'il y en a un autre
                        if (this.selectedOutputNode && this.selectedOutputNode !== nodeId) {
                            this.resetOutputNodeVisual(this.selectedOutputNode);
                        }
                        
                        // Démarrer la prévisualisation de connexion
                        this.startConnectionPreview(nodeId, outputPoint);
                        this.showNotification('🎯 Prévisualisation activée - Cliquez sur une zone VERTE', 'info');
                        return;
                    }
                    
                    // Si pas de connexion existante, gérer la sélection pour nouvelle connexion
                    if (this.selectedOutputNode === nodeId) {
                        // Désélectionner si on re-clique sur le même nœud (sans connexion existante)
                        this.clearOutputSelection();
                        this.stopConnectionPreview(); // Arrêter la prévisualisation
                        this.showNotification('❌ Sélection annulée', 'info');
                    } else {
                        // Désélectionner l'ancien nœud s'il y en a un
                        if (this.selectedOutputNode) {
                            this.resetOutputNodeVisual(this.selectedOutputNode);
                            this.stopConnectionPreview(); // Arrêter l'ancienne prévisualisation
                        }
                        
                        // Démarrer la nouvelle prévisualisation de connexion
                        this.startConnectionPreview(nodeId, outputPoint);
                        this.showNotification('✅ Nœud de sortie sélectionné. Cliquez maintenant sur une zone VERTE.', 'success');
                    }
                });

                // NOUVEAU: Système de drag & drop pour créer des connexions
                outputZone.on('mousedown', (e) => {
                    e.cancelBubble = true;
                    e.evt && e.evt.stopPropagation && e.evt.stopPropagation();
                    
                    // Démarrer le drag de connexion
                    this.startConnectionDrag(nodeId, outputPoint, e);
                });
                
                outputZone.on('mouseup', (e) => {
                    e.cancelBubble = true;
                    e.evt && e.evt.stopPropagation && e.evt.stopPropagation();
                    
                    // Arrêter le drag de connexion si c'était en cours
                    if (this.isDraggingConnection) {
                        this.stopConnectionDrag();
                    }
                });
            }

        if (type !== 'start') {
            inputZone.on('click', (e) => {
                e.cancelBubble = true;
                e.evt && e.evt.stopPropagation && e.evt.stopPropagation();
                console.log('🟢 CLIC ZONE VERTE pour nœud:', nodeId);
                
                // Vérifier si un nœud de sortie est sélectionné
                if (this.selectedOutputNode) {
                    console.log('✅ Nœud de sortie sélectionné:', this.selectedOutputNode);
                    
                    if (this.selectedOutputNode === nodeId) {
                        console.log('❌ Cannot connect node to itself');
                        this.showNotification('❌ Impossible de connecter un nœud à lui-même', 'error');
                    } else {
                        console.log('� CRÉATION CONNEXION:', this.selectedOutputNode, '→', nodeId);
                        
                        // Créer la connexion
                        const fromNode = this.nodes.get(this.selectedOutputNode);
                        const toNode = this.nodes.get(nodeId);
                        
                        if (fromNode && toNode) {
                            this.createConnection(
                                this.selectedOutputNode,
                                nodeId,
                                fromNode.outputPoint,
                                toNode.inputPoint
                            );
                            
                            this.showNotification('✅ Connexion créée avec succès !', 'success');
                            
                            // Nettoyer la sélection et arrêter la prévisualisation
                            this.resetOutputNodeVisual(this.selectedOutputNode);
                            this.stopConnectionPreview();
                            this.selectedOutputNode = null;
                        } else {
                            console.log('❌ Nœuds non trouvés pour la connexion');
                            this.showNotification('❌ Erreur lors de la création de la connexion', 'error');
                        }
                    }
                } else {
                    console.log('❌ Aucun nœud de sortie sélectionné');
                    this.showNotification('❌ Sélectionnez d\'abord un nœud de sortie (zone rouge)', 'warning');
                }
            });

            // NOUVEAU: Support du drag & drop sur les zones d'entrée
            inputZone.on('mouseup', (e) => {
                e.cancelBubble = true;
                e.evt && e.evt.stopPropagation && e.evt.stopPropagation();
                
                // Si on relâche la souris sur une zone d'entrée pendant un drag de connexion
                if (this.isDraggingConnection && this.dragStartNode) {
                    console.log('🎯 DRAG & DROP: Connexion de', this.dragStartNode, 'vers', nodeId);
                    
                    if (this.dragStartNode === nodeId) {
                        this.showNotification('❌ Impossible de connecter un nœud à lui-même', 'error');
                    } else {
                        // Créer la connexion via drag & drop
                        const fromNode = this.nodes.get(this.dragStartNode);
                        const toNode = this.nodes.get(nodeId);
                        
                        if (fromNode && toNode) {
                            this.createConnection(
                                this.dragStartNode,
                                nodeId,
                                fromNode.outputPoint,
                                toNode.inputPoint
                            );
                            
                            this.showNotification('✅ Connexion créée par drag & drop !', 'success');
                        }
                    }
                    
                    // Arrêter le drag
                    this.stopConnectionDrag();
                }
            });

            inputZone.on('mousedown', (e) => {
                e.cancelBubble = true;
                e.evt && e.evt.stopPropagation && e.evt.stopPropagation();
            });
        }

        // Événements sur le groupe principal (priorité basse)
        group.on('click', (e) => {
            // Vérifier que le clic n'a pas été intercepté par les zones de connexion
            const targetName = e.target.name();
            if (targetName === 'inputZone' || targetName === 'outputZone') {
                return; // Ignorer si c'est déjà géré par les zones
            }
            console.log('👆 Click on NODE group for:', nodeId);
            this.selectNode(nodeId);
        });

        group.on('dblclick', () => {
            this.editNode(nodeId);
        });

        // AJOUT: Événements d'infobulle sur le groupe principal
        group.on('mouseenter', (e) => {
            // Ne pas afficher l'infobulle si on survole les zones de connexion
            const targetName = e.target.name();
            if (targetName === 'inputZone' || targetName === 'outputZone') {
                return;
            }
            
            const nodeData = this.nodes.get(nodeId);
            if (nodeData) {
                const groupPos = group.getAbsolutePosition();
                const stagePos = this.stage.getAbsolutePosition();
                this.showTooltip(nodeData, 
                    stagePos.x + groupPos.x + nodeConfig.width / 2, 
                    stagePos.y + groupPos.y - 10
                );
            }
        });

        group.on('mouseleave', (e) => {
            // Masquer l'infobulle seulement si on quitte vraiment le groupe
            const targetName = e.target.name();
            if (targetName !== 'inputZone' && targetName !== 'outputZone') {
                this.hideTooltip();
            }
        });

        // Connexions avec système CLICK simple (plus de drag compliqué !)
        // ÉVÉNEMENTS HOVER POUR FEEDBACK VISUEL (zones de sortie)
        if (type !== 'hangup') {
            outputZone.on('mouseenter', () => {
                if (!this.connectionDrag || !this.connectionDrag.isActive) {
                    outputPoint.fill('#e74c3c');
                    outputPoint.radius(10);
                    this.layer.draw();
                    this.stage.container().style.cursor = 'pointer';
                    this.showNotification('Cliquez pour commencer une connexion', 'info');
                }
            });

            outputZone.on('mouseleave', () => {
                if (!this.connectionDrag || !this.connectionDrag.isActive) {
                    outputPoint.fill('#dc3545');
                    outputPoint.radius(8);
                    this.layer.draw();
                    this.stage.container().style.cursor = 'default';
                }
            });
        }

        // ÉVÉNEMENTS HOVER POUR FEEDBACK VISUEL (zones d'entrée)
        if (type !== 'start') {
            inputZone.on('mouseenter', () => {
                if (this.connectionDrag && this.connectionDrag.isActive) {
                    inputPoint.fill('#00ff00'); // Vert très visible
                    inputPoint.radius(15);
                    inputPoint.stroke('#ffffff');
                    inputPoint.strokeWidth(3);
                    this.layer.draw();
                    this.stage.container().style.cursor = 'pointer';
                    this.showNotification('Cliquez ici pour terminer la connexion !', 'success');
                } else {
                    inputPoint.fill('#2ecc71');
                    inputPoint.radius(9);
                    this.layer.draw();
                    this.stage.container().style.cursor = 'pointer';
                    this.showNotification('Zone d\'entrée disponible', 'info');
                }
            });

            inputZone.on('mouseleave', () => {
                if (this.connectionDrag && this.connectionDrag.isActive) {
                    // En mode connexion, remettre en évidence mais pas normal
                    inputPoint.fill('#27ae60');
                    inputPoint.radius(12);
                    inputPoint.stroke('#ffffff');
                    inputPoint.strokeWidth(2);
                } else {
                    inputPoint.fill('#28a745');
                    inputPoint.radius(8);
                    inputPoint.stroke(null);
                    inputPoint.strokeWidth(0);
                }
                this.layer.draw();
                this.stage.container().style.cursor = 'default';
            });
        }

        // Mettre à jour les connexions lors du déplacement
        group.on('dragmove', () => {
            this.updateConnections(nodeId);
        });

        this.layer.add(group);
        this.layer.draw();

        // Stocker les données du nœud
        this.nodes.set(nodeId, {
            type: type,
            group: group,
            config: nodeConfig,
            properties: this.getDefaultProperties(type),
            inputPoint: inputPoint,
            outputPoint: outputPoint,
            inputZone: inputZone,
            outputZone: outputZone
        });

        // Sélectionner le nouveau nœud
        this.selectNode(nodeId);
    }

    getNodeConfig(type) {
        const configs = {
            start: {
                title: 'Début',
                icon: '\uf04b', // fas fa-play
                color: '#28a745',
                width: 120,
                height: 50
            },
            say: {
                title: 'Message',
                icon: '\uf075', // fas fa-comment
                color: '#17a2b8',
                width: 140,
                height: 60
            },
            menu: {
                title: 'Menu DTMF',
                icon: '\uf03a', // fas fa-list
                color: '#007bff',
                width: 140,
                height: 60
            },
            input: {
                title: 'Saisie',
                icon: '\uf11c', // fas fa-keyboard
                color: '#fd7e14',
                width: 120,
                height: 60
            },
            condition: {
                title: 'Condition',
                icon: '\uf059', // fas fa-question
                color: '#ffc107',
                width: 130,
                height: 60
            },
            transfer: {
                title: 'Transfert',
                icon: '\uf362', // fas fa-phone-forwarded
                color: '#6f42c1',
                width: 130,
                height: 60
            },
            hangup: {
                title: 'Raccrocher',
                icon: '\uf3dd', // fas fa-phone-slash
                color: '#dc3545',
                width: 130,
                height: 50
            }
        };
        return configs[type] || configs.say;
    }

    getDefaultProperties(type) {
        const defaults = {
            start: {
                name: 'Début du flux',
                context: 'from-internal'
            },
            say: {
                name: 'Message vocal',
                message: 'Bienvenue dans notre système',
                voice: 'fr',
                audioFile: ''
            },
            menu: {
                name: 'Menu principal',
                message: 'Choisissez une option',
                options: [
                    { key: '1', label: 'Option 1' },
                    { key: '2', label: 'Option 2' }
                ],
                timeout: 5,
                retries: 3
            },
            input: {
                name: 'Saisie utilisateur',
                message: 'Veuillez saisir votre choix',
                minDigits: 1,
                maxDigits: 10,
                timeout: 5,
                variable: 'user_input'
            },
            condition: {
                name: 'Test conditionnel',
                variable: 'user_input',
                operator: 'equals',
                value: '1'
            },
            transfer: {
                name: 'Transfert d\'appel',
                destination: '100',
                context: 'from-internal',
                timeout: 30
            },
            hangup: {
                name: 'Fin d\'appel',
                cause: 'normal'
            }
        };
        return defaults[type] || {};
    }

    selectNode(nodeId) {
        // Désélectionner le nœud précédent
        if (this.selectedNode) {
            const prevNode = this.nodes.get(this.selectedNode);
            if (prevNode) {
                prevNode.group.children[0].stroke('#dee2e6');
                prevNode.group.children[0].strokeWidth(2);
            }
        }

        // Sélectionner le nouveau nœud
        this.selectedNode = nodeId;
        const node = this.nodes.get(nodeId);
        if (node) {
            node.group.children[0].stroke('#667eea');
            node.group.children[0].strokeWidth(3);
            this.showProperties(nodeId);
        }
        
        this.layer.draw();
    }

    editNode(nodeId) {
        // Pour l'instant, le double-clic fait la même chose que la sélection
        // mais affiche un focus sur le panneau des propriétés
        this.selectNode(nodeId);
        
        // Faire défiler vers le panneau des propriétés et le mettre en évidence
        const propertiesPanel = document.querySelector('.properties-panel');
        if (propertiesPanel) {
            propertiesPanel.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
            
            // Animation de mise en évidence
            propertiesPanel.style.animation = 'highlight 1s ease-in-out';
            setTimeout(() => {
                propertiesPanel.style.animation = '';
            }, 1000);
        }
        
        // Focus sur le premier input du formulaire s'il existe
        const firstInput = document.querySelector('#properties-content input, #properties-content textarea, #properties-content select');
        if (firstInput) {
            setTimeout(() => firstInput.focus(), 100);
        }
    }

    deselectAll() {
        if (this.selectedNode) {
            const node = this.nodes.get(this.selectedNode);
            if (node) {
                node.group.children[0].stroke('#dee2e6');
                node.group.children[0].strokeWidth(2);
            }
            this.selectedNode = null;
            this.hideProperties();
            this.layer.draw();
        }
    }

    showProperties(nodeId) {
        const node = this.nodes.get(nodeId);
        if (!node) return;

        const content = document.getElementById('properties-content');
        content.innerHTML = this.generatePropertiesForm(node);

        // Ajouter les événements aux inputs
        const inputs = content.querySelectorAll('input, textarea, select');
        inputs.forEach(input => {
            input.addEventListener('change', () => {
                this.updateNodeProperty(nodeId, input.name, input.value);
            });
        });
    }

    generatePropertiesForm(node) {
        let html = `<h4>${node.config.title}</h4>`;
        
        for (const [key, value] of Object.entries(node.properties)) {
            html += `<div class="property-group">`;
            html += `<label class="property-label">${this.getPropertyLabel(key)}</label>`;
            
            if (key === 'message' || key === 'audioFile') {
                html += `<textarea class="property-input property-textarea" name="${key}">${value}</textarea>`;
            } else if (key === 'options' && Array.isArray(value)) {
                html += `<div class="options-container">`;
                value.forEach((option, index) => {
                    html += `<div class="option-item">
                        <input type="text" placeholder="Touche" value="${option.key}" data-option="${index}" data-field="key" class="property-input" style="width: 30%; margin-right: 10px;">
                        <input type="text" placeholder="Label" value="${option.label}" data-option="${index}" data-field="label" class="property-input" style="width: 65%;">
                    </div>`;
                });
                html += `<button type="button" class="btn btn-sm btn-secondary" onclick="flowEditor.addMenuOption('${node.group.id()}')">Ajouter option</button>`;
                html += `</div>`;
            } else if (key === 'operator') {
                html += `<select class="property-input property-select" name="${key}">
                    <option value="equals" ${value === 'equals' ? 'selected' : ''}>Égal à</option>
                    <option value="not_equals" ${value === 'not_equals' ? 'selected' : ''}>Différent de</option>
                    <option value="greater" ${value === 'greater' ? 'selected' : ''}>Supérieur à</option>
                    <option value="less" ${value === 'less' ? 'selected' : ''}>Inférieur à</option>
                </select>`;
            } else if (key === 'voice') {
                html += `<select class="property-input property-select" name="${key}">
                    <option value="fr" ${value === 'fr' ? 'selected' : ''}>Français</option>
                    <option value="en" ${value === 'en' ? 'selected' : ''}>Anglais</option>
                    <option value="es" ${value === 'es' ? 'selected' : ''}>Espagnol</option>
                </select>`;
            } else {
                html += `<input type="text" class="property-input" name="${key}" value="${value}">`;
            }
            
            html += `</div>`;
        }
        
        return html;
    }

    getPropertyLabel(key) {
        const labels = {
            name: 'Nom',
            message: 'Message',
            voice: 'Voix',
            audioFile: 'Fichier audio',
            options: 'Options du menu',
            timeout: 'Délai d\'attente (s)',
            retries: 'Nombre d\'essais',
            minDigits: 'Minimum de chiffres',
            maxDigits: 'Maximum de chiffres',
            variable: 'Variable',
            operator: 'Opérateur',
            value: 'Valeur',
            destination: 'Destination',
            context: 'Contexte',
            cause: 'Cause'
        };
        return labels[key] || key;
    }

    updateNodeProperty(nodeId, property, value) {
        const node = this.nodes.get(nodeId);
        if (node) {
            node.properties[property] = value;
            
            // Mettre à jour le titre si c'est la propriété name
            if (property === 'name') {
                node.group.children[2].text(value.substring(0, 15) + (value.length > 15 ? '...' : ''));
                this.layer.draw();
            }
        }
    }

    hideProperties() {
        const content = document.getElementById('properties-content');
        content.innerHTML = `
            <div class="empty-state">
                <i class="fas fa-mouse-pointer"></i>
                <h4>Aucun élément sélectionné</h4>
                <p>Cliquez sur un élément du diagramme pour afficher ses propriétés.</p>
            </div>
        `;
    }

    createConnection(fromNodeId, toNodeId, fromPoint, toPoint) {
        console.log('🔗 Creating connection:', fromNodeId, '->', toNodeId);
        
        if (fromNodeId === toNodeId) {
            console.log('❌ Cannot connect node to itself');
            this.showNotification('Impossible de connecter un nœud à lui-même', 'error');
            return;
        }
        
        const connectionId = `${fromNodeId}_to_${toNodeId}`;
        console.log('🆔 Connection ID:', connectionId);
        
        // Supprimer une connexion existante
        if (this.connections.has(connectionId)) {
            console.log('🗑️ Removing existing connection');
            const existingConnection = this.connections.get(connectionId);
            existingConnection.line.destroy();
            existingConnection.arrow.destroy();
            this.connections.delete(connectionId);
        }

        const fromNode = this.nodes.get(fromNodeId);
        const toNode = this.nodes.get(toNodeId);
        
        if (!fromNode || !toNode) {
            console.log('❌ Nodes not found:', fromNode, toNode);
            return;
        }
        
        const fromPos = fromPoint.getAbsolutePosition();
        const toPos = toPoint.getAbsolutePosition();
        
        console.log('📍 Connection positions:', fromPos, '->', toPos);

        // Créer la ligne
        const line = new Konva.Line({
            points: [fromPos.x, fromPos.y, toPos.x, toPos.y],
            stroke: '#667eea',
            strokeWidth: 3,
            lineCap: 'round',
            shadowColor: 'rgba(0,0,0,0.2)',
            shadowBlur: 2,
            shadowOffset: { x: 1, y: 1 }
        });

        // Créer la flèche
        const arrow = new Konva.RegularPolygon({
            x: toPos.x - 10,
            y: toPos.y,
            sides: 3,
            radius: 8,
            fill: '#667eea',
            rotation: 90,
            shadowColor: 'rgba(0,0,0,0.2)',
            shadowBlur: 2,
            shadowOffset: { x: 1, y: 1 }
        });

        // Ajouter à la couche (en arrière-plan)
        this.layer.add(line);
        this.layer.add(arrow);
        
        // Mettre les nœuds au premier plan
        fromNode.group.moveToTop();
        toNode.group.moveToTop();
        
        this.layer.draw();

        // Stocker la connexion
        this.connections.set(connectionId, {
            fromNodeId,
            toNodeId,
            line,
            arrow,
            properties: {}
        });
        
        console.log('✅ Connection created successfully');
    }

    updateConnections(nodeId) {
        // Mettre à jour toutes les connexions liées à ce nœud
        this.connections.forEach((connection, connectionId) => {
            if (connection.fromNodeId === nodeId || connection.toNodeId === nodeId) {
                const fromNode = this.nodes.get(connection.fromNodeId);
                const toNode = this.nodes.get(connection.toNodeId);
                
                if (fromNode && toNode) {
                    const fromPos = fromNode.outputPoint.getAbsolutePosition();
                    const toPos = toNode.inputPoint.getAbsolutePosition();
                    
                    // Mettre à jour la ligne
                    connection.line.points([fromPos.x, fromPos.y, toPos.x, toPos.y]);
                    
                    // Mettre à jour la flèche
                    connection.arrow.x(toPos.x - 10);
                    connection.arrow.y(toPos.y);
                }
            }
        });
        
        this.layer.draw();
    }

    // === MÉTHODES UTILITAIRES POUR GESTION DES CONNEXIONS ===
    findConnectionFromNode(nodeId) {
        // Chercher une connexion sortante depuis ce nœud
        for (const [connectionId, connection] of this.connections.entries()) {
            if (connection.fromNodeId === nodeId) {
                return connectionId;
            }
        }
        return null;
    }

    removeConnection(connectionId) {
        const connection = this.connections.get(connectionId);
        if (connection) {
            // Détruire les éléments visuels
            connection.line.destroy();
            connection.arrow.destroy();
            
            // Supprimer de la Map
            this.connections.delete(connectionId);
            
            // Redessiner la couche
            this.layer.draw();
            
            console.log('✅ Connexion supprimée:', connectionId);
            return true;
        }
        return false;
    }

    zoom(factor) {
        this.scale *= factor;
        this.stage.scale({ x: this.scale, y: this.scale });
        this.stage.batchDraw();
    }

    resetZoom() {
        this.scale = 1;
        this.stage.scale({ x: 1, y: 1 });
        this.stage.position({ x: 0, y: 0 });
        this.stage.batchDraw();
    }

    clearCanvas() {
        if (confirm('Êtes-vous sûr de vouloir effacer tout le diagramme ?')) {
            this.layer.destroyChildren();
            this.layer.draw();
            this.nodes.clear();
            this.connections.clear();
            this.selectedNode = null;
            this.hideProperties();
        }
    }

    saveFlow() {
        const flowData = {
            nodes: Array.from(this.nodes.entries()).map(([id, node]) => ({
                id,
                type: node.type,
                x: node.group.x(),
                y: node.group.y(),
                properties: node.properties
            })),
            connections: Array.from(this.connections.entries()).map(([id, conn]) => ({
                id,
                fromNodeId: conn.fromNodeId,
                toNodeId: conn.toNodeId,
                properties: conn.properties
            }))
        };

        // Sauvegarder via API
        this.saveFlowToServer(flowData);
    }

    async saveFlowToServer(flowData) {
        try {
            const response = await fetch('api/flow-management.php', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    action: 'save',
                    flowData: flowData
                })
            });

            const result = await response.json();
            if (result.success) {
                this.showNotification('Flux sauvegardé avec succès', 'success');
            } else {
                this.showNotification('Erreur lors de la sauvegarde: ' + result.error, 'error');
            }
        } catch (error) {
            this.showNotification('Erreur de connexion: ' + error.message, 'error');
        }
    }

    async generateAsterisk() {
        const flowData = {
            nodes: Array.from(this.nodes.entries()).map(([id, node]) => ({
                id,
                type: node.type,
                properties: node.properties
            })),
            connections: Array.from(this.connections.entries()).map(([id, conn]) => ({
                id,
                fromNodeId: conn.fromNodeId,
                toNodeId: conn.toNodeId,
                properties: conn.properties
            }))
        };

        try {
            const response = await fetch('api/flow-management.php', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    action: 'generate',
                    flowData: flowData
                })
            });

            const result = await response.json();
            if (result.success) {
                this.showGeneratedCode(result.asteriskCode);
                this.showNotification('Code Asterisk généré avec succès', 'success');
            } else {
                this.showNotification('Erreur lors de la génération: ' + result.error, 'error');
            }
        } catch (error) {
            this.showNotification('Erreur de connexion: ' + error.message, 'error');
        }
    }

    async deployFlow() {
        if (!confirm('Êtes-vous sûr de vouloir déployer ce flux dans Asterisk ? Cela va modifier la configuration.')) {
            return;
        }

        const flowData = {
            nodes: Array.from(this.nodes.entries()).map(([id, node]) => ({
                id,
                type: node.type,
                properties: node.properties
            })),
            connections: Array.from(this.connections.entries()).map(([id, conn]) => ({
                id,
                fromNodeId: conn.fromNodeId,
                toNodeId: conn.toNodeId,
                properties: conn.properties
            }))
        };

        try {
            const response = await fetch('api/flow-management.php', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    action: 'deploy',
                    flowData: flowData
                })
            });

            const result = await response.json();
            if (result.success) {
                this.showNotification('Flux déployé avec succès dans Asterisk !', 'success');
            } else {
                this.showNotification('Erreur lors du déploiement: ' + result.error, 'error');
            }
        } catch (error) {
            this.showNotification('Erreur de connexion: ' + error.message, 'error');
        }
    }

    showGeneratedCode(code) {
        // Créer une modal pour afficher le code généré
        const modal = document.createElement('div');
        modal.className = 'modal';
        modal.style.display = 'block';
        modal.innerHTML = `
            <div class="modal-content" style="max-width: 800px; max-height: 80vh; overflow-y: auto;">
                <span class="close" onclick="this.closest('.modal').remove()">&times;</span>
                <h2>Code Asterisk Généré</h2>
                <pre style="background: #f8f9fa; padding: 20px; border-radius: 4px; overflow-x: auto;"><code>${code}</code></pre>
                <div style="margin-top: 20px;">
                    <button class="btn btn-primary" onclick="navigator.clipboard.writeText(\`${code.replace(/`/g, '\\`')}\`)">
                        <i class="fas fa-copy"></i> Copier
                    </button>
                    <button class="btn btn-secondary" onclick="this.closest('.modal').remove()">
                        Fermer
                    </button>
                </div>
            </div>
        `;
        document.body.appendChild(modal);
    }

    // NOUVELLES MÉTHODES pour le système de sélection séquentielle
    highlightOutputNodeAsSelected(nodeId, outputPoint) {
        console.log('🔴 Mise en évidence du nœud de sortie sélectionné:', nodeId);
        
        // Changer l'apparence du point de sortie pour indiquer la sélection
        outputPoint.fill('#ff6b00'); // Orange vif pour indiquer la sélection
        outputPoint.radius(12);
        outputPoint.stroke('#ffffff');
        outputPoint.strokeWidth(3);
        
        // Ajouter un effet de pulsation
        const animation = new Konva.Animation((frame) => {
            const opacity = (Math.sin(frame.time * 0.01) + 1) * 0.5;
            outputPoint.opacity(0.5 + opacity * 0.5);
        }, this.layer);
        
        // Stocker l'animation pour pouvoir l'arrêter plus tard
        const nodeData = this.nodes.get(nodeId);
        if (nodeData) {
            nodeData.selectionAnimation = animation;
        }
        
        animation.start();
        this.layer.draw();
    }

    resetOutputNodeVisual(nodeId) {
        console.log('🔴 Reset visuel du nœud de sortie:', nodeId);
        
        const nodeData = this.nodes.get(nodeId);
        if (nodeData && nodeData.outputPoint) {
            // Arrêter l'animation de pulsation
            if (nodeData.selectionAnimation) {
                nodeData.selectionAnimation.stop();
                delete nodeData.selectionAnimation;
            }
            
            // Remettre l'apparence normale
            nodeData.outputPoint.fill('#dc3545');
            nodeData.outputPoint.radius(8);
            nodeData.outputPoint.stroke('white');
            nodeData.outputPoint.strokeWidth(2);
            nodeData.outputPoint.opacity(1);
            
            this.layer.draw();
        }
    }

    // Méthode pour annuler toute sélection en cours
    clearOutputSelection() {
        if (this.selectedOutputNode) {
            console.log('🔄 Annulation de la sélection en cours');
            this.resetOutputNodeVisual(this.selectedOutputNode);
            this.selectedOutputNode = null;
            this.showNotification('Sélection annulée', 'info');
        }
        
        // Arrêter la prévisualisation et le drag
        this.stopConnectionPreview();
        if (this.isDraggingConnection) {
            this.stopConnectionDrag();
        }
    }

    showNotification(message, type) {
        // Utiliser Toastify.js si disponible, sinon alert
        if (typeof Toastify !== 'undefined') {
            const colors = {
                'success': '#28a745',
                'error': '#dc3545',
                'info': '#17a2b8',
                'warning': '#ffc107'
            };
            
            Toastify({
                text: message,
                duration: type === 'info' ? 4000 : 3000,
                gravity: "top",
                position: "right",
                backgroundColor: colors[type] || '#6c757d'
            }).showToast();
        } else {
            alert(message);
        }
    }

    addMenuOption(nodeId) {
        const node = this.nodes.get(nodeId);
        if (node && node.properties.options) {
            node.properties.options.push({
                key: (node.properties.options.length + 1).toString(),
                label: `Option ${node.properties.options.length + 1}`
            });
            this.showProperties(nodeId);
        }
    }

    toggleDebugMode() {
        this.debugMode = !this.debugMode;
        console.log('🐛 Debug mode:', this.debugMode ? 'ON' : 'OFF');
        
        // Redessiner tous les nœuds pour appliquer/supprimer la visualisation debug
        this.nodes.forEach((nodeData, nodeId) => {
            const inputZone = nodeData.inputZone;
            const outputZone = nodeData.outputZone;
            
            if (this.debugMode) {
                // Rendre les zones visibles
                if (inputZone) {
                    inputZone.stroke('rgba(46, 204, 113, 0.5)');
                    inputZone.strokeWidth(2);
                    inputZone.fill('rgba(46, 204, 113, 0.1)');
                }
                if (outputZone) {
                    outputZone.stroke('rgba(220, 53, 69, 0.5)');
                    outputZone.strokeWidth(2);
                    outputZone.fill('rgba(220, 53, 69, 0.1)');
                }
            } else {
                // Masquer les zones
                if (inputZone) {
                    inputZone.stroke(null);
                    inputZone.strokeWidth(0);
                    inputZone.fill('transparent');
                }
                if (outputZone) {
                    outputZone.stroke(null);
                    outputZone.strokeWidth(0);
                    outputZone.fill('transparent');
                }
            }
        });
        
        this.layer.draw();
        
        // Changer le style du bouton debug
        const debugBtn = document.getElementById('toggleDebug');
        if (this.debugMode) {
            debugBtn.style.background = '#dc3545';
            debugBtn.style.color = 'white';
            this.showNotification('Mode debug activé - Zones de connexion visibles', 'info');
        } else {
            debugBtn.style.background = '';
            debugBtn.style.color = '';
            this.showNotification('Mode debug désactivé', 'info');
        }
    }

    toggleDarkMode() {
        const body = document.body;
        const isDark = body.classList.contains('dark-mode');
        
        if (isDark) {
            body.classList.remove('dark-mode');
            localStorage.setItem('dark-mode', 'false');
            this.showNotification('Mode clair activé', 'info');
        } else {
            body.classList.add('dark-mode');
            localStorage.setItem('dark-mode', 'true');
            this.showNotification('Mode sombre activé', 'info');
        }

        // Changer l'icône du bouton
        const darkBtn = document.getElementById('toggleDarkMode');
        const icon = darkBtn.querySelector('i');
        if (body.classList.contains('dark-mode')) {
            icon.className = 'fas fa-sun';
            darkBtn.title = 'Basculer en mode clair';
        } else {
            icon.className = 'fas fa-moon';
            darkBtn.title = 'Basculer en mode sombre';
        }

        // Redessiner le canvas avec les nouvelles couleurs si nécessaire
        if (this.stage) {
            this.layer.draw();
        }
    }
    
    // === SYSTÈME D'INFOBULLES ===
    createTooltip() {
        this.tooltip = document.createElement('div');
        this.tooltip.className = 'tooltip';
        document.body.appendChild(this.tooltip);
    }
    
    showTooltip(nodeData, x, y) {
        if (!this.tooltip) return;
        
        // Configuration des informations par type de nœud
        const tooltipConfig = {
            start: {
                title: '🟢 Début d\'appel',
                description: 'Point d\'entrée du serveur vocal interactif. Premier élément exécuté lors d\'un appel entrant.',
                config: 'Déclenchement automatique • Accueil personnalisable'
            },
            menu: {
                title: '📋 Menu vocal',
                description: 'Présente les options disponibles à l\'appelant et capture son choix via les touches du téléphone.',
                config: 'Options configurables • Répétition automatique • Temporisation'
            },
            action: {
                title: '⚡ Action système',
                description: 'Exécute une opération spécifique comme la lecture d\'un message, une requête base de données ou un transfert.',
                config: 'Paramètres personnalisables • Gestion d\'erreurs • Logs automatiques'
            },
            condition: {
                title: '❓ Condition logique',
                description: 'Évalue une condition et dirige le flux selon le résultat (vrai/faux, comparaison de valeurs).',
                config: 'Conditions multiples • Opérateurs logiques • Variables système'
            },
            transfer: {
                title: '📞 Transfert d\'appel',
                description: 'Redirige l\'appelant vers un autre numéro, service ou queue d\'attente.',
                config: 'Numéro de destination • Mode de transfert • Gestion d\'échec'
            },
            end: {
                title: '🔴 Fin d\'appel',
                description: 'Termine la session SVI et raccroche l\'appel. Point final obligatoire de chaque flux.',
                config: 'Message de fin optionnel • Statistiques d\'appel • Logs de session'
            }
        };
        
        const config = tooltipConfig[nodeData.type] || {
            title: `📦 ${nodeData.type}`,
            description: 'Élément du serveur vocal interactif.',
            config: 'Configuration standard'
        };
        
        // Construction du contenu HTML
        this.tooltip.innerHTML = `
            <div class="tooltip-title">${config.title}</div>
            <div class="tooltip-description">${config.description}</div>
            <div class="tooltip-config">${config.config}</div>
        `;
        
        // Positionnement intelligent
        this.tooltip.style.left = (x + 15) + 'px';
        this.tooltip.style.top = (y - 50) + 'px';
        
        // Vérifier les bords de l'écran
        const rect = this.tooltip.getBoundingClientRect();
        if (rect.right > window.innerWidth) {
            this.tooltip.style.left = (x - rect.width - 15) + 'px';
        }
        if (rect.top < 0) {
            this.tooltip.style.top = (y + 15) + 'px';
        }
        
        // Affichage avec animation
        this.tooltip.classList.add('show');
    }
    
    hideTooltip() {
        if (this.tooltip) {
            this.tooltip.classList.remove('show');
        }
    }
    
    // === SYSTÈME DE PRÉVISUALISATION DE CONNEXION ===
    startConnectionPreview(fromNodeId, fromPoint) {
        this.isCreatingConnection = true;
        this.selectedOutputNode = fromNodeId;
        this.connectionStartPoint = fromPoint;
        
        // Créer la ligne de prévisualisation
        const startPos = fromPoint.getAbsolutePosition();
        this.previewLine = new Konva.Line({
            points: [startPos.x, startPos.y, startPos.x, startPos.y],
            stroke: '#667eea',
            strokeWidth: 3,
            lineCap: 'round',
            dash: [10, 5], // Ligne pointillée pour indiquer que c'est temporaire
            opacity: 0.7
        });
        
        this.layer.add(this.previewLine);
        this.layer.draw();
        
        // Feedback visuel sur le nœud de départ
        this.highlightOutputNodeAsSelected(fromNodeId, fromPoint);
        
        console.log('🎯 Prévisualisation de connexion démarrée depuis:', fromNodeId);
    }
    
    updateConnectionPreview(mousePos) {
        if (this.previewLine && this.connectionStartPoint && this.isCreatingConnection) {
            const startPos = this.connectionStartPoint.getAbsolutePosition();
            this.previewLine.points([startPos.x, startPos.y, mousePos.x, mousePos.y]);
            this.layer.draw();
        }
    }
    
    stopConnectionPreview() {
        if (this.previewLine) {
            this.previewLine.destroy();
            this.previewLine = null;
        }
        this.isCreatingConnection = false;
        this.connectionStartPoint = null;
        this.layer.draw();
        
        console.log('🛑 Prévisualisation de connexion arrêtée');
    }
    
    // === SYSTÈME DE DRAG & DROP POUR CONNEXIONS ===
    startConnectionDrag(fromNodeId, fromPoint, e) {
        this.isDraggingConnection = true;
        this.dragStartNode = fromNodeId;
        this.dragStartPoint = fromPoint;
        
        // Démarrer aussi la prévisualisation
        this.startConnectionPreview(fromNodeId, fromPoint);
        
        // Empêcher le drag du nœud pendant la création de connexion
        const nodeData = this.nodes.get(fromNodeId);
        if (nodeData && nodeData.group) {
            nodeData.group.draggable(false);
        }
        
        // Capturer les événements de souris au niveau du stage
        this.stage.on('mousemove.connectionDrag', (e) => {
            if (this.isDraggingConnection) {
                const mousePos = this.stage.getPointerPosition();
                this.updateConnectionPreview(mousePos);
            }
        });
        
        console.log('🖱️ Drag de connexion démarré depuis:', fromNodeId);
    }
    
    stopConnectionDrag() {
        this.isDraggingConnection = false;
        
        // Réactiver le drag des nœuds
        if (this.dragStartNode) {
            const nodeData = this.nodes.get(this.dragStartNode);
            if (nodeData && nodeData.group) {
                nodeData.group.draggable(true);
            }
        }
        
        // Nettoyer les événements
        this.stage.off('mousemove.connectionDrag');
        
        // Arrêter la prévisualisation
        this.stopConnectionPreview();
        
        this.dragStartNode = null;
        this.dragStartPoint = null;
        
        console.log('🖱️ Drag de connexion arrêté');
    }
}

// Initialiser l'éditeur
let flowEditor;
document.addEventListener('DOMContentLoaded', () => {
    // Initialiser le mode sombre selon la préférence sauvegardée
    const savedDarkMode = localStorage.getItem('dark-mode');
    if (savedDarkMode === 'true') {
        document.body.classList.add('dark-mode');
        const darkBtn = document.getElementById('toggleDarkMode');
        if (darkBtn) {
            const icon = darkBtn.querySelector('i');
            icon.className = 'fas fa-sun';
            darkBtn.title = 'Basculer en mode clair';
        }
    }
    
    flowEditor = new FlowEditor();
});
