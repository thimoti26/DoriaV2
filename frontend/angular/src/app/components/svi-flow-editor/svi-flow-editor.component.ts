import { Component, OnInit, OnDestroy, ElementRef, ViewChild } from '@angular/core';
import { ApiClientService } from '../../services/api-client.service';
import { NotificationService } from '../../services/notification.service';

interface SviNode {
  id: string;
  type: 'menu' | 'action' | 'condition' | 'start' | 'end' | 'playback' | 'transfer';
  label: string;
  x: number;
  y: number;
  properties: any;
  connections: string[];
}

interface SviConnection {
  id: string;
  from: string;
  to: string;
  fromPort?: string;
  toPort?: string;
  label?: string;
}

interface SviFlow {
  nodes: SviNode[];
  connections: SviConnection[];
}

@Component({
  selector: 'app-svi-flow-editor',
  template: `
    <div class="svi-flow-editor">
      <div class="toolbar">
        <h2>Éditeur de Flux SVI</h2>
        <div class="toolbar-actions">
          <button class="btn btn-primary" (click)="saveFlow()">
            <i class="fas fa-save"></i> Sauvegarder
          </button>
          <button class="btn btn-secondary" (click)="loadFlow()">
            <i class="fas fa-folder-open"></i> Charger
          </button>
          <button class="btn btn-warning" (click)="clearFlow()">
            <i class="fas fa-trash"></i> Effacer
          </button>
        </div>
      </div>

      <div class="editor-container">
        <!-- Palette d'outils -->
        <div class="tool-palette">
          <h3>Éléments SVI</h3>
          <div class="palette-section">
            <h4>Contrôle</h4>
            <div 
              class="draggable-item" 
              draggable="true" 
              (dragstart)="onDragStart($event, 'start')"
            >
              <i class="fas fa-play-circle"></i> Début
            </div>
            <div 
              class="draggable-item" 
              draggable="true" 
              (dragstart)="onDragStart($event, 'end')"
            >
              <i class="fas fa-stop-circle"></i> Fin
            </div>
          </div>

          <div class="palette-section">
            <h4>Actions</h4>
            <div 
              class="draggable-item" 
              draggable="true" 
              (dragstart)="onDragStart($event, 'menu')"
            >
              <i class="fas fa-list"></i> Menu
            </div>
            <div 
              class="draggable-item" 
              draggable="true" 
              (dragstart)="onDragStart($event, 'action')"
            >
              <i class="fas fa-cog"></i> Action
            </div>
            <div 
              class="draggable-item" 
              draggable="true" 
              (dragstart)="onDragStart($event, 'condition')"
            >
              <i class="fas fa-question-circle"></i> Condition
            </div>
          </div>

          <div class="palette-section">
            <h4>Téléphonie</h4>
            <div 
              class="draggable-item" 
              draggable="true" 
              (dragstart)="onDragStart($event, 'playback')"
            >
              <i class="fas fa-play"></i> Lecture Audio
            </div>
            <div 
              class="draggable-item" 
              draggable="true" 
              (dragstart)="onDragStart($event, 'transfer')"
            >
              <i class="fas fa-phone-alt"></i> Transfert
            </div>
          </div>
        </div>

        <!-- Zone de travail -->
        <div 
          class="canvas-container"
          #canvas
          (drop)="onDrop($event)"
          (dragover)="onDragOver($event)"
          (click)="onCanvasClick($event)"
        >
          <svg 
            class="canvas-svg" 
            [attr.width]="canvasWidth" 
            [attr.height]="canvasHeight"
            (mousedown)="onSvgMouseDown($event)"
            (mousemove)="onSvgMouseMove($event)"
            (mouseup)="onSvgMouseUp($event)"
          >
            <!-- Lignes de connexion -->
            <g class="connections">
              <!-- Connexions existantes -->
              <g *ngFor="let connection of flow.connections">
                <path
                  [attr.d]="getConnectionPath(connection)"
                  stroke="#2563eb"
                  stroke-width="2"
                  fill="none"
                  marker-end="url(#arrowhead)"
                  class="connection-line"
                  (click)="selectConnection(connection, $event)"
                  [class.selected]="selectedConnection?.id === connection.id"
                />
                <!-- Label de connexion -->
                <text *ngIf="connection.label"
                      [attr.x]="getConnectionMidpoint(connection).x"
                      [attr.y]="getConnectionMidpoint(connection).y"
                      text-anchor="middle"
                      class="connection-label"
                      fill="#666">
                  {{ connection.label }}
                </text>
              </g>
              
              <!-- Ligne de connexion temporaire -->
              <line *ngIf="isConnecting && tempConnection.from"
                    [attr.x1]="tempConnection.startX"
                    [attr.y1]="tempConnection.startY"
                    [attr.x2]="tempConnection.endX"
                    [attr.y2]="tempConnection.endY"
                    stroke="#007bff"
                    stroke-width="2"
                    stroke-dasharray="5,5"
                    opacity="0.7"
              />
            </g>
            
            <!-- Marqueur de flèche -->
            <defs>
              <marker id="arrowhead" markerWidth="10" markerHeight="7" 
                      refX="9" refY="3.5" orient="auto">
                <polygon points="0 0, 10 3.5, 0 7" fill="#2563eb" />
              </marker>
            </defs>
          </svg>

          <!-- Nœuds -->
          <div 
            *ngFor="let node of flow.nodes; trackBy: trackNode"
            class="svi-node"
            [class]="'node-' + node.type"
            [style.left.px]="node.x"
            [style.top.px]="node.y"
            [class.selected]="selectedNode?.id === node.id"
            [class.dragging]="dragNode?.id === node.id"
            [class.highlighted]="highlightedNodes.includes(node.id)"
            [class.connection-target]="isInConnectionMode && node.type !== 'start'"
            (click)="onNodeClick(node, $event)"
            (mousedown)="startNodeDrag(node, $event)"
          >
            <div class="node-header">
              <i [class]="getNodeIcon(node.type)"></i>
              <span>{{ node.label }}</span>
              <button class="node-delete" 
                      (click)="deleteNode(node, $event)"
                      title="Supprimer le nœud">×</button>
            </div>
            <div class="node-content" *ngIf="node.properties">
              <small>{{ getNodeDescription(node) }}</small>
            </div>
            
            <!-- Points de connexion améliorés -->
            <div class="connection-points">
              <!-- Points de sortie uniquement (plus de points d'entrée) -->
              <div *ngIf="node.type !== 'end'" 
                   class="connection-point output" 
                   (click)="onOutputClick(node, 'output', $event)"
                   title="Point de sortie - Cliquer pour connecter">
                <span class="output-icon">🔗</span>
              </div>
              
              <!-- Points de sortie multiples pour les menus -->
              <div *ngIf="node.type === 'menu' && node.properties.options" 
                   class="menu-outputs">
                <div *ngFor="let option of node.properties.options; let i = index"
                     class="connection-point menu-output"
                     [style.right.px]="-8"
                     [style.top.px]="30 + i * 25"
                     (click)="onOutputClick(node, 'output-' + option.key, $event)"
                     [title]="'Sortie: ' + option.label + ' - Cliquer pour connecter'">
                  <span class="output-label">{{ option.key }}</span>
                </div>
              </div>
              
              <!-- Points de sortie pour les conditions -->
              <div *ngIf="node.type === 'condition'" 
                   class="condition-outputs">
                <div class="connection-point condition-output true"
                     [style.right.px]="-8"
                     [style.top.px]="20"
                     (click)="onOutputClick(node, 'output-true', $event)"
                     title="Sortie: Vrai - Cliquer pour connecter">
                  <span class="output-label">✓</span>
                </div>
                <div class="connection-point condition-output false"
                     [style.right.px]="-8"
                     [style.top.px]="50"
                     (click)="onOutputClick(node, 'output-false', $event)"
                     title="Sortie: Faux - Cliquer pour connecter">
                  <span class="output-label">✗</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Panneau de propriétés -->
        <div class="properties-panel">
          <!-- Propriétés des nœuds -->
          <div *ngIf="selectedNode && !selectedConnection">
            <h3>Propriétés du Nœud</h3>
            <form (ngSubmit)="updateNodeProperties()">
              <div class="form-group">
                <label>Nom:</label>
                <input 
                  type="text" 
                  [(ngModel)]="selectedNode.label" 
                  name="label"
                  class="form-control"
                >
              </div>

              <div *ngIf="selectedNode.type === 'menu'" class="form-group">
                <label>Message d'accueil:</label>
                <textarea 
                  [(ngModel)]="selectedNode.properties.welcomeMessage" 
                  name="welcomeMessage"
                  class="form-control"
                  rows="3"
                  placeholder="Bienvenue dans notre système..."
                ></textarea>
                
                <label>Options du menu:</label>
                <div *ngFor="let option of selectedNode.properties.options; let i = index" class="menu-option">
                  <input 
                    type="text" 
                    [(ngModel)]="option.key" 
                    [name]="'optionKey' + i"
                    placeholder="Touche"
                    class="form-control option-key"
                  >
                  <input 
                    type="text" 
                    [(ngModel)]="option.label" 
                    [name]="'optionLabel' + i"
                    placeholder="Description"
                    class="form-control option-label"
                  >
                  <button type="button" class="btn btn-danger btn-sm" 
                          (click)="removeMenuOption(i)">-</button>
                </div>
                <button type="button" class="btn btn-primary btn-sm" 
                        (click)="addMenuOption()">+ Ajouter Option</button>
              </div>

              <div *ngIf="selectedNode.type === 'playback'" class="form-group">
                <label>Fichier Audio:</label>
                <select [(ngModel)]="selectedNode.properties.audioFile" 
                        name="audioFile" 
                        class="form-control">
                  <option value="">Sélectionner un fichier</option>
                  <option *ngFor="let file of audioFiles" [value]="file.name">
                    {{ file.name }} ({{ file.duration }}s)
                  </option>
                </select>
              </div>

              <div *ngIf="selectedNode.type === 'transfer'" class="form-group">
                <label>Destination:</label>
                <input 
                  type="text" 
                  [(ngModel)]="selectedNode.properties.destination" 
                  name="destination"
                  class="form-control"
                  placeholder="Extension ou numéro"
                >
              </div>

              <div *ngIf="selectedNode.type === 'condition'" class="form-group">
                <label>Expression:</label>
                <textarea 
                  [(ngModel)]="selectedNode.properties.expression" 
                  name="expression"
                  class="form-control"
                  rows="3"
                  placeholder="Expression de condition"
                ></textarea>
              </div>

              <div class="form-actions">
                <button type="submit" class="btn btn-primary btn-sm">
                  Mettre à jour
                </button>
                <button type="button" class="btn btn-danger btn-sm" 
                        (click)="deleteSelectedNode()">
                  Supprimer
                </button>
              </div>
            </form>
          </div>

          <!-- Propriétés des connexions -->
          <div *ngIf="selectedConnection && !selectedNode">
            <h3>Propriétés de la Connexion</h3>
            <form (ngSubmit)="updateConnectionProperties()">
              <div class="form-group">
                <label>Label:</label>
                <input 
                  type="text" 
                  [(ngModel)]="selectedConnection.label" 
                  name="connectionLabel"
                  class="form-control"
                  placeholder="Nom de la connexion"
                >
              </div>
              
              <div class="form-group">
                <label>De:</label>
                <input 
                  type="text" 
                  [value]="getNodeLabel(selectedConnection.from)"
                  readonly
                  class="form-control"
                >
              </div>
              
              <div class="form-group">
                <label>Vers:</label>
                <input 
                  type="text" 
                  [value]="getNodeLabel(selectedConnection.to)"
                  readonly
                  class="form-control"
                >
              </div>

              <div class="form-actions">
                <button type="submit" class="btn btn-primary btn-sm">
                  Mettre à jour
                </button>
                <button type="button" class="btn btn-danger btn-sm" 
                        (click)="deleteSelectedConnection()">
                  Supprimer
                </button>
              </div>
            </form>
          </div>

          <!-- Instructions -->
          <div *ngIf="!selectedNode && !selectedConnection" class="instructions">
            <h3>Instructions</h3>
            <div class="instruction-item">
              <strong>Créer un nœud:</strong> Glissez un élément de la palette vers la zone de travail
            </div>
            <div class="instruction-item">
              <strong>Déplacer un nœud:</strong> Cliquez et glissez le nœud
            </div>
            <div class="instruction-item">
              <strong>Connecter des nœuds:</strong> Cliquez sur un point de sortie (vert), puis sur le nœud de destination
            </div>
            <div class="instruction-item">
              <strong>Supprimer une connexion:</strong> Cliquez sur le point de sortie déjà connecté
            </div>
            <div class="instruction-item">
              <strong>Annuler une connexion:</strong> Appuyez sur Échap
            </div>
            <div class="instruction-item">
              <strong>Modifier les propriétés:</strong> Cliquez sur un nœud ou une connexion
            </div>
          </div>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .svi-flow-editor {
      height: 100vh;
      display: flex;
      flex-direction: column;
      background: #f5f5f5;
    }

    .toolbar {
      background: white;
      padding: 1rem;
      border-bottom: 1px solid #ddd;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }

    .toolbar h2 {
      margin: 0;
      color: #333;
    }

    .toolbar-actions .btn {
      margin-left: 0.5rem;
    }

    .editor-container {
      flex: 1;
      display: flex;
      overflow: hidden;
    }

    .tool-palette {
      width: 250px;
      background: white;
      border-right: 1px solid #ddd;
      padding: 1rem;
      overflow-y: auto;
    }

    .tool-palette h3 {
      margin-top: 0;
      color: #333;
      border-bottom: 2px solid #007bff;
      padding-bottom: 0.5rem;
    }

    .palette-section {
      margin-bottom: 1.5rem;
    }

    .palette-section h4 {
      font-size: 0.9rem;
      color: #666;
      margin-bottom: 0.5rem;
      text-transform: uppercase;
    }

    .draggable-item {
      padding: 0.75rem;
      margin-bottom: 0.5rem;
      background: #f8f9fa;
      border: 1px solid #dee2e6;
      border-radius: 4px;
      cursor: grab;
      transition: all 0.2s;
      user-select: none;
    }

    .draggable-item:hover {
      background: #e9ecef;
      transform: translateY(-1px);
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }

    .draggable-item:active {
      cursor: grabbing;
    }

    .draggable-item i {
      margin-right: 0.5rem;
      color: #007bff;
    }

    .canvas-container {
      flex: 1;
      position: relative;
      background: 
        radial-gradient(circle, #ccc 1px, transparent 1px);
      background-size: 20px 20px;
      overflow: auto;
      min-height: 600px;
    }

    .canvas-svg {
      position: absolute;
      top: 0;
      left: 0;
      pointer-events: all;
      z-index: 1;
    }

    .connection-line {
      cursor: pointer;
      stroke-width: 2;
      transition: stroke-width 0.2s;
    }

    .connection-line:hover {
      stroke-width: 3;
    }

    .connection-line.selected {
      stroke: #007bff;
      stroke-width: 3;
    }

    .connection-label {
      font-size: 12px;
      font-weight: bold;
      pointer-events: none;
    }

    .svi-node {
      position: absolute;
      min-width: 140px;
      max-width: 200px;
      background: white;
      border: 2px solid #ddd;
      border-radius: 8px;
      cursor: move;
      z-index: 2;
      box-shadow: 0 2px 8px rgba(0,0,0,0.1);
      transition: all 0.2s ease;
      user-select: none;
      /* Assurer que les enfants positionnés sont visibles */
      overflow: visible !important;
    }

    .svi-node:hover {
      transform: translateY(-2px);
      box-shadow: 0 4px 16px rgba(0,0,0,0.15);
    }

    .svi-node.highlighted {
      box-shadow: 0 0 20px #00ff00, 0 0 40px #00ff00;
      border: 3px solid #00ff00;
      background: rgba(0, 255, 0, 0.15);
      transform: scale(1.05);
      animation: pulse-green 1s infinite;
    }

    @keyframes pulse-green {
      0% { box-shadow: 0 0 20px #00ff00, 0 0 40px #00ff00; }
      50% { box-shadow: 0 0 30px #00ff00, 0 0 60px #00ff00; }
      100% { box-shadow: 0 0 20px #00ff00, 0 0 40px #00ff00; }
    }

    .svi-node.connection-target {
      cursor: pointer;
      transition: all 0.2s ease;
    }

    .svi-node.connection-target:hover {
      box-shadow: 0 0 15px #007bff, 0 0 30px #007bff;
      border: 3px solid #007bff;
      background: rgba(0, 123, 255, 0.15);
      transform: scale(1.03);
    }

    .svi-node.selected {
      border-color: #007bff;
      box-shadow: 0 0 0 3px rgba(0,123,255,0.25);
    }

    .svi-node.dragging {
      transform: rotate(3deg);
      z-index: 10;
      box-shadow: 0 8px 32px rgba(0,0,0,0.3);
    }

    .node-start { border-color: #28a745; }
    .node-end { border-color: #dc3545; }
    .node-menu { border-color: #007bff; }
    .node-action { border-color: #ffc107; }
    .node-condition { border-color: #17a2b8; }
    .node-playback { border-color: #6f42c1; }
    .node-transfer { border-color: #fd7e14; }

    .node-header {
      padding: 0.5rem;
      background: #f8f9fa;
      border-bottom: 1px solid #ddd;
      border-radius: 6px 6px 0 0;
      font-weight: bold;
      font-size: 0.9rem;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }

    .node-header i {
      margin-right: 0.5rem;
    }

    .node-delete {
      background: none;
      border: none;
      color: #dc3545;
      font-size: 18px;
      font-weight: bold;
      cursor: pointer;
      padding: 0;
      width: 20px;
      height: 20px;
      display: flex;
      align-items: center;
      justify-content: center;
      border-radius: 50%;
      transition: background-color 0.2s;
    }

    .node-delete:hover {
      background-color: #dc3545;
      color: white;
    }

    .node-content {
      padding: 0.5rem;
      font-size: 0.8rem;
      color: #666;
    }

    .connection-points {
      position: relative;
    }

    .connection-point {
      width: 20px;
      height: 20px;
      border: 3px solid #007bff;
      border-radius: 50%;
      background: white;
      position: absolute;
      cursor: crosshair;
      z-index: 10;
      transition: all 0.2s;
      pointer-events: auto;
      box-shadow: 0 2px 6px rgba(0,0,0,0.3);
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 10px;
    }

    .connection-point:hover {
      background: #007bff;
      transform: scale(1.4);
      border-color: #ff4444;
      box-shadow: 0 4px 12px rgba(0,123,255,0.4);
    }

    .output-icon {
      color: #28a745;
      font-weight: bold;
      font-size: 10px;
      pointer-events: none;
    }

    .connection-point:hover .output-icon {
      color: white;
    }

    .connection-point.input {
      top: -6px;
      left: 50%;
      transform: translateX(-50%);
    }

    .connection-point.output {
      bottom: -10px;
      left: 50%;
      transform: translateX(-50%);
      background: #28a745 !important;
      border: 3px solid #28a745 !important;
      width: 20px !important;
      height: 20px !important;
      border-radius: 50% !important;
      box-shadow: 0 3px 8px rgba(40,167,69,0.4) !important;
      z-index: 100 !important;
      position: absolute !important;
      display: flex !important;
      align-items: center !important;
      justify-content: center !important;
    }

    .connection-point.output:hover {
      background: #ffffff;
      border-color: #dc3545;
      transform: translateX(-50%) scale(1.5);
      box-shadow: 0 0 15px #dc3545;
    }

    .connection-point.output .output-icon {
      color: white !important;
      font-size: 12px !important;
      font-weight: bold !important;
      text-shadow: 1px 1px 2px rgba(0,0,0,0.5) !important;
      display: block !important;
    }

    .connection-point.output:hover .output-icon {
      color: #dc3545;
    }

    .menu-output,
    .condition-output {
      width: 18px;
      height: 18px;
      border: 2px solid #28a745;
      background: white;
      border-radius: 4px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 10px;
      font-weight: bold;
      box-shadow: 0 2px 4px rgba(0,0,0,0.2);
      cursor: crosshair;
    }

    .menu-output:hover,
    .condition-output:hover {
      background: #28a745;
      color: white;
      transform: scale(1.2);
      box-shadow: 0 3px 8px rgba(40,167,69,0.4);
    }

    .condition-output.true {
      border-color: #28a745;
      color: #28a745;
    }

    .condition-output.false {
      border-color: #dc3545;
      color: #dc3545;
    }

    .connection-points {
      position: relative;
      pointer-events: none; /* Allow clicks to pass through to children */
    }

    .connection-points > * {
      pointer-events: auto; /* Re-enable clicks on connection points */
    }

    .output-label {
      font-size: 8px;
      font-weight: bold;
      pointer-events: none;
      color: #333;
    }

    .menu-option {
      display: flex;
      align-items: center;
      margin-bottom: 0.5rem;
      gap: 0.5rem;
    }

    .option-key {
      width: 60px;
    }

    .option-label {
      flex: 1;
    }

    .form-actions {
      display: flex;
      gap: 0.5rem;
      margin-top: 1rem;
      padding-top: 1rem;
      border-top: 1px solid #eee;
    }

    .instructions {
      padding: 1rem;
      background: #f8f9fa;
      border-radius: 4px;
      margin-top: 1rem;
    }

    .instruction-item {
      margin-bottom: 0.75rem;
      padding: 0.5rem;
      background: white;
      border-radius: 4px;
      font-size: 0.85rem;
    }

    .properties-panel {
      width: 300px;
      background: white;
      border-left: 1px solid #ddd;
      padding: 1rem;
      overflow-y: auto;
    }

    .properties-panel h3 {
      margin-top: 0;
      color: #333;
      border-bottom: 2px solid #007bff;
      padding-bottom: 0.5rem;
    }

    .form-group {
      margin-bottom: 1rem;
    }

    .form-group label {
      display: block;
      margin-bottom: 0.25rem;
      font-weight: bold;
      color: #333;
    }

    .form-control {
      width: 100%;
      padding: 0.375rem 0.75rem;
      border: 1px solid #ced4da;
      border-radius: 0.25rem;
      margin-bottom: 0.5rem;
    }

    .menu-option {
      display: flex;
      align-items: center;
      margin-bottom: 0.5rem;
    }

    .btn {
      padding: 0.375rem 0.75rem;
      border: 1px solid transparent;
      border-radius: 0.25rem;
      cursor: pointer;
      text-decoration: none;
      display: inline-block;
      margin-right: 0.5rem;
    }

    .btn-primary { background: #007bff; color: white; border-color: #007bff; }
    .btn-secondary { background: #6c757d; color: white; border-color: #6c757d; }
    .btn-warning { background: #ffc107; color: #212529; border-color: #ffc107; }
    .btn-danger { background: #dc3545; color: white; border-color: #dc3545; }
    .btn-sm { padding: 0.25rem 0.5rem; font-size: 0.875rem; }
  `]
})
export class SviFlowEditorComponent implements OnInit, OnDestroy {
  @ViewChild('canvas', { static: true }) canvasRef!: ElementRef;

