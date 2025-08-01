import { Component, OnInit } from '@angular/core';
import { FlowService } from '../../services/flow.service';
import { NodeType } from '../../models/svi-flow.interface';

@Component({
  selector: 'app-node-palette',
  templateUrl: './node-palette.component.html',
  styleUrls: ['./node-palette.component.scss']
})
export class NodePaletteComponent implements OnInit {

  nodeTypes: NodeType[] = [
    {
      type: 'start',
      label: 'Début',
      description: 'Point d\'entrée du flux',
      icon: 'S',
      color: '#4caf50'
    },
    {
      type: 'menu',
      label: 'Menu',
      description: 'Menu de sélection',
      icon: 'M',
      color: '#2196f3'
    },
    {
      type: 'action',
      label: 'Action',
      description: 'Exécution d\'une action',
      icon: 'A',
      color: '#ff9800'
    },
    {
      type: 'condition',
      label: 'Condition',
      description: 'Test conditionnel',
      icon: 'C',
      color: '#9c27b0'
    },
    {
      type: 'transfer',
      label: 'Transfert',
      description: 'Transfert d\'appel',
      icon: 'T',
      color: '#f44336'
    },
    {
      type: 'end',
      label: 'Fin',
      description: 'Fin du flux',
      icon: 'E',
      color: '#607d8b'
    }
  ];

  constructor(private flowService: FlowService) { }

  ngOnInit(): void {
  }

  onDragStart(event: DragEvent, nodeType: NodeType): void {
    if (event.dataTransfer) {
      event.dataTransfer.setData('application/json', JSON.stringify(nodeType));
      event.dataTransfer.effectAllowed = 'copy';
    }
    document.body.classList.add('dragging-node');
  }

  onDragEnd(event: DragEvent): void {
    document.body.classList.remove('dragging-node');
  }
}
