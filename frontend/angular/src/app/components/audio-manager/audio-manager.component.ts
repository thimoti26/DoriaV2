import { Component, OnInit } from '@angular/core';
import { ApiClientService, AudioFile } from '../../services/api-client.service';
import { NotificationService } from '../../services/notification.service';

@Component({
  selector: 'app-audio-manager',
  template: `
    <div class="audio-manager-container">
      <div class="audio-manager-header">
        <h2>
          <span class="icon">🎵</span>
          Gestionnaire de Fichiers Audio
          <span class="count" *ngIf="audioFiles.length > 0">({{ audioFiles.length }})</span>
        </h2>
        <button class="btn btn-primary" (click)="triggerFileUpload()">
          <span>📁</span> Ajouter un fichier
        </button>
      </div>

      <!-- Zone d'upload -->
      <div class="upload-zone" 
           [class.drag-over]="isDragOver"
           (dragover)="onDragOver($event)"
           (dragleave)="onDragLeave($event)"
           (drop)="onFileDrop($event)"
           (click)="triggerFileUpload()">
        <div class="upload-content">
          <div class="upload-icon">🎤</div>
          <h3>Glissez-déposez vos fichiers audio ici</h3>
          <p>ou cliquez pour sélectionner des fichiers</p>
          <small>Formats supportés: MP3, WAV, OGG</small>
        </div>
      </div>

      <input 
        #fileInput 
        type="file" 
        multiple 
        accept="audio/*" 
        style="display: none"
        (change)="onFileSelected($event)"
      >

      <!-- Liste des fichiers -->
      <div class="audio-files-grid" *ngIf="!loading && audioFiles.length > 0">
        <div class="audio-file-card" *ngFor="let file of audioFiles">
          <div class="file-header">
            <div class="file-icon">🎵</div>
            <div class="file-info">
              <div class="file-name">{{ file.name }}</div>
              <div class="file-details">
                <span *ngIf="file.duration">{{ formatDuration(file.duration) }}</span>
                <span *ngIf="file.size">{{ formatFileSize(file.size) }}</span>
              </div>
            </div>
          </div>
          
          <div class="file-actions">
            <button class="btn btn-play" (click)="playAudio(file)" [disabled]="currentlyPlaying === file.name">
              <span *ngIf="currentlyPlaying !== file.name">▶️</span>
              <span *ngIf="currentlyPlaying === file.name">⏸️</span>
              {{ currentlyPlaying === file.name ? 'En cours' : 'Écouter' }}
            </button>
            <button class="btn btn-copy" (click)="copyFilePath(file)">
              <span>📋</span> Copier le chemin
            </button>
            <button class="btn btn-delete" (click)="deleteAudioFile(file)">
              <span>🗑️</span> Supprimer
            </button>
          </div>

          <!-- Lecteur audio -->
          <audio 
            *ngIf="currentlyPlaying === file.name" 
            [src]="file.path" 
            controls 
            autoplay
            (ended)="onAudioEnded()"
            class="audio-player">
          </audio>
        </div>
      </div>

      <!-- État vide -->
      <div class="empty-state" *ngIf="!loading && audioFiles.length === 0">
        <div class="empty-icon">🎵</div>
        <h3>Aucun fichier audio</h3>
        <p>Ajoutez vos premiers fichiers audio pour vos menus SVI</p>
        <button class="btn btn-primary" (click)="triggerFileUpload()">
          <span>📁</span> Ajouter des fichiers
        </button>
      </div>

      <!-- Chargement -->
      <div class="loading" *ngIf="loading">
        <div class="loading-spinner"></div>
        <p>Chargement des fichiers audio...</p>
      </div>

      <!-- Upload en cours -->
      <div class="upload-progress" *ngIf="uploading">
        <div class="progress-info">
          <span>📤 Upload en cours...</span>
          <span>{{ uploadingFileName }}</span>
        </div>
        <div class="progress-bar">
          <div class="progress-fill" [style.width.%]="uploadProgress"></div>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .audio-manager-container {
      padding: 24px;
      max-width: 1200px;
      margin: 0 auto;
    }

    .audio-manager-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 24px;
      padding-bottom: 16px;
      border-bottom: 2px solid #e5e7eb;
    }

    .audio-manager-header h2 {
      margin: 0;
      color: #1f2937;
      display: flex;
      align-items: center;
      gap: 8px;
    }

    .audio-manager-header h2 .icon {
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

    .upload-zone {
      border: 2px dashed #d1d5db;
      border-radius: 12px;
      padding: 48px 24px;
      text-align: center;
      margin-bottom: 32px;
      cursor: pointer;
      transition: all 0.3s ease;
      background: #f9fafb;
    }

    .upload-zone:hover,
    .upload-zone.drag-over {
      border-color: #3b82f6;
      background: #eff6ff;
      transform: scale(1.02);
    }

    .upload-content {
      color: #6b7280;
    }

    .upload-icon {
      font-size: 48px;
      margin-bottom: 16px;
    }

    .upload-content h3 {
      margin: 0 0 8px 0;
      color: #374151;
    }

    .upload-content p {
      margin: 0 0 8px 0;
    }

    .upload-content small {
      color: #9ca3af;
    }

    .audio-files-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
      gap: 20px;
    }

    .audio-file-card {
      background: white;
      border: 1px solid #e5e7eb;
      border-radius: 12px;
      padding: 20px;
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
      transition: all 0.2s ease;
    }

    .audio-file-card:hover {
      transform: translateY(-2px);
      box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15);
    }

    .file-header {
      display: flex;
      align-items: center;
      gap: 12px;
      margin-bottom: 16px;
    }

    .file-icon {
      font-size: 24px;
      width: 40px;
      height: 40px;
      background: #eff6ff;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
    }

    .file-info {
      flex: 1;
      min-width: 0;
    }

    .file-name {
      font-weight: 600;
      color: #1f2937;
      word-break: break-all;
    }

    .file-details {
      display: flex;
      gap: 12px;
      color: #6b7280;
      font-size: 14px;
      margin-top: 4px;
    }

    .file-actions {
      display: flex;
      gap: 8px;
      flex-wrap: wrap;
      margin-bottom: 16px;
    }

    .file-actions .btn {
      flex: 1;
      min-width: 100px;
      font-size: 12px;
      padding: 6px 12px;
      justify-content: center;
    }

    .btn-play {
      background: #10b981;
      color: white;
      border-color: #10b981;
    }

    .btn-play:hover:not(:disabled) {
      background: #059669;
    }

    .btn-play:disabled {
      background: #6b7280;
      border-color: #6b7280;
      cursor: not-allowed;
    }

    .btn-copy {
      background: #f59e0b;
      color: white;
      border-color: #f59e0b;
    }

    .btn-copy:hover {
      background: #d97706;
    }

    .audio-player {
      width: 100%;
      margin-top: 12px;
    }

    .upload-progress {
      position: fixed;
      bottom: 24px;
      right: 24px;
      background: white;
      border: 1px solid #e5e7eb;
      border-radius: 8px;
      padding: 16px;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
      width: 300px;
      z-index: 1000;
    }

    .progress-info {
      display: flex;
      justify-content: space-between;
      margin-bottom: 8px;
      font-size: 14px;
    }

    .progress-bar {
      height: 4px;
      background: #f3f4f6;
      border-radius: 2px;
      overflow: hidden;
    }

    .progress-fill {
      height: 100%;
      background: #3b82f6;
      transition: width 0.3s ease;
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

    @media (max-width: 768px) {
      .audio-manager-header {
        flex-direction: column;
        gap: 16px;
        align-items: stretch;
      }

      .audio-files-grid {
        grid-template-columns: 1fr;
      }

      .file-actions {
        flex-direction: column;
      }

      .upload-progress {
        position: relative;
        bottom: auto;
        right: auto;
        width: 100%;
        margin-top: 16px;
      }
    }
  `]
})
export class AudioManagerComponent implements OnInit {
  audioFiles: AudioFile[] = [];
  loading = false;
  uploading = false;
  uploadProgress = 0;
  uploadingFileName = '';
  isDragOver = false;
  currentlyPlaying: string | null = null;

