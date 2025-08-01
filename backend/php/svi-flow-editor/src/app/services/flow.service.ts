import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable } from 'rxjs';
import { HttpClient } from '@angular/common/http';
import { SviFlow, SviNode, SviConnection, NodeType } from '../models/svi-flow.interface';

@Injectable({
  providedIn: 'root'
})
export class FlowService {
  private currentFlowSubject = new BehaviorSubject<SviFlow | null>(null);
  private selectedNodeSubject = new BehaviorSubject<SviNode | null>(null);
  private nodeTypesSubject = new BehaviorSubject<NodeType[]>([]);

  public currentFlow$ = this.currentFlowSubject.asObservable();
  public selectedNode$ = this.selectedNodeSubject.asObservable();
  public nodeTypes$ = this.nodeTypesSubject.asObservable();

  constructor(private http: HttpClient) {
    this.initializeNodeTypes();
  }

  private initializeNodeTypes(): void {
    const nodeTypes: NodeType[] = [
      {
        type: 'start',
        icon: 'play_circle',
        label: 'Démarrage',
        color: '#4CAF50',
        description: 'Point de départ du flux SVI'
      },
      {
        type: 'menu',
        icon: 'menu',
        label: 'Menu',
        color: '#2196F3',
        description: 'Menu de navigation avec options'
      },
      {
        type: 'action',
        icon: 'settings',
        label: 'Action',
        color: '#FF9800',
        description: 'Exécution d\'une action'
      },
      {
        type: 'condition',
        icon: 'help_outline',
        label: 'Condition',
        color: '#9C27B0',
        description: 'Test conditionnel'
      },
      {
        type: 'transfer',
        icon: 'call_made',
        label: 'Transfert',
        color: '#F44336',
        description: 'Transfert d\'appel'
      },
      {
        type: 'end',
        icon: 'stop_circle',
        label: 'Fin',
        color: '#607D8B',
        description: 'Fin du flux SVI'
      }
    ];
    this.nodeTypesSubject.next(nodeTypes);
  }

  createNewFlow(name: string): SviFlow {
    const newFlow: SviFlow = {
      id: this.generateId(),
      name,
      nodes: [],
      connections: []
    };
    this.currentFlowSubject.next(newFlow);
    return newFlow;
  }

  addNode(type: string, position: { x: number; y: number }): SviNode {
    const currentFlow = this.currentFlowSubject.value;
    if (!currentFlow) return null as any;

    const newNode: SviNode = {
      id: this.generateId(),
      type: type as any,
      label: `${type.charAt(0).toUpperCase() + type.slice(1)} ${currentFlow.nodes.length + 1}`,
      position,
      data: {},
      connections: []
    };

    currentFlow.nodes.push(newNode);
    this.currentFlowSubject.next(currentFlow);
    return newNode;
  }

  addConnection(sourceNodeId: string, targetNodeId: string): SviConnection {
    const currentFlow = this.currentFlowSubject.value;
    if (!currentFlow) return null as any;

    const newConnection: SviConnection = {
      id: this.generateId(),
      sourceNodeId,
      targetNodeId
    };

    currentFlow.connections.push(newConnection);
    
    // Update node connections
    const sourceNode = currentFlow.nodes.find(n => n.id === sourceNodeId);
    if (sourceNode && !sourceNode.connections.includes(targetNodeId)) {
      sourceNode.connections.push(targetNodeId);
    }

    this.currentFlowSubject.next(currentFlow);
    return newConnection;
  }

  selectNode(node: SviNode | null): void {
    this.selectedNodeSubject.next(node);
  }

  updateNode(nodeId: string, updates: Partial<SviNode>): void {
    const currentFlow = this.currentFlowSubject.value;
    if (!currentFlow) return;

    const node = currentFlow.nodes.find(n => n.id === nodeId);
    if (node) {
      Object.assign(node, updates);
      this.currentFlowSubject.next(currentFlow);
    }
  }

  deleteNode(nodeId: string): void {
    const currentFlow = this.currentFlowSubject.value;
    if (!currentFlow) return;

    // Remove connections
    currentFlow.connections = currentFlow.connections.filter(
      c => c.sourceNodeId !== nodeId && c.targetNodeId !== nodeId
    );

    // Remove from other nodes' connections
    currentFlow.nodes.forEach(node => {
      node.connections = node.connections.filter(id => id !== nodeId);
    });

    // Remove node
    currentFlow.nodes = currentFlow.nodes.filter(n => n.id !== nodeId);
    
    this.currentFlowSubject.next(currentFlow);
    this.selectedNodeSubject.next(null);
  }

  saveFlow(): Observable<any> {
    const currentFlow = this.currentFlowSubject.value;
    if (!currentFlow) throw new Error('No flow to save');

    return this.http.post('/api/flows/save', currentFlow);
  }

  loadFlow(flowId: string): Observable<SviFlow> {
    return this.http.get<SviFlow>(`/api/flows/${flowId}`);
  }

  private generateId(): string {
    return Date.now().toString(36) + Math.random().toString(36).substr(2);
  }
}