  flow: SviFlow = {
    nodes: [],
    connections: []
  };

  selectedNode: SviNode | null = null;
  selectedConnection: SviConnection | null = null;
  draggedNodeType: string = '';
  
  // Système de drag amélioré
  isDragging = false;
  dragNode: SviNode | null = null;
  dragStartPos = { x: 0, y: 0 };
  mousePos = { x: 0, y: 0 };
  
  // Système de connexion amélioré
  isConnecting = false;
  connectionStart: { node: SviNode, port: string } | null = null;
  tempConnection = {
    from: '',
    startX: 0,
    startY: 0,
    endX: 0,
    endY: 0
  };
  
  // Nouveaux états pour l'interface améliorée
  highlightedNodes: string[] = []; // Nœuds surlignés pendant la connexion
  isInConnectionMode = false; // Mode connexion actif
  
  nodeIdCounter = 1;
  connectionIdCounter = 1;
  canvasWidth = 1200;
  canvasHeight = 800;
  audioFiles: any[] = [];

  constructor(
    private apiService: ApiClientService,
    private notificationService: NotificationService
  ) {}

  ngOnDestroy() {
    // Nettoyer les listeners d'événements
    document.removeEventListener('keydown', this.onEscapeKey);
    document.removeEventListener('mousemove', this.onConnectionDrag);
    document.removeEventListener('mouseup', this.onConnectionEnd);
  }

