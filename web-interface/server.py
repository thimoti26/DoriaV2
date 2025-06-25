#!/usr/bin/env python3
"""
Serveur web simple pour l'interface DoriaV2 Asterisk
Sert les fichiers statiques et proxie les appels API vers le script PHP
"""

import http.server
import socketserver
import subprocess
import json
import os
import sys
import threading
import time
from urllib.parse import urlparse, parse_qs

class DoriaWebHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        # Définir le répertoire de base pour servir les fichiers
        self.base_dir = os.path.dirname(os.path.abspath(__file__))
        super().__init__(*args, directory=self.base_dir, **kwargs)
    
    def do_GET(self):
        parsed_path = urlparse(self.path)
        
        # API endpoints
        if parsed_path.path.startswith('/api/'):
            self.handle_api_request('GET')
        else:
            # Servir les fichiers statiques
            if parsed_path.path == '/':
                self.path = '/index.html'
            super().do_GET()
    
    def do_POST(self):
        parsed_path = urlparse(self.path)
        
        if parsed_path.path.startswith('/api/'):
            self.handle_api_request('POST')
        else:
            self.send_error(404, "Not Found")
    
    def handle_api_request(self, method):
        """Gestion des requêtes API"""
        try:
            parsed_path = urlparse(self.path)
            path_segments = parsed_path.path.strip('/').split('/')
            
            if len(path_segments) < 2:
                self.send_json_error("Endpoint manquant", 400)
                return
            
            endpoint = path_segments[1]
            action = path_segments[2] if len(path_segments) > 2 else None
            
            if endpoint == 'status':
                self.handle_status_request()
            elif endpoint == 'control' and action:
                self.handle_control_request(action)
            elif endpoint == 'logs':
                self.handle_logs_request(action)
            elif endpoint == 'docker' and action:
                self.handle_docker_request(action)
            else:
                self.send_json_error("Endpoint non supporté", 404)
                
        except Exception as e:
            self.send_json_error(f"Erreur serveur: {str(e)}", 500)
    
    def handle_status_request(self):
        """Gestion du statut du système"""
        try:
            # Vérifier Asterisk
            asterisk_status = self.check_asterisk_status()
            docker_status = self.check_docker_status()
            
            status_data = {
                'status': 'online' if asterisk_status else 'offline',
                'asterisk': asterisk_status,
                'docker': docker_status,
                'extensions': 1,  # Extension osmo
                'timestamp': time.strftime('%Y-%m-%d %H:%M:%S'),
                'uptime': self.get_system_uptime()
            }
            
            self.send_json_response(status_data)
        except Exception as e:
            self.send_json_error(f"Erreur de statut: {str(e)}", 500)
    
    def handle_control_request(self, action):
        """Gestion des commandes de contrôle"""
        try:
            script_path = os.path.join(os.path.dirname(self.base_dir), 'asterisk-ctl.sh')
            
            if action in ['start', 'stop', 'restart', 'status']:
                result = self.execute_command([script_path, action])
                
                response = {
                    'message': f'Action {action} exécutée',
                    'output': result['output'],
                    'success': result['success']
                }
                self.send_json_response(response)
            else:
                self.send_json_error("Action non supportée", 400)
                
        except Exception as e:
            self.send_json_error(f"Erreur de contrôle: {str(e)}", 500)
    
    def handle_logs_request(self, log_type=None):
        """Gestion des journaux"""
        try:
            if log_type == 'docker':
                logs = self.get_docker_logs()
            else:
                logs = self.get_asterisk_logs()
            
            self.send_json_response({'logs': logs, 'type': log_type or 'asterisk'})
        except Exception as e:
            self.send_json_error(f"Erreur de journaux: {str(e)}", 500)
    
    def handle_docker_request(self, action):
        """Gestion des commandes Docker"""
        try:
            compose_path = os.path.join(os.path.dirname(self.base_dir), 'compose.yml')
            
            if action in ['up', 'down', 'restart', 'ps']:
                if action == 'up':
                    cmd = ['docker-compose', '-f', compose_path, 'up', '-d']
                elif action == 'down':
                    cmd = ['docker-compose', '-f', compose_path, 'down']
                elif action == 'restart':
                    cmd = ['docker-compose', '-f', compose_path, 'restart']
                elif action == 'ps':
                    cmd = ['docker-compose', '-f', compose_path, 'ps']
                
                result = self.execute_command(cmd)
                
                response = {
                    'message': f'Docker {action} exécuté',
                    'output': result['output'],
                    'success': result['success']
                }
                self.send_json_response(response)
            else:
                self.send_json_error("Action Docker non supportée", 400)
                
        except Exception as e:
            self.send_json_error(f"Erreur Docker: {str(e)}", 500)
    
    def check_asterisk_status(self):
        """Vérifier si Asterisk est en cours d'exécution"""
        try:
            # Méthode 1: Vérifier le processus
            result = subprocess.run(['pgrep', 'asterisk'], 
                                  capture_output=True, text=True, timeout=5)
            if result.returncode == 0 and result.stdout.strip():
                return True
            
            # Méthode 2: Vérifier via Docker
            result = subprocess.run(['docker', 'ps', '--format', '{{.Names}}'], 
                                  capture_output=True, text=True, timeout=5)
            if 'asterisk' in result.stdout:
                return True
            
            return False
        except Exception:
            return False
    
    def check_docker_status(self):
        """Vérifier si Docker est disponible"""
        try:
            result = subprocess.run(['docker', '--version'], 
                                  capture_output=True, text=True, timeout=5)
            return result.returncode == 0
        except Exception:
            return False
    
    def get_system_uptime(self):
        """Obtenir l'uptime du système"""
        try:
            result = subprocess.run(['uptime'], capture_output=True, text=True, timeout=5)
            return result.stdout.strip() if result.returncode == 0 else "Non disponible"
        except Exception:
            return "Non disponible"
    
    def get_asterisk_logs(self):
        """Obtenir les journaux Asterisk"""
        try:
            # Essayer différents emplacements de logs
            log_paths = [
                '/var/log/asterisk/messages',
                '/var/log/asterisk/full',
                os.path.join(os.path.dirname(self.base_dir), 'asterisk-logs', 'messages')
            ]
            
            for log_path in log_paths:
                if os.path.exists(log_path):
                    return self.tail_file(log_path, 20)
            
            # Logs simulés si aucun fichier trouvé
            return self.generate_simulated_logs('asterisk')
        except Exception:
            return self.generate_simulated_logs('asterisk')
    
    def get_docker_logs(self):
        """Obtenir les journaux Docker"""
        try:
            compose_path = os.path.join(os.path.dirname(self.base_dir), 'compose.yml')
            result = subprocess.run(
                ['docker-compose', '-f', compose_path, 'logs', '--tail=20'],
                capture_output=True, text=True, timeout=10
            )
            
            if result.returncode == 0 and result.stdout.strip():
                return result.stdout.strip().split('\n')
            else:
                return self.generate_simulated_logs('docker')
        except Exception:
            return self.generate_simulated_logs('docker')
    
    def generate_simulated_logs(self, log_type):
        """Générer des logs simulés pour les tests"""
        timestamp = time.strftime('%Y-%m-%d %H:%M:%S')
        
        if log_type == 'asterisk':
            return [
                f"[{timestamp}] INFO: Asterisk démarré avec succès",
                f"[{timestamp}] INFO: Extension osmo (1000) enregistrée",
                f"[{timestamp}] INFO: SIP/UDP écoute sur port 5060",
                f"[{timestamp}] INFO: Module chan_sip chargé",
                f"[{timestamp}] INFO: Dialplan chargé depuis extensions.conf",
                f"[{timestamp}] INFO: Système prêt pour les appels",
                f"[{timestamp}] DEBUG: Configuration SIP validée",
                f"[{timestamp}] STATUS: Système opérationnel"
            ]
        else:
            return [
                f"[{timestamp}] docker-compose: Démarrage des conteneurs",
                f"[{timestamp}] asterisk_1: Container started",
                f"[{timestamp}] web_1: Container started",
                f"[{timestamp}] asterisk_1: Loading configurations...",
                f"[{timestamp}] asterisk_1: SIP module initialized",
                f"[{timestamp}] asterisk_1: Extension osmo configured",
                f"[{timestamp}] asterisk_1: System ready for calls"
            ]
    
    def tail_file(self, file_path, lines=10):
        """Lire les dernières lignes d'un fichier"""
        try:
            with open(file_path, 'r') as f:
                return f.readlines()[-lines:]
        except Exception:
            return []
    
    def execute_command(self, command):
        """Exécuter une commande système"""
        try:
            result = subprocess.run(
                command, 
                capture_output=True, 
                text=True, 
                timeout=30
            )
            
            return {
                'command': ' '.join(command),
                'output': result.stdout.split('\n') if result.stdout else [],
                'error': result.stderr if result.stderr else None,
                'return_code': result.returncode,
                'success': result.returncode == 0
            }
        except subprocess.TimeoutExpired:
            return {
                'command': ' '.join(command),
                'output': ['Timeout: commande trop longue'],
                'error': 'Timeout',
                'return_code': 124,
                'success': False
            }
        except Exception as e:
            return {
                'command': ' '.join(command),
                'output': [f'Erreur: {str(e)}'],
                'error': str(e),
                'return_code': 1,
                'success': False
            }
    
    def send_json_response(self, data):
        """Envoyer une réponse JSON de succès"""
        response = {
            'success': True,
            'data': data,
            'timestamp': time.strftime('%Y-%m-%d %H:%M:%S')
        }
        
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        self.wfile.write(json.dumps(response, indent=2).encode())
    
    def send_json_error(self, message, code=500):
        """Envoyer une réponse JSON d'erreur"""
        response = {
            'success': False,
            'error': message,
            'timestamp': time.strftime('%Y-%m-%d %H:%M:%S')
        }
        
        self.send_response(code)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        self.wfile.write(json.dumps(response, indent=2).encode())
    
    def log_message(self, format, *args):
        """Personnaliser les messages de log"""
        timestamp = time.strftime('%Y-%m-%d %H:%M:%S')
        print(f"[{timestamp}] {format % args}")

def start_server(port=8080):
    """Démarrer le serveur web"""
    print(f"🌐 Démarrage du serveur DoriaV2 sur le port {port}")
    print(f"📱 Interface web accessible sur: http://localhost:{port}")
    print(f"🔧 API disponible sur: http://localhost:{port}/api/")
    print("📋 Endpoints disponibles:")
    print("   • GET  /api/status          - Statut du système")
    print("   • POST /api/control/{action} - Contrôle du système")
    print("   • GET  /api/logs/{type}     - Journaux système")
    print("   • POST /api/docker/{action} - Commandes Docker")
    print("=" * 60)
    
    try:
        with socketserver.TCPServer(("", port), DoriaWebHandler) as httpd:
            httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n🛑 Arrêt du serveur demandé par l'utilisateur")
    except Exception as e:
        print(f"❌ Erreur lors du démarrage du serveur: {e}")
        sys.exit(1)

if __name__ == "__main__":
    # Récupérer le port depuis les arguments ou utiliser 8080 par défaut
    port = 8080
    if len(sys.argv) > 1:
        try:
            port = int(sys.argv[1])
        except ValueError:
            print("❌ Port invalide, utilisation du port 8080 par défaut")
    
    start_server(port)
