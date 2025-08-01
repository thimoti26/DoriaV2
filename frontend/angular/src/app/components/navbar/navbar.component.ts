import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { ApiClientService } from '../../services/api-client.service';
import { NotificationService } from '../../services/notification.service';

@Component({
  selector: 'app-navbar',
  template: `
    <nav class="navbar">
      <div class="navbar-content">
        <div class="navbar-brand">
          <span class="brand-icon">📞</span>
          <span class="brand-text">SVI Admin</span>
          <span class="brand-version">v2.0</span>
        </div>

        <div class="navbar-nav">
          <a 
            routerLink="/svi-flow-editor" 
            routerLinkActive="active"
            class="nav-link"
            title="Éditeur de Flux SVI"
          >
            <span class="nav-icon">🔀</span>
            <span class="nav-text">Éditeur de Flux</span>
          </a>
          
          <a 
            routerLink="/sip-users" 
            routerLinkActive="active"
            class="nav-link"
            title="Gestion des Utilisateurs SIP"
          >
            <span class="nav-icon">👥</span>
            <span class="nav-text">Utilisateurs SIP</span>
          </a>
          
          <a 
            routerLink="/audio-manager" 
            routerLinkActive="active"
            class="nav-link"
            title="Gestionnaire de Fichiers Audio"
          >
            <span class="nav-icon">🎵</span>
            <span class="nav-text">Fichiers Audio</span>
          </a>

          <a 
            routerLink="/system-status" 
            routerLinkActive="active"
            class="nav-link"
            title="État du Système"
          >
            <span class="nav-icon">📊</span>
            <span class="nav-text">Statut Système</span>
          </a>
        </div>

        <div class="navbar-actions">
          <button 
            class="action-btn"
            (click)="testConnection()"
            [disabled]="testing"
            title="Tester la connexion"
          >
            <span *ngIf="!testing">🔗</span>
            <span *ngIf="testing">⏳</span>
            <span class="action-text">Connexion</span>
          </button>

          <button 
            class="action-btn action-btn-primary"
            (click)="reloadAsterisk()"
            [disabled]="reloading"
            title="Recharger la configuration Asterisk"
          >
            <span *ngIf="!reloading">🔄</span>
            <span *ngIf="reloading">⏳</span>
            <span class="action-text">Recharger</span>
          </button>

          <div class="connection-status" [class]="connectionStatusClass">
            <span class="status-indicator"></span>
            <span class="status-text">{{ connectionStatusText }}</span>
          </div>
        </div>
      </div>
    </nav>
  `,
  styles: [`
    .navbar {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
      box-shadow: 0 2px 12px rgba(0, 0, 0, 0.15);
      position: sticky;
      top: 0;
      z-index: 100;
    }

    .navbar-content {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 0 24px;
      height: 64px;
      max-width: 1400px;
      margin: 0 auto;
    }

    .navbar-brand {
      display: flex;
      align-items: center;
      gap: 8px;
      font-weight: 600;
      font-size: 18px;
    }

    .brand-icon {
      font-size: 24px;
    }

    .brand-version {
      background: rgba(255, 255, 255, 0.2);
      padding: 2px 6px;
      border-radius: 8px;
      font-size: 12px;
      font-weight: 500;
    }

    .navbar-nav {
      display: flex;
      align-items: center;
      gap: 8px;
    }

    .nav-link {
      display: flex;
      align-items: center;
      gap: 6px;
      padding: 8px 16px;
      border-radius: 8px;
      text-decoration: none;
      color: rgba(255, 255, 255, 0.9);
      transition: all 0.2s ease;
      font-weight: 500;
      position: relative;
      overflow: hidden;
    }

    .nav-link::before {
      content: '';
      position: absolute;
      top: 0;
      left: -100%;
      width: 100%;
      height: 100%;
      background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.1), transparent);
      transition: left 0.5s;
    }

    .nav-link:hover::before {
      left: 100%;
    }

    .nav-link:hover,
    .nav-link.active {
      background: rgba(255, 255, 255, 0.15);
      color: white;
      transform: translateY(-1px);
    }

    .nav-link.active {
      background: rgba(255, 255, 255, 0.2);
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    }

    .nav-icon {
      font-size: 16px;
    }

    .navbar-actions {
      display: flex;
      align-items: center;
      gap: 12px;
    }

    .action-btn {
      display: flex;
      align-items: center;
      gap: 6px;
      padding: 8px 12px;
      border: 1px solid rgba(255, 255, 255, 0.3);
      border-radius: 6px;
      background: rgba(255, 255, 255, 0.1);
      color: white;
      cursor: pointer;
      transition: all 0.2s ease;
      font-size: 14px;
      font-weight: 500;
    }

    .action-btn:hover:not(:disabled) {
      background: rgba(255, 255, 255, 0.2);
      transform: translateY(-1px);
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    }

    .action-btn:disabled {
      opacity: 0.6;
      cursor: not-allowed;
    }

    .action-btn-primary {
      background: rgba(255, 255, 255, 0.2);
      border-color: rgba(255, 255, 255, 0.4);
    }

    .action-btn-primary:hover:not(:disabled) {
      background: rgba(255, 255, 255, 0.3);
    }

    .connection-status {
      display: flex;
      align-items: center;
      gap: 6px;
      padding: 4px 8px;
      border-radius: 12px;
      font-size: 12px;
      font-weight: 500;
    }

    .connection-status.online {
      background: rgba(16, 185, 129, 0.2);
      color: #d1fae5;
    }

    .connection-status.offline {
      background: rgba(239, 68, 68, 0.2);
      color: #fecaca;
    }

    .connection-status.unknown {
      background: rgba(156, 163, 175, 0.2);
      color: #f3f4f6;
    }

    .status-indicator {
      width: 8px;
      height: 8px;
      border-radius: 50%;
      animation: pulse 2s infinite;
    }

    .online .status-indicator {
      background: #10b981;
    }

    .offline .status-indicator {
      background: #ef4444;
    }

    .unknown .status-indicator {
      background: #9ca3af;
    }

    @keyframes pulse {
      0%, 100% {
        opacity: 1;
      }
      50% {
        opacity: 0.5;
      }
    }

    /* Responsive */
    @media (max-width: 768px) {
      .navbar-content {
        padding: 0 16px;
        height: 56px;
      }

      .navbar-nav {
        gap: 4px;
      }

      .nav-text,
      .action-text {
        display: none;
      }

      .nav-link,
      .action-btn {
        padding: 8px;
      }

      .navbar-brand .brand-text {
        display: none;
      }

      .connection-status {
        display: none;
      }
    }

    @media (max-width: 480px) {
      .navbar-actions {
        gap: 4px;
      }

      .brand-version {
        display: none;
      }
    }
  `]
})
export class NavbarComponent {
  testing = false;
  reloading = false;
  connectionStatus: 'online' | 'offline' | 'unknown' = 'unknown';