  ngOnInit() {
    this.loadAudioFiles();
    
    // Ajouter un nœud de départ par défaut
    this.addNode('start', 100, 100);
  }

  loadAudioFiles() {
    this.apiService.getAudioFiles().subscribe({
      next: (files) => {
        this.audioFiles = files;
      },
      error: (error) => {
        console.error('Erreur lors du chargement des fichiers audio:', error);
      }
    });
  }

  trackNode(index: number, node: SviNode): string {
    return node.id;
  }

  onDragStart(event: DragEvent, nodeType: string) {
    this.draggedNodeType = nodeType;
    event.dataTransfer?.setData('text/plain', nodeType);
  }

  onDragOver(event: DragEvent) {
    event.preventDefault();
  }

  onDrop(event: DragEvent) {
    event.preventDefault();
    const rect = this.canvasRef.nativeElement.getBoundingClientRect();
    const x = event.clientX - rect.left;
    const y = event.clientY - rect.top;
    
    this.addNode(this.draggedNodeType, x, y);
  }

  addNode(type: string, x: number, y: number) {
    const node: SviNode = {
      id: `node_${this.nodeIdCounter++}`,
      type: type as any,
      label: this.getDefaultLabel(type),
      x: x,
      y: y,
      properties: this.getDefaultProperties(type),
      connections: []
    };

    this.flow.nodes.push(node);
    this.selectNode(node);
    
    this.notificationService.success(`Nœud "${node.label}" ajouté`);
  }