  constructor(
    private apiClient: ApiClientService,
    private notificationService: NotificationService
  ) {}

  ngOnInit() {
    this.loadAudioFiles();
  }

  async loadAudioFiles() {
    this.loading = true;
    try {
      this.audioFiles = await this.apiClient.getAudioFiles().toPromise() || [];
      this.notificationService.success(`${this.audioFiles.length} fichier(s) audio chargé(s)`);
    } catch (error: any) {
      this.notificationService.error('Erreur lors du chargement des fichiers audio: ' + error.message);
    } finally {
      this.loading = false;
    }
  }

  triggerFileUpload() {
    const fileInput = document.querySelector('input[type="file"]') as HTMLInputElement;
    fileInput?.click();
  }

  onFileSelected(event: Event) {
    const input = event.target as HTMLInputElement;
    if (input.files) {
      this.uploadFiles(Array.from(input.files));
    }
  }

  onDragOver(event: DragEvent) {
    event.preventDefault();
    this.isDragOver = true;
  }

  onDragLeave(event: DragEvent) {
    event.preventDefault();
    this.isDragOver = false;
  }

  onFileDrop(event: DragEvent) {
    event.preventDefault();
    this.isDragOver = false;
    
    if (event.dataTransfer?.files) {
      this.uploadFiles(Array.from(event.dataTransfer.files));
    }
  }

