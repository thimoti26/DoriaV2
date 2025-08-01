import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { HttpClientModule } from '@angular/common/http';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { NodePaletteComponent } from './components/node-palette/node-palette.component';
import { PropertiesPanelComponent } from './components/properties-panel/properties-panel.component';
import { FlowCanvasComponent } from './components/flow-canvas/flow-canvas.component';
import { SviNodeComponent } from './components/svi-node/svi-node.component';
import { ConnectionComponent } from './components/connection/connection.component';

// Nouveaux composants pour les fonctionnalités HTML
import { NavbarComponent } from './components/navbar/navbar.component';
import { NotificationComponent } from './components/notification/notification.component';
import { SipUsersComponent } from './components/sip-users/sip-users.component';
import { AudioManagerComponent } from './components/audio-manager/audio-manager.component';
import { SviFlowEditorComponent } from './components/svi-flow-editor/svi-flow-editor.component';

@NgModule({
  declarations: [
    AppComponent,
    NodePaletteComponent,
    PropertiesPanelComponent,
    FlowCanvasComponent,
    SviNodeComponent,
    ConnectionComponent,
    // Nouveaux composants
    NavbarComponent,
    NotificationComponent,
    SipUsersComponent,
    AudioManagerComponent,
    SviFlowEditorComponent
  ],
  imports: [
    BrowserModule,
    HttpClientModule,
    FormsModule,
    ReactiveFormsModule,
    AppRoutingModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