  getDefaultLabel(type: string): string {
    const labels: {[key: string]: string} = {
      'start': 'Début',
      'end': 'Fin',
      'menu': 'Menu',
      'action': 'Action',
      'condition': 'Condition',
      'playback': 'Lecture Audio',
      'transfer': 'Transfert'
    };
    return labels[type] || type;
  }

  getDefaultProperties(type: string): any {
    switch(type) {
      case 'menu':
        return {
          welcomeMessage: '',
          options: [
            { key: '1', label: 'Option 1' },
            { key: '2', label: 'Option 2' }
          ]
        };
      case 'playback':
        return { audioFile: '' };
      case 'transfer':
        return { destination: '' };
      case 'condition':
        return { expression: '' };
      default:
        return {};
    }
  }

  getNodeIcon(type: string): string {
    const icons: {[key: string]: string} = {
      'start': 'fas fa-play-circle',
      'end': 'fas fa-stop-circle',
      'menu': 'fas fa-list',
      'action': 'fas fa-cog',
      'condition': 'fas fa-question-circle',
      'playback': 'fas fa-play',
      'transfer': 'fas fa-phone-alt'
    };
    return icons[type] || 'fas fa-square';
  }

  getNodeDescription(node: SviNode): string {
    switch(node.type) {
      case 'menu':
        return `${node.properties.options?.length || 0} options`;
      case 'playback':
        return node.properties.audioFile || 'Aucun fichier';
      case 'transfer':
        return node.properties.destination || 'Aucune destination';
      default:
        return '';
    }
  }

