import { Component, OnInit, OnDestroy } from '@angular/core';
import { Subject, takeUntil } from 'rxjs';
import { NotificationService, NotificationMessage } from '../../services/notification.service';

@Component({
  selector: 'app-notification',
  template: `
    <div class="notification-container">
      <div
        *ngFor="let notification of notifications"
        [class]="'notification notification-' + notification.type"
        [style.animation-delay]="'0.1s'"
      >
        <div class="notification-icon">
          <span [ngSwitch]="notification.type">
            <span *ngSwitchCase="'success'">✅</span>
            <span *ngSwitchCase="'error'">❌</span>
            <span *ngSwitchCase="'warning'">⚠️</span>
            <span *ngSwitchDefault>ℹ️</span>
          </span>
        </div>
        
        <div class="notification-content">
          <div *ngIf="notification.title" class="notification-title">
            {{ notification.title }}
          </div>
          <div class="notification-message">
            {{ notification.message }}
          </div>
        </div>
        
        <div class="notification-actions">
          <button
            *ngIf="notification.action"
            class="notification-action-btn"
            (click)="handleAction(notification)"
          >
            {{ notification.action.label }}
          </button>
          <button
            class="notification-close-btn"
            (click)="removeNotification(notification.id)"
          >
            ✕
          </button>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .notification-container {
      position: fixed;
      top: 20px;
      right: 20px;
      z-index: 1000;
      display: flex;
      flex-direction: column;
      gap: 12px;
      max-width: 400px;
    }

    .notification {
      display: flex;
      align-items: flex-start;
      gap: 12px;
      padding: 16px;
      border-radius: 8px;
      background: white;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
      border-left: 4px solid;
      animation: slideInRight 0.3s ease-out;
      transition: transform 0.2s ease, opacity 0.2s ease;
    }

    .notification:hover {
      transform: translateX(-4px);
    }

    .notification-success {
      border-left-color: #10b981;
      background: #f0fdf4;
    }

    .notification-error {
      border-left-color: #ef4444;
      background: #fef2f2;
    }

    .notification-warning {
      border-left-color: #f59e0b;
      background: #fffbeb;
    }

    .notification-info {
      border-left-color: #3b82f6;
      background: #eff6ff;
    }

    .notification-icon {
      font-size: 20px;
      line-height: 1;
    }

    .notification-content {
      flex: 1;
      min-width: 0;
    }

    .notification-title {
      font-weight: 600;
      margin-bottom: 4px;
      color: #1f2937;
    }

    .notification-message {
      color: #4b5563;
      line-height: 1.4;
    }

    .notification-actions {
      display: flex;
      align-items: center;
      gap: 8px;
    }

    .notification-action-btn {
      background: #3b82f6;
      color: white;
      border: none;
      padding: 4px 8px;
      border-radius: 4px;
      font-size: 12px;
      cursor: pointer;
      transition: background 0.2s;
    }

    .notification-action-btn:hover {
      background: #2563eb;
    }

    .notification-close-btn {
      background: transparent;
      border: none;
      color: #6b7280;
      cursor: pointer;
      padding: 4px;
      line-height: 1;
      transition: color 0.2s;
    }

    .notification-close-btn:hover {
      color: #374151;
    }

    @keyframes slideInRight {
      from {
        transform: translateX(100%);
        opacity: 0;
      }
      to {
        transform: translateX(0);
        opacity: 1;
      }
    }

    @keyframes slideOutRight {
      from {
        transform: translateX(0);
        opacity: 1;
      }
      to {
        transform: translateX(100%);
        opacity: 0;
      }
    }

    .notification.removing {
      animation: slideOutRight 0.3s ease-in forwards;
    }
  `]
})
export class NotificationComponent implements OnInit, OnDestroy {
  notifications: NotificationMessage[] = [];
  private destroy$ = new Subject<void>();

  constructor(private notificationService: NotificationService) {}

  ngOnInit() {
    this.notificationService.messages$
      .pipe(takeUntil(this.destroy$))
      .subscribe(notification => {
        this.addNotification(notification);
        
        if (notification.duration && notification.duration > 0) {
          setTimeout(() => {
            this.removeNotification(notification.id);
          }, notification.duration);
        }
      });
  }

  ngOnDestroy() {
    this.destroy$.next();
    this.destroy$.complete();
  }

  addNotification(notification: NotificationMessage) {
    this.notifications.unshift(notification);
    
    // Limiter le nombre de notifications
    if (this.notifications.length > 5) {
      this.notifications = this.notifications.slice(0, 5);
    }
  }

  removeNotification(id: string) {
    this.notifications = this.notifications.filter(n => n.id !== id);
  }

  handleAction(notification: NotificationMessage) {
    if (notification.action) {
      notification.action.callback();
      this.removeNotification(notification.id);
    }
  }
}
