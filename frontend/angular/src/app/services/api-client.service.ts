import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { catchError, map } from 'rxjs/operators';

export interface SipUser {
  id: string;
  name: string;
  displayName: string;
  email?: string;
  extension: string;
  department?: string;
  status: 'online' | 'offline';
  context: string;
  contact?: string;
  lastActivity?: string;
  created_at?: string;
  password?: string;
}

export interface SviConfig {
  contexts: { [key: string]: any };
  menus: { [key: string]: any };
  sounds: string[];
}

export interface AudioFile {
  name: string;
  path: string;
  duration?: number;
  size?: number;
}

export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}

@Injectable({
  providedIn: 'root'
})
export class ApiClientService {
  private baseUrl = '/api/';

  constructor(private http: HttpClient) {}

  private handleError(error: any): Observable<never> {
    console.error('API Error:', error);
    return throwError(() => new Error(error.error?.error || error.message || 'Erreur API inconnue'));
  }

  // Configuration SVI
  getSviConfig(): Observable<SviConfig> {
    return this.http.get<ApiResponse<SviConfig>>(`${this.baseUrl}get-svi-config.php`)
      .pipe(
        map(response => response.data || { contexts: {}, menus: {}, sounds: [] }),
        catchError(this.handleError)
      );
  }

  saveSviConfig(config: SviConfig): Observable<any> {
    return this.http.post<ApiResponse>(`${this.baseUrl}save-svi-config.php`, config)
      .pipe(catchError(this.handleError));
  }

  // Gestion des utilisateurs SIP
  getSipUsers(): Observable<SipUser[]> {
    return this.http.get<any>(`${this.baseUrl}users-management.php?action=list`)
      .pipe(
        map(response => response.users || []),
        catchError(this.handleError)
      );
  }

  getSipUser(id: string): Observable<SipUser> {
    return this.http.get<ApiResponse<SipUser>>(`${this.baseUrl}users-management.php?action=get&id=${id}`)
      .pipe(
        map(response => response.data!),
        catchError(this.handleError)
      );
  }

  createSipUser(user: Partial<SipUser>): Observable<SipUser> {
    return this.http.post<ApiResponse<SipUser>>(`${this.baseUrl}users-management.php?action=create`, user)
      .pipe(
        map(response => response.data!),
        catchError(this.handleError)
      );
  }

  updateSipUser(id: string, user: Partial<SipUser>): Observable<SipUser> {
    return this.http.post<ApiResponse<SipUser>>(`${this.baseUrl}users-management.php?action=update`, { id, ...user })
      .pipe(
        map(response => response.data!),
        catchError(this.handleError)
      );
  }

  deleteSipUser(id: string): Observable<void> {
    return this.http.post<ApiResponse>(`${this.baseUrl}users-management.php?action=delete`, { id })
      .pipe(
        map(() => void 0),
        catchError(this.handleError)
      );
  }

  // Gestion des fichiers audio
  getAudioFiles(): Observable<AudioFile[]> {
    return this.http.get<any>(`${this.baseUrl}list-audio.php`)
      .pipe(
        map(response => {
          const allFiles: AudioFile[] = [];
          if (response.data) {
            // Fusionner tous les fichiers de toutes les langues
            Object.values(response.data).forEach((files: any) => {
              if (Array.isArray(files)) {
                allFiles.push(...files);
              }
            });
          }
          return allFiles;
        }),
        catchError(this.handleError)
      );
  }

  uploadAudio(file: File, language: string = 'fr'): Observable<AudioFile> {
    const formData = new FormData();
    formData.append('audioFile', file);
    formData.append('language', language);

    return this.http.post<ApiResponse<AudioFile>>(`${this.baseUrl}upload-audio.php`, formData)
      .pipe(
        map(response => response.data!),
        catchError(this.handleError)
      );
  }

  // Validation et contrôle
  validateSyntax(config: any): Observable<any> {
    return this.http.post<ApiResponse>(`${this.baseUrl}validate-syntax.php`, config)
      .pipe(catchError(this.handleError));
  }

  reloadAsterisk(): Observable<any> {
    return this.http.post<ApiResponse>(`${this.baseUrl}reload-asterisk.php`, {})
      .pipe(catchError(this.handleError));
  }

  // Test de connexion
  testConnection(): Observable<any> {
    return this.http.get<ApiResponse>(`${this.baseUrl}test.php`)
      .pipe(catchError(this.handleError));
  }
}