  selectNode(node: SviNode, event?: Event) {
    if (event) {
      event.stopPropagation();
    }
    this.selectedNode = node;
    this.selectedConnection = null;
  }

  selectConnection(connection: SviConnection, event?: Event) {
    if (event) {
      event.stopPropagation();
    }
    this.selectedConnection = connection;
    this.selectedNode = null;
  }

  startNodeDrag(node: SviNode, event: MouseEvent) {
    // Ne pas démarrer le drag si on est en mode connexion
    if (this.isInConnectionMode) {
      return;
    }
    
    if (event.button !== 0) return; // Only left click
    
    event.stopPropagation();
    event.preventDefault();
    
    this.isDragging = true;
    this.dragNode = node;
    this.selectNode(node);
    
    const rect = this.canvasRef.nativeElement.getBoundingClientRect();
    this.dragStartPos = { 
      x: event.clientX - rect.left - node.x, 
      y: event.clientY - rect.top - node.y 
    };
    
    console.log('🎯 Début du drag pour:', node.label);
    
    // Add event listeners to document for better mouse tracking
    document.addEventListener('mousemove', this.onNodeDrag);
    document.addEventListener('mouseup', this.onNodeDragEnd);
    
    // Prevent text selection during drag
    document.body.style.userSelect = 'none';
  }