  constructor(
    private router: Router,
    private apiClient: ApiClientService,
    private notificationService: NotificationService
  ) {
    // Test de connexion initial
    this.testConnection();
  }

  get connectionStatusClass(): string {
    return this.connectionStatus;
  }

  get connectionStatusText(): string {
    switch (this.connectionStatus) {
      case 'online':
        return 'En ligne';
      case 'offline':
        return 'Hors ligne';
      default:
        return 'Inconnu';
    }
  }

  async testConnection() {
    this.testing = true;
    try {
      await this.apiClient.testConnection().toPromise();
      this.connectionStatus = 'online';
      this.notificationService.success('Connexion établie avec succès');
    } catch (error: any) {
      this.connectionStatus = 'offline';
      this.notificationService.error('Erreur de connexion: ' + error.message);
    } finally {
      this.testing = false;
    }
  }

  async reloadAsterisk() {
    this.reloading = true;
    try {
      await this.apiClient.reloadAsterisk().toPromise();
      this.notificationService.successWithAction(
        'Configuration Asterisk rechargée avec succès',
        'Voir les logs',
        () => {
          // Ouvrir une page de logs ou modal
          console.log('Afficher les logs de rechargement');
        }
      );
    } catch (error: any) {
      this.notificationService.error('Erreur lors du rechargement: ' + error.message);
    } finally {
      this.reloading = false;
    }
  }
}
