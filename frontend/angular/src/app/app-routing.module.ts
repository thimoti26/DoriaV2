import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { SipUsersComponent } from './components/sip-users/sip-users.component';
import { AudioManagerComponent } from './components/audio-manager/audio-manager.component';
import { SviFlowEditorComponent } from './components/svi-flow-editor/svi-flow-editor.component';

const routes: Routes = [
  { 
    path: '', 
    redirectTo: '/svi-flow-editor', 
    pathMatch: 'full' 
  },
  { 
    path: 'svi-flow-editor', 
    component: SviFlowEditorComponent,
    data: { title: 'Éditeur de Flux SVI' }
  },
  { 
    path: 'sip-users', 
    component: SipUsersComponent,
    data: { title: 'Gestion des Utilisateurs SIP' }
  },
  { 
    path: 'audio-manager', 
    component: AudioManagerComponent,
    data: { title: 'Gestionnaire de Fichiers Audio' }
  },
  { 
    path: '**', 
    redirectTo: '/svi-flow-editor' 
  }
];

@NgModule({
  imports: [RouterModule.forRoot(routes, {
    enableTracing: false, // Mettre à true pour débugger le routage
    scrollPositionRestoration: 'top',
    useHash: true
  })],
  exports: [RouterModule]
})
export class AppRoutingModule { }
