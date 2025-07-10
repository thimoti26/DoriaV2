// Script de test direct pour le drag and drop SVI
// À exécuter dans la console de l'interface SVI

function initSimpleDragDrop() {
    console.log('=== Initialisation Simple Drag Drop ===');
    
    // Sélectionner tous les templates
    const templates = document.querySelectorAll('.action-template');
    console.log('Templates trouvés:', templates.length);
    
    templates.forEach((template, index) => {
        // S'assurer que l'élément est draggable
        template.draggable = true;
        
        // Ajouter les événements directement
        template.ondragstart = function(e) {
            console.log('DRAG START:', this.dataset.type);
            e.dataTransfer.setData('text/plain', this.dataset.type);
            e.dataTransfer.effectAllowed = 'copy';
            this.style.opacity = '0.5';
        };
        
        template.ondragend = function(e) {
            console.log('DRAG END:', this.dataset.type);
            this.style.opacity = '1';
        };
        
        console.log(`Template ${index} configuré:`, template.dataset.type);
    });
    
    // Zone de drop
    const diagram = document.getElementById('sviDiagram');
    if (diagram) {
        diagram.ondragover = function(e) {
            e.preventDefault();
            e.dataTransfer.dropEffect = 'copy';
        };
        
        diagram.ondragenter = function(e) {
            e.preventDefault();
            this.style.backgroundColor = 'rgba(0, 123, 255, 0.1)';
            this.style.border = '2px dashed #007bff';
        };
        
        diagram.ondragleave = function(e) {
            this.style.backgroundColor = '';
            this.style.border = '';
        };
        
        diagram.ondrop = function(e) {
            e.preventDefault();
            this.style.backgroundColor = '';
            this.style.border = '';
            
            const actionType = e.dataTransfer.getData('text/plain');
            const rect = this.getBoundingClientRect();
            const x = e.clientX - rect.left;
            const y = e.clientY - rect.top;
            
            console.log('DROP:', { actionType, x, y });
            
            // Créer un nœud simple pour test
            const node = document.createElement('div');
            node.style.cssText = `
                position: absolute;
                left: ${x}px;
                top: ${y}px;
                background: white;
                border: 2px solid #007bff;
                padding: 10px;
                border-radius: 5px;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            `;
            node.textContent = `${actionType} (${x},${y})`;
            this.appendChild(node);
        };
        
        console.log('Zone de drop configurée');
    }
    
    console.log('=== Drag Drop Simple Prêt ===');
}

// Auto-exécution
initSimpleDragDrop();
