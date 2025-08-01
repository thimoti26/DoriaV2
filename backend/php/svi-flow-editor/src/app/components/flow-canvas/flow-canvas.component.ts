import { Component, ElementRef, ViewChild, AfterViewInit, OnDestroy, OnInit } from '@angular/core';
import { Subject } from 'rxjs';
import { takeUntil } from 'rxjs/operators';
import * as d3 from 'd3';
import { FlowService } from '../../services/flow.service';
import { SviNode, SviFlow, SviConnection, NodeType } from '../../models/svi-flow.interface';

@Component({
  selector: 'app-flow-canvas',
  templateUrl: './flow-canvas.component.html',
  styleUrls: ['./flow-canvas.component.scss']
})
export class FlowCanvasComponent implements OnInit, OnDestroy, AfterViewInit {
  @ViewChild('canvas', { static: true }) canvasRef!: ElementRef<SVGElement>;
  
  private svg: any;
  private nodesLayer: any;
  private connectionsLayer: any;
  private previewLayer: any;
  
  currentFlow: SviFlow | null = null;
  selectedNode: SviNode | null = null;
  nodeTypes: NodeType[] = [];
  
  // État de connexion
  isConnecting = false;
  connectionStart: SviNode | null = null;
  connectionPreviewPath = '';
  
  // Tooltip
  showTooltip = false;
  tooltipText = '';
  tooltipPosition = { x: 0, y: 0 };
  
  private destroy$ = new Subject<void>();

  constructor(private flowService: FlowService) {}

  ngOnInit(): void {
    // Observer le flux actuel
    this.flowService.currentFlow$
      .pipe(takeUntil(this.destroy$))
      .subscribe(flow => {
        this.currentFlow = flow;
        this.updateCanvas();
      });

    // Observer le nœud sélectionné
    this.flowService.selectedNode$
      .pipe(takeUntil(this.destroy$))
      .subscribe(node => {
        this.selectedNode = node;
        this.updateNodeSelection();
      });

    // Observer les types de nœuds
    this.flowService.nodeTypes$
      .pipe(takeUntil(this.destroy$))
      .subscribe(types => {
        this.nodeTypes = types;
      });
  }

  ngAfterViewInit(): void {
    this.initializeSVG();
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }

  private initializeSVG(): void {
    this.svg = d3.select(this.canvasRef.nativeElement);
    
    // Initialiser les couches
    this.connectionsLayer = this.svg.select('.connections-layer');
    this.nodesLayer = this.svg.select('.nodes-layer');
    this.previewLayer = this.svg.select('.preview-layer');
    
    // Gérer le zoom et le pan
    const zoom = d3.zoom()
      .scaleExtent([0.1, 3])
      .on('zoom', (event) => {
        const { transform } = event;
        this.nodesLayer.attr('transform', transform);
        this.connectionsLayer.attr('transform', transform);
      });
    
    this.svg.call(zoom);
  }

  private updateCanvas(): void {
    if (!this.currentFlow || !this.svg) return;
    
    this.renderNodes();
    this.renderConnections();
  }

  private renderNodes(): void {
    if (!this.currentFlow) return;

    const nodes = this.nodesLayer
      .selectAll('.node-group')
      .data(this.currentFlow.nodes, (d: any) => d.id);

    // Supprimer les nœuds supprimés
    nodes.exit().remove();

    // Créer les nouveaux nœuds
    const nodeEnter = nodes.enter()
      .append('g')
      .attr('class', 'node-group')
      .attr('transform', (d: SviNode) => `translate(${d.position.x}, ${d.position.y})`);

    // Ajouter le rectangle du nœud
    nodeEnter.append('rect')
      .attr('class', 'node-rect')
      .attr('width', 120)
      .attr('height', 80)
      .attr('x', -60)
      .attr('y', -40);

    // Ajouter l'icône
    nodeEnter.append('circle')
      .attr('class', 'node-icon-bg')
      .attr('r', 16)
      .attr('cy', -10);

    nodeEnter.append('text')
      .attr('class', 'node-icon')
      .attr('y', -10)
      .text((d: SviNode) => this.getNodeIcon(d.type));

    // Ajouter le label
    nodeEnter.append('text')
      .attr('class', 'node-label')
      .attr('y', 15)
      .text((d: SviNode) => d.label);

    // Ajouter les points de connexion
    this.addConnectionPoints(nodeEnter);

    // Mettre à jour tous les nœuds
    const nodeUpdate = nodeEnter.merge(nodes);
    
    // Mettre à jour la position
    nodeUpdate
      .transition()
      .duration(200)
      .attr('transform', (d: SviNode) => `translate(${d.position.x}, ${d.position.y})`);

    // Mettre à jour les couleurs
    nodeUpdate.select('.node-icon-bg')
      .attr('fill', (d: SviNode) => this.getNodeColor(d.type));

    nodeUpdate.select('.node-label')
      .text((d: SviNode) => d.label);

    // Ajouter les événements
    this.addNodeEvents(nodeUpdate);
  }

