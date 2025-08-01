import { Component, OnInit } from '@angular/core';
import { ApiClientService, SipUser } from '../../services/api-client.service';
import { NotificationService } from '../../services/notification.service';

@Component({
  selector: 'app-sip-users',
  template: `
    <div class="sip-users-container">
      <div class="sip-users-header">
        <h2>
          <span class="icon">👥</span>
          Gestion des Utilisateurs SIP
          <span class="count" *ngIf="users.length > 0">({{ users.length }})</span>
        </h2>
        <button class="btn btn-primary" (click)="openAddUserModal()">
          <span>➕</span> Ajouter un utilisateur
        </button>
      </div>

      <div class="users-grid" *ngIf="!loading && users.length > 0">
        <div class="user-card" *ngFor="let user of users" [id]="'user-' + user.id">
          <div class="user-header">
            <div class="user-id">{{ user.id }}</div>
            <div class="user-status" [class.status-online]="user.status === 'online'" [class.status-offline]="user.status === 'offline'">
              {{ user.status === 'online' ? 'En ligne' : 'Hors ligne' }}
            </div>
          </div>
          <div class="user-info">
            <div><strong>Nom:</strong> {{ user.displayName || user.name }}</div>
            <div><strong>Extension:</strong> {{ user.extension }}</div>
            <div><strong>Contexte:</strong> {{ user.context }}</div>
            <div *ngIf="user.email"><strong>Email:</strong> {{ user.email }}</div>
            <div *ngIf="user.department"><strong>Département:</strong> {{ user.department }}</div>
            <div *ngIf="user.contact"><strong>Contact:</strong> {{ user.contact }}</div>
            <div *ngIf="user.lastActivity"><strong>Dernière activité:</strong> {{ user.lastActivity }}</div>
          </div>
          <div class="user-actions">
            <button class="btn btn-edit" (click)="editUser(user)">
              <span>✏️</span> Modifier
            </button>
            <button class="btn btn-delete" (click)="deleteUser(user.id)">
              <span>🗑️</span> Supprimer
            </button>
          </div>
        </div>
      </div>

      <div class="empty-state" *ngIf="!loading && users.length === 0">
        <div class="empty-icon">📞</div>
        <h3>Aucun utilisateur SIP configuré</h3>
        <p>Ajoutez votre premier utilisateur pour commencer</p>
        <button class="btn btn-primary" (click)="openAddUserModal()">
          <span>➕</span> Ajouter un utilisateur
        </button>
      </div>

      <div class="loading" *ngIf="loading">
        <div class="loading-spinner"></div>
        <p>Chargement des utilisateurs...</p>
      </div>
    </div>

    <!-- Modal d'édition/ajout d'utilisateur -->
    <div class="modal" [class.show]="showModal" (click)="closeModal($event)">
      <div class="modal-content">
        <div class="modal-header">
          <h3>{{ currentUser ? 'Modifier l\'utilisateur' : 'Ajouter un utilisateur' }}</h3>
          <button class="modal-close" (click)="closeModal()">✕</button>
        </div>
        
        <form class="modal-body" (ngSubmit)="saveUser()" #userForm="ngForm">
          <div class="form-row">
            <div class="form-field">
              <label for="userId">ID Utilisateur</label>
              <input
                type="text"
                id="userId"
                name="userId"
                [(ngModel)]="userFormData.id"
                required
                class="form-input"
                [disabled]="!!currentUser"
                placeholder="Ex: 1001"
              >
            </div>
            <div class="form-field">
              <label for="extension">Extension</label>
              <input
                type="text"
                id="extension"
                name="extension"
                [(ngModel)]="userFormData.extension"
                required
                class="form-input"
                placeholder="Ex: 1001"
              >
            </div>
          </div>

          <div class="form-field">
            <label for="displayName">Nom d'affichage</label>
            <input
              type="text"
              id="displayName"
              name="displayName"
              [(ngModel)]="userFormData.displayName"
              required
              class="form-input"
              placeholder="Ex: Jean Dupont"
            >
          </div>

          <div class="form-field">
            <label for="email">Email</label>
            <input
              type="email"
              id="email"
              name="email"
              [(ngModel)]="userFormData.email"
              class="form-input"
              placeholder="Ex: jean.dupont@entreprise.com"
            >
          </div>

          <div class="form-row">
            <div class="form-field">
              <label for="context">Contexte</label>
              <select
                id="context"
                name="context"
                [(ngModel)]="userFormData.context"
                required
                class="form-select"
              >
                <option value="from-internal">from-internal</option>
                <option value="from-external">from-external</option>
                <option value="svi-menu">svi-menu</option>
              </select>
            </div>
            <div class="form-field">
              <label for="department">Département</label>
              <input
                type="text"
                id="department"
                name="department"
                [(ngModel)]="userFormData.department"
                class="form-input"
                placeholder="Ex: IT, Commercial"
              >
            </div>
          </div>

          <div class="form-field" *ngIf="!currentUser">
            <label for="password">Mot de passe</label>
            <input
              type="password"
              id="password"
              name="password"
              [(ngModel)]="userFormData.password"
              [required]="!currentUser"
              class="form-input"
              placeholder="Mot de passe SIP"
            >
          </div>

          <div class="modal-actions">
            <button type="button" class="btn btn-secondary" (click)="closeModal()">
              Annuler
            </button>
            <button type="submit" class="btn btn-primary" [disabled]="!userForm.valid || saving">
              <span *ngIf="saving">⏳</span>
              <span *ngIf="!saving">💾</span>
              {{ saving ? 'Sauvegarde...' : 'Sauvegarder' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  `,
  styles: [`
    .sip-users-container {
      padding: 24px;
      max-width: 1200px;
      margin: 0 auto;
    }

    .sip-users-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 24px;
      padding-bottom: 16px;
      border-bottom: 2px solid #e5e7eb;
    }

    .sip-users-header h2 {
      margin: 0;
      color: #1f2937;
      display: flex;
      align-items: center;
      gap: 8px;
    }

    .sip-users-header h2 .icon {
      font-size: 24px;
    }

    .count {
      background: #3b82f6;
      color: white;
      padding: 2px 8px;
      border-radius: 12px;
      font-size: 14px;
      font-weight: 500;
    }

    .users-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
      gap: 20px;
    }

    .user-card {
      background: white;
      border: 1px solid #e5e7eb;
      border-radius: 12px;
      padding: 20px;
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
      transition: all 0.2s ease;
    }

    .user-card:hover {
      transform: translateY(-2px);
      box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15);
    }

    .user-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 16px;
      padding-bottom: 12px;
      border-bottom: 1px solid #f3f4f6;
    }

    .user-id {
      font-weight: 600;
      font-size: 18px;
      color: #1f2937;
    }

    .user-status {
      padding: 4px 8px;
      border-radius: 12px;
      font-size: 12px;
      font-weight: 500;
    }

    .status-online {
      background: #d1fae5;
      color: #065f46;
    }

    .status-offline {
      background: #fee2e2;
      color: #991b1b;
    }

    .user-info {
      margin-bottom: 16px;
    }

    .user-info > div {
      margin-bottom: 8px;
      color: #4b5563;
      font-size: 14px;
    }

    .user-info strong {
      color: #1f2937;
      font-weight: 500;
    }

    .user-actions {
      display: flex;
      gap: 8px;
    }

    .user-actions .btn {
      flex: 1;
      font-size: 14px;
      justify-content: center;
    }

    .empty-state {
      text-align: center;
      padding: 64px 24px;
      color: #6b7280;
    }

    .empty-icon {
      font-size: 64px;
      margin-bottom: 16px;
    }

    .empty-state h3 {
      margin: 0 0 8px 0;
      color: #374151;
    }

    .empty-state p {
      margin: 0 0 24px 0;
    }

    .loading {
      text-align: center;
      padding: 64px 24px;
      color: #6b7280;
    }

    .loading-spinner {
      width: 32px;
      height: 32px;
      border: 3px solid #f3f4f6;
      border-top: 3px solid #3b82f6;
      border-radius: 50%;
      animation: spin 1s linear infinite;
      margin: 0 auto 16px auto;
    }

    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }

    // Modal styles
    .modal {
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: rgba(0, 0, 0, 0.5);
      display: flex;
      align-items: center;
      justify-content: center;
      z-index: 1000;
      opacity: 0;
      visibility: hidden;
      transition: all 0.3s ease;
    }

    .modal.show {
      opacity: 1;
      visibility: visible;
    }

    .modal-content {
      background: white;
      border-radius: 12px;
      width: 90%;
      max-width: 600px;
      max-height: 90vh;
      overflow-y: auto;
      box-shadow: 0 10px 25px rgba(0, 0, 0, 0.25);
      transform: scale(0.9);
      transition: transform 0.3s ease;
    }

    .modal.show .modal-content {
      transform: scale(1);
    }

    .modal-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 24px;
      border-bottom: 1px solid #e5e7eb;
    }

    .modal-header h3 {
      margin: 0;
      color: #1f2937;
    }

    .modal-close {
      background: none;
      border: none;
      font-size: 24px;
      cursor: pointer;
      color: #6b7280;
      transition: color 0.2s;
    }

    .modal-close:hover {
      color: #374151;
    }

    .modal-body {
      padding: 24px;
    }

    .form-row {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 16px;
    }

    .form-field {
      margin-bottom: 16px;
    }

    .form-field label {
      display: block;
      margin-bottom: 6px;
      font-weight: 500;
      color: #374151;
    }

    .form-input,
    .form-select {
      width: 100%;
      padding: 10px 14px;
      border: 1px solid #d1d5db;
      border-radius: 6px;
      font-size: 14px;
      transition: border-color 0.2s, box-shadow 0.2s;
    }

    .form-input:focus,
    .form-select:focus {
      outline: none;
      border-color: #3b82f6;
      box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
    }

    .form-input:disabled {
      background: #f9fafb;
      color: #6b7280;
    }

    .modal-actions {
      display: flex;
      gap: 12px;
      justify-content: flex-end;
      margin-top: 24px;
      padding-top: 16px;
      border-top: 1px solid #e5e7eb;
    }

    // Responsive
    @media (max-width: 768px) {
      .sip-users-header {
        flex-direction: column;
        gap: 16px;
        align-items: stretch;
      }

      .users-grid {
        grid-template-columns: 1fr;
      }

      .form-row {
        grid-template-columns: 1fr;
      }

      .modal-actions {
        flex-direction: column;
      }
    }
  `]
})
export class SipUsersComponent implements OnInit {
  users: SipUser[] = [];
  loading = false;
  saving = false;
  showModal = false;
  currentUser: SipUser | null = null;
  userFormData: Partial<SipUser> = {};

