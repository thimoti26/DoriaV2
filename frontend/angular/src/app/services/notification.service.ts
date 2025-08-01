import { Injectable } from '@angular/core';
import { Subject } from 'rxjs';

export interface NotificationMessage {
  id: string;
  type: 'success' | 'error' | 'warning' | 'info';
  title?: string;
  message: string;
  duration?: number;
  action?: {
    label: string;
    callback: () => void;
  };
}

@Injectable({
  providedIn: 'root'
})
export class NotificationService {
  private messagesSubject = new Subject<NotificationMessage>();
  public messages$ = this.messagesSubject.asObservable();

  private generateId(): string {
    return Math.random().toString(36).substr(2, 9);
  }

  private showMessage(
    type: NotificationMessage['type'],
    message: string,
    title?: string,
    duration: number = 5000,
    action?: NotificationMessage['action']
  ) {
    const notification: NotificationMessage = {
      id: this.generateId(),
      type,
      title,
      message,
      duration,
      action
    };

    this.messagesSubject.next(notification);
  }

  success(message: string, title?: string, duration?: number) {
    this.showMessage('success', message, title, duration);
  }

  error(message: string, title?: string, duration?: number) {
    this.showMessage('error', message, title, duration);
  }

  warning(message: string, title?: string, duration?: number) {
    this.showMessage('warning', message, title, duration);
  }

  info(message: string, title?: string, duration?: number) {
    this.showMessage('info', message, title, duration);
  }

  // Méthodes avec actions
  successWithAction(
    message: string,
    actionLabel: string,
    actionCallback: () => void,
    title?: string,
    duration?: number
  ) {
    this.showMessage('success', message, title, duration, {
      label: actionLabel,
      callback: actionCallback
    });
  }

  errorWithAction(
    message: string,
    actionLabel: string,
    actionCallback: () => void,
    title?: string,
    duration?: number
  ) {
    this.showMessage('error', message, title, duration, {
      label: actionLabel,
      callback: actionCallback
    });
  }
}