  private addConnectionPoints(nodeEnter: any): void {
    // Point de sortie (droite)
    nodeEnter.append('circle')
      .attr('class', 'connection-point output')
      .attr('r', 6)
      .attr('cx', 60)
      .attr('cy', 0);

    // Point d'entrée (gauche)
    nodeEnter.append('circle')
      .attr('class', 'connection-point input')
      .attr('r', 6)
      .attr('cx', -60)
      .attr('cy', 0);
  }

  private addNodeEvents(nodeSelection: any): void {
    const self = this;

    // Drag & drop des nœuds
    const drag = d3.drag()
      .on('start', function(event: any, d: any) {
        d3.select(this).classed('dragging', true);
        self.hideTooltip();
      })
      .on('drag', function(event: any, d: any) {
        const node = d as SviNode;
        node.position.x += event.dx;
        node.position.y += event.dy;
        
        d3.select(this)
          .attr('transform', `translate(${node.position.x}, ${node.position.y})`);
        
        self.flowService.updateNode(node.id, { position: node.position });
      })
      .on('end', function(event: any, d: any) {
        d3.select(this).classed('dragging', false);
        const node = d as SviNode;
        self.flowService.updateNode(node.id, { position: node.position });
      });

    nodeSelection.call(drag);

    // Sélection des nœuds
    nodeSelection.on('click', function(event: MouseEvent, d: SviNode) {
      event.stopPropagation();
      self.flowService.selectNode(d);
    });

    // Tooltip
    nodeSelection
      .on('mouseenter', function(event: MouseEvent, d: SviNode) {
        self.showNodeTooltip(event, d);
      })
      .on('mouseleave', function() {
        self.hideTooltip();
      });

    // Événements des points de connexion
    nodeSelection.selectAll('.connection-point.output')
      .on('click', function(event: MouseEvent, d: SviNode) {
        event.stopPropagation();
        self.startConnection(d);
      });

    nodeSelection.selectAll('.connection-point.input')
      .on('click', function(event: MouseEvent, d: SviNode) {
        event.stopPropagation();
        self.endConnection(d);
      });
  }

  private renderConnections(): void {
    if (!this.currentFlow) return;

    const connections = this.connectionsLayer
      .selectAll('.connection')
      .data(this.currentFlow.connections, (d: any) => d.id);

    connections.exit().remove();

    const connectionEnter = connections.enter()
      .append('path')
      .attr('class', 'connection');

    const connectionUpdate = connectionEnter.merge(connections);

    connectionUpdate
      .attr('d', (d: SviConnection) => this.getConnectionPath(d))
      .on('click', (event: MouseEvent, d: SviConnection) => {
        event.stopPropagation();
        console.log('Connection clicked:', d);
      });
  }

  private getConnectionPath(connection: SviConnection): string {
    if (!this.currentFlow) return '';

    const sourceNode = this.currentFlow.nodes.find(n => n.id === connection.sourceNodeId);
    const targetNode = this.currentFlow.nodes.find(n => n.id === connection.targetNodeId);

    if (!sourceNode || !targetNode) return '';

    const source = { x: sourceNode.position.x + 60, y: sourceNode.position.y };
    const target = { x: targetNode.position.x - 60, y: targetNode.position.y };

    const dx = target.x - source.x;
    const dy = target.y - source.y;
    const dr = Math.sqrt(dx * dx + dy * dy) * 0.3;

    return `M${source.x},${source.y}A${dr},${dr} 0 0,1 ${target.x},${target.y}`;
  }