  onNodeDrag = (event: MouseEvent) => {
    if (this.isDragging && this.dragNode) {
      const rect = this.canvasRef.nativeElement.getBoundingClientRect();
      
      let newX = event.clientX - rect.left - this.dragStartPos.x;
      let newY = event.clientY - rect.top - this.dragStartPos.y;
      
      // Constrain to canvas bounds
      newX = Math.max(0, Math.min(newX, this.canvasWidth - 140));
      newY = Math.max(0, Math.min(newY, this.canvasHeight - 100));
      
      this.dragNode.x = newX;
      this.dragNode.y = newY;
    }
  }

  onNodeDragEnd = () => {
    this.isDragging = false;
    this.dragNode = null;
    
    document.removeEventListener('mousemove', this.onNodeDrag);
    document.removeEventListener('mouseup', this.onNodeDragEnd);
    
    // Restore text selection
    document.body.style.userSelect = '';
  }

  // Nouvelle méthode pour gérer les clics sur les nœuds
  onNodeClick(node: SviNode, event: MouseEvent) {
    // Empêcher la propagation vers le canvas
    event.stopPropagation();
    
    if (this.isInConnectionMode && this.connectionStart) {
      // Mode connexion : connecter vers ce nœud
      if (node.type !== 'start' && node.id !== this.connectionStart.node.id) {
        console.log('🎯 Création de connexion vers:', node.label);
        this.createConnection(this.connectionStart.node, node, this.connectionStart.port, 'input');
        this.exitConnectionMode();
      } else {
        console.log('❌ Connexion invalide vers ce nœud');
        this.notificationService.warning('Connexion impossible vers ce nœud');
      }
    } else if (!this.isDragging) {
      // Mode normal : sélectionner le nœud seulement si on n'est pas en train de drag
      this.selectNode(node, event);
    }
  }

  // Nouvelle méthode pour gérer les clics sur les points de sortie
  onOutputClick(node: SviNode, port: string, event: MouseEvent) {
    // Empêcher la propagation vers le nœud et le canvas
    event.stopPropagation();
    event.preventDefault();
    
    console.log('🔗 Clic sur sortie:', { nodeId: node.id, nodeLabel: node.label, port });
    
    // Vérifier s'il y a déjà une connexion sur ce port
    const existingConnection = this.flow.connections.find(c => 
      c.from === node.id && c.fromPort === port
    );
    
    if (existingConnection) {
      // Supprimer la connexion existante
      console.log('🗑️ Suppression de la connexion existante:', existingConnection.id);
      this.flow.connections = this.flow.connections.filter(c => c.id !== existingConnection.id);
      this.notificationService.success('Connexion supprimée');
      return;
    }
    
    // Entrer en mode connexion
    this.enterConnectionMode(node, port, event);
  }

  // Entrer en mode connexion
  enterConnectionMode(node: SviNode, port: string, event: MouseEvent) {
    console.log('🎯 Entrée en mode connexion:', { from: node.label, port });
    
    this.isInConnectionMode = true;
    this.connectionStart = { node, port };
    
    // Surligner tous les nœuds qui peuvent recevoir une connexion
    this.highlightedNodes = this.flow.nodes
      .filter(n => n.type !== 'start' && n.id !== node.id)
      .map(n => n.id);
    
    console.log('🎯 Mode connexion activé, nœuds surlignés:', this.highlightedNodes.length);
    this.notificationService.info(`Mode connexion: cliquez sur un nœud de destination`);
    
    // Ajouter un listener pour sortir du mode avec Escape
    document.addEventListener('keydown', this.onEscapeKey);
    
    // Changer le curseur pour indiquer le mode connexion
    document.body.style.cursor = 'crosshair';
  }

