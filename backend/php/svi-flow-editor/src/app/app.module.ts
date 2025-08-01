import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { HttpClientModule } from '@angular/common/http';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { FlowEditorComponent } from './components/flow-editor/flow-editor.component';
import { NodePaletteComponent } from './components/node-palette/node-palette.component';
import { PropertiesPanelComponent } from './components/properties-panel/properties-panel.component';
import { FlowCanvasComponent } from './components/flow-canvas/flow-canvas.component';
import { SviNodeComponent } from './components/svi-node/svi-node.component';
import { ConnectionComponent } from './components/connection/connection.component';

@NgModule({
  declarations: [
    AppComponent,
    FlowEditorComponent,
    NodePaletteComponent,
    PropertiesPanelComponent,
    FlowCanvasComponent,
    SviNodeComponent,
    ConnectionComponent
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
