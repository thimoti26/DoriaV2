export interface SviNode {
  id: string;
  type: 'start' | 'menu' | 'action' | 'condition' | 'transfer' | 'end';
  label: string;
  position: { x: number; y: number };
  data: any;
  connections: string[];
}

export interface SviFlow {
  id: string;
  name: string;
  nodes: SviNode[];
  connections: SviConnection[];
}

export interface SviConnection {
  id: string;
  sourceNodeId: string;
  targetNodeId: string;
  sourcePort?: string;
  targetPort?: string;
  label?: string;
}

export interface NodeType {
  type: string;
  icon: string;
  label: string;
  color: string;
  description: string;
}

export interface Position {
  x: number;
  y: number;
}