  // Sortir du mode connexion
  exitConnectionMode() {
    console.log('🚪 Sortie du mode connexion');
    
    this.isInConnectionMode = false;
    this.connectionStart = null;
    this.highlightedNodes = [];
    this.tempConnection = { from: '', startX: 0, startY: 0, endX: 0, endY: 0 };
    
    // Restaurer le curseur normal
    document.body.style.cursor = '';
    
    document.removeEventListener('keydown', this.onEscapeKey);
    console.log('🚪 Mode connexion désactivé');
  }

  // Listener pour la touche Escape
  onEscapeKey = (event: KeyboardEvent) => {
    if (event.key === 'Escape') {
      this.exitConnectionMode();
      this.notificationService.info('Mode connexion annulé');
    }
  }

  startConnection(node: SviNode, port: string, event: MouseEvent) {
    console.log('🔗 startConnection:', { nodeId: node.id, nodeType: node.type, port });
    event.stopPropagation();
    event.preventDefault();
    
    if (port.startsWith('output')) {
      this.isConnecting = true;
      this.connectionStart = { node, port };
      
      const rect = this.canvasRef.nativeElement.getBoundingClientRect();
      const nodeRect = this.getNodeRect(node);
      
      this.tempConnection = {
        from: node.id,
        startX: nodeRect.x + nodeRect.width / 2,
        startY: nodeRect.y + nodeRect.height,
        endX: event.clientX - rect.left,
        endY: event.clientY - rect.top
      };
      
      console.log('🔗 Mode connexion activé, tempConnection:', this.tempConnection);
      
      document.addEventListener('mousemove', this.onConnectionDrag);
      document.addEventListener('mouseup', this.onConnectionEnd);
    } else {
      console.log('❌ Port non valide pour démarrer connexion:', port);
    }
  }

  endConnection(node: SviNode, port: string, event: MouseEvent) {
    console.log('🎯 endConnection:', { nodeId: node.id, nodeType: node.type, port, isConnecting: this.isConnecting });
    event.stopPropagation();
    
    if (this.isConnecting && this.connectionStart && port === 'input') {
      const fromNode = this.connectionStart.node;
      const fromPort = this.connectionStart.port;
      
      console.log('✅ Tentative de connexion:', { 
        from: fromNode.id, 
        to: node.id, 
        fromPort, 
        toPort: port 
      });
      
      // Check if connection is valid
      if (fromNode.id !== node.id && !this.connectionExists(fromNode.id, node.id)) {
        this.createConnection(fromNode, node, fromPort, port);
        console.log('🎉 Connexion créée avec succès!');
      } else {
        console.log('❌ Connexion invalide (même nœud ou connexion existante)');
      }
      
      this.endConnectionMode();
    } else {
      console.log('❌ Conditions non remplies pour endConnection:', {
        isConnecting: this.isConnecting,
        hasConnectionStart: !!this.connectionStart,
        portType: port
      });
    }
  }

  onConnectionDrag = (event: MouseEvent) => {
    if (this.isConnecting) {
      const rect = this.canvasRef.nativeElement.getBoundingClientRect();
      this.tempConnection.endX = event.clientX - rect.left;
      this.tempConnection.endY = event.clientY - rect.top;
    }
  }

  onConnectionEnd = () => {
    this.endConnectionMode();
  }

  endConnectionMode() {
    this.isConnecting = false;
    this.connectionStart = null;
    this.tempConnection = { from: '', startX: 0, startY: 0, endX: 0, endY: 0 };
    
    document.removeEventListener('mousemove', this.onConnectionDrag);
    document.removeEventListener('mouseup', this.onConnectionEnd);
  }

  createConnection(fromNode: SviNode, toNode: SviNode, fromPort: string, toPort: string) {
    console.log('✨ Création de connexion:', {
      from: fromNode.id + ' (' + fromNode.label + ')',
      to: toNode.id + ' (' + toNode.label + ')',
      fromPort,
      toPort
    });
    
    const connection: SviConnection = {
      id: `connection_${this.connectionIdCounter++}`,
      from: fromNode.id,
      to: toNode.id,
      fromPort,
      toPort,
      label: this.getConnectionLabel(fromNode, fromPort)
    };
    
    this.flow.connections.push(connection);
    console.log('🎉 Connexion créée avec succès:', connection);
    this.notificationService.success(`Connexion créée: ${fromNode.label} → ${toNode.label}`);
  }

  connectionExists(fromId: string, toId: string): boolean {
    return this.flow.connections.some(c => c.from === fromId && c.to === toId);
  }

  getConnectionLabel(node: SviNode, port: string): string {
    if (port.startsWith('output-') && node.type === 'menu') {
      const key = port.replace('output-', '');
      const option = node.properties.options?.find((o: any) => o.key === key);
      return option ? `Touche ${key}` : '';
    } else if (port === 'output-true') {
      return 'Vrai';
    } else if (port === 'output-false') {
      return 'Faux';
    }
    return '';
  }

  onSvgMouseDown(event: MouseEvent) {
    // Handle SVG interactions if needed
  }

  onSvgMouseMove(event: MouseEvent) {
    // Handle SVG mouse move if needed
  }

  onSvgMouseUp(event: MouseEvent) {
    // Handle SVG mouse up if needed
  }

  onCanvasClick(event: Event) {
    if (event.target === this.canvasRef.nativeElement) {
      this.selectedNode = null;
      this.selectedConnection = null;
    }
  }