  async uploadFiles(files: File[]) {
    const audioFiles = files.filter(file => file.type.startsWith('audio/'));
    
    if (audioFiles.length === 0) {
      this.notificationService.warning('Aucun fichier audio valide sélectionné');
      return;
    }

    for (const file of audioFiles) {
      await this.uploadSingleFile(file);
    }

    await this.loadAudioFiles();
  }

  async uploadSingleFile(file: File) {
    this.uploading = true;
    this.uploadingFileName = file.name;
    this.uploadProgress = 0;

    try {
      // Simulation du progrès (à adapter selon votre API)
      const progressInterval = setInterval(() => {
        this.uploadProgress += 10;
        if (this.uploadProgress >= 90) {
          clearInterval(progressInterval);
        }
      }, 200);

      await this.apiClient.uploadAudio(file).toPromise();
      
      clearInterval(progressInterval);
      this.uploadProgress = 100;
      
      this.notificationService.success(`Fichier ${file.name} uploadé avec succès`);
      
      setTimeout(() => {
        this.uploading = false;
        this.uploadProgress = 0;
        this.uploadingFileName = '';
      }, 1000);
      
    } catch (error: any) {
      this.uploading = false;
      this.notificationService.error(`Erreur lors de l'upload de ${file.name}: ` + error.message);
    }
  }

  playAudio(file: AudioFile) {
    if (this.currentlyPlaying === file.name) {
      this.currentlyPlaying = null;
    } else {
      this.currentlyPlaying = file.name;
    }
  }

  onAudioEnded() {
    this.currentlyPlaying = null;
  }

  copyFilePath(file: AudioFile) {
    navigator.clipboard.writeText(file.path).then(() => {
      this.notificationService.success('Chemin du fichier copié dans le presse-papiers');
    }).catch(() => {
      this.notificationService.error('Impossible de copier le chemin du fichier');
    });
  }

  async deleteAudioFile(file: AudioFile) {
    if (!confirm(`Êtes-vous sûr de vouloir supprimer le fichier ${file.name} ?`)) {
      return;
    }

    try {
      // À implémenter côté API
      // await this.apiClient.deleteAudioFile(file.name).toPromise();
      this.notificationService.success(`Fichier ${file.name} supprimé`);
      await this.loadAudioFiles();
    } catch (error: any) {
      this.notificationService.error('Erreur lors de la suppression: ' + error.message);
    }
  }

  formatDuration(seconds: number): string {
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  }

  formatFileSize(bytes: number): string {
    if (bytes === 0) return '0 B';
    
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    
    return parseFloat((bytes / Math.pow(k, i)).toFixed(1)) + ' ' + sizes[i];
  }
}