  constructor(
    private apiClient: ApiClientService,
    private notificationService: NotificationService
  ) {}

  ngOnInit() {
    this.loadUsers();
  }

  async loadUsers() {
    this.loading = true;
    try {
      this.users = await this.apiClient.getSipUsers().toPromise() || [];
      this.notificationService.success(`${this.users.length} utilisateur(s) chargé(s)`);
    } catch (error: any) {
      this.notificationService.error('Erreur lors du chargement des utilisateurs: ' + error.message);
    } finally {
      this.loading = false;
    }
  }

  openAddUserModal() {
    this.currentUser = null;
    this.userFormData = {
      context: 'from-internal'
    };
    this.showModal = true;
  }

  editUser(user: SipUser) {
    this.currentUser = user;
    this.userFormData = { ...user };
    this.showModal = true;
  }

  closeModal(event?: Event) {
    if (event && event.target !== event.currentTarget) {
      return;
    }
    this.showModal = false;
    this.currentUser = null;
    this.userFormData = {};
  }

  async saveUser() {
    this.saving = true;
    try {
      if (this.currentUser) {
        // Mise à jour
        await this.apiClient.updateSipUser(this.currentUser.id, this.userFormData).toPromise();
        this.notificationService.success(`Utilisateur ${this.userFormData.id} mis à jour`);
      } else {
        // Création
        await this.apiClient.createSipUser(this.userFormData).toPromise();
        this.notificationService.success(`Utilisateur ${this.userFormData.id} créé`);
      }
      
      this.closeModal();
      await this.loadUsers();
    } catch (error: any) {
      this.notificationService.error('Erreur lors de la sauvegarde: ' + error.message);
    } finally {
      this.saving = false;
    }
  }

  async deleteUser(userId: string) {
    if (!confirm(`Êtes-vous sûr de vouloir supprimer l'utilisateur ${userId} ?`)) {
      return;
    }

    try {
      await this.apiClient.deleteSipUser(userId).toPromise();
      this.notificationService.success(`Utilisateur ${userId} supprimé`);
      await this.loadUsers();
    } catch (error: any) {
      this.notificationService.error('Erreur lors de la suppression: ' + error.message);
    }
  }
}