  private updateConnections(): void {
    if (!this.currentFlow) return;

    this.connectionsLayer
      .selectAll('.connection')
      .attr('d', (d: SviConnection) => this.getConnectionPath(d));
  }

  private updateNodeSelection(): void {
    if (!this.svg) return;

    this.nodesLayer
      .selectAll('.node-group')
      .classed('selected', (d: SviNode) => d.id === this.selectedNode?.id);
  }

  private getNodeIcon(type: string): string {
    const nodeType = this.nodeTypes.find(nt => nt.type === type);
    return nodeType?.icon || 'help';
  }

  private getNodeColor(type: string): string {
    const nodeType = this.nodeTypes.find(nt => nt.type === type);
    return nodeType?.color || '#666';
  }

  private startConnection(node: SviNode): void {
    this.isConnecting = true;
    this.connectionStart = node;
    this.updateConnectionPreview();
  }

  private endConnection(node: SviNode): void {
    if (this.isConnecting && this.connectionStart && this.connectionStart.id !== node.id) {
      this.flowService.addConnection(this.connectionStart.id, node.id);
    }
    this.cancelConnection();
  }

  private cancelConnection(): void {
    this.isConnecting = false;
    this.connectionStart = null;
    this.connectionPreviewPath = '';
  }

  private updateConnectionPreview(): void {
    if (!this.isConnecting || !this.connectionStart) return;

    // Cette méthode sera appelée pendant le mousemove
    // La logique sera implémentée dans onCanvasMouseMove
  }

  private showNodeTooltip(event: MouseEvent, node: SviNode): void {
    this.tooltipText = `${node.label} (${node.type})`;
    this.tooltipPosition = { x: event.clientX, y: event.clientY };
    this.showTooltip = true;
  }

  private hideTooltip(): void {
    this.showTooltip = false;
  }

  // Événements de drop HTML5
  onDragOver(event: DragEvent): void {
    event.preventDefault();
    event.dataTransfer!.dropEffect = 'copy';
  }

  onDragEnter(event: DragEvent): void {
    event.preventDefault();
  }

  onDragLeave(event: DragEvent): void {
    // Optional: add visual feedback
  }

  onDrop(event: DragEvent): void {
    event.preventDefault();
    
    try {
      const nodeTypeData = event.dataTransfer?.getData('application/json');
      if (nodeTypeData) {
        const nodeType = JSON.parse(nodeTypeData) as NodeType;
        const rect = this.canvasRef.nativeElement.getBoundingClientRect();
        const position = {
          x: event.clientX - rect.left,
          y: event.clientY - rect.top
        };
        
        this.flowService.addNode(nodeType.type, position);
      }
    } catch (error) {
      console.error('Error parsing dropped data:', error);
    }
  }

  onCanvasClick(event: MouseEvent): void {
    if (this.isConnecting) {
      this.cancelConnection();
    } else {
      this.flowService.selectNode(null);
    }
  }

  onCanvasMouseMove(event: MouseEvent): void {
    if (this.isConnecting && this.connectionStart) {
      const rect = this.canvasRef.nativeElement.getBoundingClientRect();
      const mouseX = event.clientX - rect.left;
      const mouseY = event.clientY - rect.top;
      
      const source = { 
        x: this.connectionStart.position.x + 60, 
        y: this.connectionStart.position.y 
      };
      const target = { x: mouseX, y: mouseY };
      
      const dx = target.x - source.x;
      const dy = target.y - source.y;
      const dr = Math.sqrt(dx * dx + dy * dy) * 0.3;
      
      this.connectionPreviewPath = `M${source.x},${source.y}A${dr},${dr} 0 0,1 ${target.x},${target.y}`;
    }
  }
}
