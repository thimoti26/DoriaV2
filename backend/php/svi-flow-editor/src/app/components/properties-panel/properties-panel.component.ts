import { Component, OnInit, OnDestroy } from '@angular/core';
import { Subject } from 'rxjs';
import { takeUntil } from 'rxjs/operators';
import { FlowService } from '../../services/flow.service';
import { SviNode, NodeType } from '../../models/svi-flow.interface';
import { MatSnackBar } from '@angular/material/snack-bar';

@Component({
  selector: 'app-properties-panel',
  templateUrl: './properties-panel.component.html',
  styleUrls: ['./properties-panel.component.scss']
})
export class PropertiesPanelComponent implements OnInit, OnDestroy {
  selectedNode: SviNode | null = null;
  nodeTypes: NodeType[] = [];
  private destroy$ = new Subject<void>();

  constructor(
    private flowService: FlowService,
    private snackBar: MatSnackBar
  ) {}

  ngOnInit(): void {
    this.flowService.selectedNode$
      .pipe(takeUntil(this.destroy$))
      .subscribe(node => {
        this.selectedNode = node;
        this.initializeNodeData();
      });

    this.flowService.nodeTypes$
      .pipe(takeUntil(this.destroy$))
      .subscribe(types => {
        this.nodeTypes = types;
      });
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }

  private initializeNodeData(): void {
    if (!this.selectedNode) return;

    // Initialiser les données spécifiques au type de nœud si elles n'existent pas
    if (!this.selectedNode.data) {
      this.selectedNode.data = {};
    }

    switch (this.selectedNode.type) {
      case 'menu':
        if (!this.selectedNode.data.options) {
          this.selectedNode.data.options = [
            { key: '1', description: 'Option 1' }
          ];
        }
        break;
      case 'action':
        if (!this.selectedNode.data.actionType) {
          this.selectedNode.data.actionType = 'playback';
        }
        break;
      case 'condition':
        if (!this.selectedNode.data.operator) {
          this.selectedNode.data.operator = 'equals';
        }
        break;
      case 'transfer':
        if (!this.selectedNode.data.transferType) {
          this.selectedNode.data.transferType = 'blind';
        }
        break;
    }
  }

  getNodeIcon(): string {
    if (!this.selectedNode) return 'help';
    const nodeType = this.nodeTypes.find(nt => nt.type === this.selectedNode!.type);
    return nodeType?.icon || 'help';
  }

  getNodeColor(): string {
    if (!this.selectedNode) return '#666';
    const nodeType = this.nodeTypes.find(nt => nt.type === this.selectedNode!.type);
    return nodeType?.color || '#666';
  }

  getNodeTypeName(): string {
    if (!this.selectedNode) return '';
    const nodeType = this.nodeTypes.find(nt => nt.type === this.selectedNode!.type);
    return nodeType?.label || this.selectedNode.type;
  }

  getMenuOptions(): any[] {
    if (!this.selectedNode?.data?.options) {
      return [];
    }
    return this.selectedNode.data.options;
  }

  addMenuOption(): void {
    if (!this.selectedNode) return;
    
    if (!this.selectedNode.data) {
      this.selectedNode.data = {};
    }
    
    if (!this.selectedNode.data.options) {
      this.selectedNode.data.options = [];
    }
    
    const nextKey = (this.selectedNode.data.options.length + 1).toString();
    this.selectedNode.data.options.push({
      key: nextKey,
      description: `Option ${nextKey}`
    });
  }

  removeMenuOption(index: number): void {
    if (this.selectedNode?.data?.options) {
      this.selectedNode.data.options.splice(index, 1);
    }
  }

  saveProperties(): void {
    if (!this.selectedNode) return;

    this.flowService.updateNode(this.selectedNode.id, this.selectedNode);
    
    this.snackBar.open('Propriétés sauvegardées', 'Fermer', {
      duration: 2000,
      panelClass: ['success-snackbar']
    });
  }

  resetProperties(): void {
    if (!this.selectedNode) return;

    // Réinitialiser les données aux valeurs par défaut
    this.selectedNode.data = {};
    this.initializeNodeData();
    
    this.snackBar.open('Propriétés réinitialisées', 'Fermer', {
      duration: 2000,
      panelClass: ['info-snackbar']
    });
  }

  deleteNode(): void {
    if (!this.selectedNode) return;

    const nodeLabel = this.selectedNode.label;
    this.flowService.deleteNode(this.selectedNode.id);
    
    this.snackBar.open(`Nœud "${nodeLabel}" supprimé`, 'Fermer', {
      duration: 3000,
      panelClass: ['warning-snackbar']
    });
  }
}
