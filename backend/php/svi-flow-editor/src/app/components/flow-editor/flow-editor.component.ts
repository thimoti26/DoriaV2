import { Component, OnInit, OnDestroy } from '@angular/core';
import { Subject } from 'rxjs';
import { takeUntil } from 'rxjs/operators';
import { FlowService } from '../../services/flow.service';
import { SviFlow } from '../../models/svi-flow.interface';

@Component({
  selector: 'app-flow-editor',
  templateUrl: './flow-editor.component.html',
  styleUrls: ['./flow-editor.component.scss']
})
export class FlowEditorComponent implements OnInit, OnDestroy {
  currentFlow: SviFlow | null = null;
  private destroy$ = new Subject<void>();

  constructor(private flowService: FlowService) {}

  ngOnInit(): void {
    this.flowService.currentFlow$
      .pipe(takeUntil(this.destroy$))
      .subscribe(flow => {
        this.currentFlow = flow;
      });

    // Créer un nouveau flux par défaut
    if (!this.currentFlow) {
      this.flowService.createNewFlow('Nouveau flux SVI');
    }
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }

  saveFlow(): void {
    if (!this.currentFlow) return;

    this.flowService.saveFlow().subscribe({
      next: () => {
        alert('Flux sauvegardé avec succès !');
      },
      error: (error) => {
        alert('Erreur lors de la sauvegarde');
        console.error('Save error:', error);
      }
    });
  }

  testFlow(): void {
    if (!this.currentFlow) return;
    alert('Test du flux en cours...');
    console.log('Testing flow:', this.currentFlow);
  }
}