  getNodeRect(node: SviNode): { x: number, y: number, width: number, height: number } {
    return {
      x: node.x,
      y: node.y,
      width: 140,
      height: 80
    };
  }

  getNodePosition(nodeId: string): {x: number, y: number} {
    const node = this.flow.nodes.find(n => n.id === nodeId);
    return node ? { x: node.x, y: node.y } : { x: 0, y: 0 };
  }

  getNodeLabel(nodeId: string): string {
    const node = this.flow.nodes.find(n => n.id === nodeId);
    return node ? node.label : 'Inconnu';
  }

  getConnectionPath(connection: SviConnection): string {
    const fromNode = this.flow.nodes.find(n => n.id === connection.from);
    const toNode = this.flow.nodes.find(n => n.id === connection.to);
    
    if (!fromNode || !toNode) return '';
    
    const fromRect = this.getNodeRect(fromNode);
    const toRect = this.getNodeRect(toNode);
    
    // Calculate connection points
    let startX = fromRect.x + fromRect.width / 2;
    let startY = fromRect.y + fromRect.height;
    let endX = toRect.x + toRect.width / 2;
    let endY = toRect.y;
    
    // Adjust for specific ports
    if (connection.fromPort?.startsWith('output-') && fromNode.type === 'menu') {
      startX = fromRect.x + fromRect.width;
      const optionIndex = fromNode.properties.options?.findIndex((o: any) => 
        o.key === connection.fromPort?.replace('output-', '')) || 0;
      startY = fromRect.y + 30 + optionIndex * 25;
    } else if (connection.fromPort === 'output-true' && fromNode.type === 'condition') {
      startX = fromRect.x + fromRect.width;
      startY = fromRect.y + 20;
    } else if (connection.fromPort === 'output-false' && fromNode.type === 'condition') {
      startX = fromRect.x + fromRect.width;
      startY = fromRect.y + 50;
    }
    
    // Create curved path
    const dx = endX - startX;
    const dy = endY - startY;
    const controlOffset = Math.abs(dy) * 0.3;
    
    return `M ${startX} ${startY} C ${startX} ${startY + controlOffset}, ${endX} ${endY - controlOffset}, ${endX} ${endY}`;
  }

  getConnectionMidpoint(connection: SviConnection): { x: number, y: number } {
    const fromNode = this.flow.nodes.find(n => n.id === connection.from);
    const toNode = this.flow.nodes.find(n => n.id === connection.to);
    
    if (!fromNode || !toNode) return { x: 0, y: 0 };
    
    const fromRect = this.getNodeRect(fromNode);
    const toRect = this.getNodeRect(toNode);
    
    return {
      x: (fromRect.x + fromRect.width / 2 + toRect.x + toRect.width / 2) / 2,
      y: (fromRect.y + fromRect.height + toRect.y) / 2
    };
  }

  addConnection(event: Event, node: SviNode, type: 'input' | 'output') {
    event.stopPropagation();
    // Legacy method - replaced by new connection system
    console.log('Legacy connection method called:', node.id, type);
  }

  updateConnectionProperties() {
    if (this.selectedConnection) {
      this.notificationService.success('Propriétés de connexion mises à jour');
    }
  }

  deleteNode(node: SviNode, event?: Event) {
    if (event) {
      event.stopPropagation();
    }
    
    if (confirm(`Êtes-vous sûr de vouloir supprimer le nœud "${node.label}" ?`)) {
      // Remove node
      const nodeIndex = this.flow.nodes.findIndex(n => n.id === node.id);
      if (nodeIndex >= 0) {
        this.flow.nodes.splice(nodeIndex, 1);
      }
      
      // Remove all connections involving this node
      this.flow.connections = this.flow.connections.filter(c => 
        c.from !== node.id && c.to !== node.id
      );
      
      // Clear selection if this node was selected
      if (this.selectedNode?.id === node.id) {
        this.selectedNode = null;
      }
      
      this.notificationService.success('Nœud supprimé');
    }
  }

  deleteSelectedNode() {
    if (this.selectedNode) {
      this.deleteNode(this.selectedNode);
    }
  }

  deleteSelectedConnection() {
    if (this.selectedConnection) {
      const index = this.flow.connections.findIndex(c => c.id === this.selectedConnection!.id);
      if (index >= 0) {
        this.flow.connections.splice(index, 1);
        this.selectedConnection = null;
        this.notificationService.success('Connexion supprimée');
      }
    }
  }

  addMenuOption() {
    if (this.selectedNode?.type === 'menu') {
      this.selectedNode.properties.options.push({ key: '', label: '' });
    }
  }

  removeMenuOption(index: number) {
    if (this.selectedNode?.type === 'menu') {
      this.selectedNode.properties.options.splice(index, 1);
    }
  }

  updateNodeProperties() {
    if (this.selectedNode) {
      this.notificationService.success('Propriétés mises à jour');
    }
  }

  saveFlow() {
    // Sauvegarder le flux via l'API
    this.notificationService.success('Flux sauvegardé');
  }

  loadFlow() {
    // Charger un flux via l'API
    this.notificationService.success('Flux chargé');
  }

  clearFlow() {
    if (confirm('Êtes-vous sûr de vouloir effacer tout le flux ?')) {
      this.flow.nodes = [];
      this.flow.connections = [];
      this.selectedNode = null;
      this.selectedConnection = null;
      this.addNode('start', 100, 100);
      this.notificationService.warning('Flux effacé');
    }
  }
}
