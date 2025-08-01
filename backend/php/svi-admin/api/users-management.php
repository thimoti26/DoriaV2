<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST');
header('Access-Control-Allow-Headers: Content-Type');

class UsersManagementAPI {
    private $pjsipConfigPath;
    private $asteriskConfigPath;
    
    public function __construct() {
        // Chemin vers le fichier de configuration PJSIP
        $this->pjsipConfigPath = '/var/www/html/asterisk-config/pjsip.conf';
        $this->asteriskConfigPath = '/var/www/html/asterisk-config';
        
        // Vérifier que le fichier existe
        if (!file_exists($this->pjsipConfigPath)) {
            throw new Exception("Fichier pjsip.conf non trouvé: " . $this->pjsipConfigPath);
        }
    }
    
    public function handleRequest() {
        try {
            $method = $_SERVER['REQUEST_METHOD'];
            
            if ($method === 'GET') {
                $action = $_GET['action'] ?? '';
                switch ($action) {
                    case 'list':
                        return $this->listUsers();
                    default:
                        throw new Exception("Action GET non supportée: " . $action);
                }
            } elseif ($method === 'POST') {
                $input = json_decode(file_get_contents('php://input'), true);
                $action = $input['action'] ?? '';
                
                switch ($action) {
                    case 'create':
                        return $this->createUser($input);
                    case 'update':
                        return $this->updateUser($input);
                    case 'delete':
                        return $this->deleteUser($input['userId']);
                    case 'reload':
                        return $this->reloadAsterisk();
                    default:
                        throw new Exception("Action POST non supportée: " . $action);
                }
            } else {
                throw new Exception("Méthode HTTP non supportée: " . $method);
            }
        } catch (Exception $e) {
            http_response_code(500);
            return [
                'success' => false,
                'error' => $e->getMessage()
            ];
        }
    }
    
    private function listUsers() {
        $users = [];
        $config = file_get_contents($this->pjsipConfigPath);
        
        // Parser le fichier pour extraire les utilisateurs
        $lines = explode("\n", $config);
        $currentUser = null;
        $inUserSection = false;
        
        foreach ($lines as $line) {
            $line = trim($line);
            
            // Ignorer les commentaires et lignes vides
            if (empty($line) || $line[0] === ';') {
                continue;
            }
            
            // Détecter les sections utilisateur (ex: [1001])
            if (preg_match('/^\[(\d+)\]\(endpoint_template\)/', $line, $matches)) {
                $userId = $matches[1];
                $currentUser = [
                    'id' => $userId,
                    'displayName' => '',
                    'context' => 'from-internal',
                    'password' => '',
                    'contact' => null,
                    'status' => 'offline',
                    'lastActivity' => null
                ];
                $inUserSection = true;
            }
            // Détecter callerid pour le nom d'affichage
            elseif ($inUserSection && preg_match('/^callerid=(.+)/', $line, $matches)) {
                if ($currentUser) {
                    $callerid = $matches[1];
                    if (preg_match('/^(.+) <\d+>$/', $callerid, $nameMatches)) {
                        $currentUser['displayName'] = $nameMatches[1];
                    } else {
                        $currentUser['displayName'] = $callerid;
                    }
                }
            }
            // Détecter la section auth pour le mot de passe
            elseif (preg_match('/^\[(\d+)\]\(auth_template\)/', $line, $matches)) {
                $inUserSection = false; // Sortir de la section endpoint
            }
            elseif (preg_match('/^password=(.+)/', $line, $matches)) {
                if ($currentUser) {
                    $currentUser['password'] = $matches[1];
                    $users[] = $currentUser;
                    $currentUser = null;
                }
            }
        }
        
        // Tenter de récupérer les statuts Asterisk (si disponible)
        $this->updateUserStatuses($users);
        
        return [
            'success' => true,
            'users' => $users
        ];
    }
    
    private function updateUserStatuses(&$users) {
        // Récupérer les statuts réels depuis Asterisk
        try {
            $output = [];
            $command = "docker exec doriav2-asterisk asterisk -rx 'pjsip show endpoints' 2>/dev/null";
            exec($command, $output);
            
            // Parser la sortie pour extraire les statuts
            foreach ($output as $line) {
                if (preg_match('/^\s*Endpoint:\s+(\d+)\/\d+.*?(Not in use|Unavailable|In use)/', $line, $matches)) {
                    $userId = $matches[1];
                    $status = $matches[2];
                    
                    // Trouver l'utilisateur correspondant
                    foreach ($users as &$user) {
                        if ($user['id'] === $userId) {
                            $user['status'] = ($status === 'Not in use') ? 'online' : 'offline';
                            $user['lastActivity'] = date('Y-m-d H:i:s');
                            break;
                        }
                    }
                }
                
                // Récupérer les contacts pour voir qui est enregistré
                if (preg_match('/^\s*Contact:\s+\d+\/sip:\d+@([^:]+):/', $line, $matches)) {
                    $contact = $matches[1];
                    // Mettre à jour le contact de l'utilisateur précédent trouvé
                    // Cette logique peut être améliorée pour une correspondance plus précise
                }
            }
        } catch (Exception $e) {
            // En cas d'erreur, garder les statuts par défaut
            error_log("Erreur lors de la récupération des statuts: " . $e->getMessage());
        }
    }
    
    private function createUser($userData) {
        $userId = $userData['userId'];
        $displayName = $userData['displayName'];
        $password = $userData['password'];
        $context = $userData['context'] ?? 'from-internal';
        
        // Valider les données
        if (!preg_match('/^\d+$/', $userId)) {
            throw new Exception("L'ID utilisateur doit être numérique");
        }
        
        if (empty($displayName) || empty($password)) {
            throw new Exception("Le nom d'affichage et le mot de passe sont requis");
        }
        
        // Vérifier que l'utilisateur n'existe pas déjà
        if ($this->userExists($userId)) {
            throw new Exception("L'utilisateur $userId existe déjà");
        }
        
        // Générer la configuration pour le nouvel utilisateur
        $userConfig = $this->generateUserConfig($userId, $displayName, $password, $context);
        
        // Ajouter au fichier de configuration
        $this->addUserToConfig($userConfig);
        
        return [
            'success' => true,
            'message' => "Utilisateur $userId créé avec succès"
        ];
    }
    
    private function updateUser($userData) {
        $originalUserId = $userData['originalUserId'];
        $newUserId = $userData['userId'];
        $displayName = $userData['displayName'];
        $password = $userData['password'];
        $context = $userData['context'] ?? 'from-internal';
        
        // Valider les données
        if (!preg_match('/^\d+$/', $newUserId)) {
            throw new Exception("L'ID utilisateur doit être numérique");
        }
        
        if (empty($displayName)) {
            throw new Exception("Le nom d'affichage est requis");
        }
        
        // Si l'ID change, vérifier qu'il n'existe pas déjà
        if ($originalUserId !== $newUserId && $this->userExists($newUserId)) {
            throw new Exception("L'utilisateur $newUserId existe déjà");
        }
        
        // Supprimer l'ancienne configuration
        $this->deleteUserFromConfig($originalUserId);
        
        // Ajouter la nouvelle configuration
        $userConfig = $this->generateUserConfig($newUserId, $displayName, $password, $context);
        $this->addUserToConfig($userConfig);
        
        return [
            'success' => true,
            'message' => "Utilisateur $newUserId modifié avec succès"
        ];
    }
    
    private function deleteUser($userId) {
        if (!$this->userExists($userId)) {
            throw new Exception("L'utilisateur $userId n'existe pas");
        }
        
        $this->deleteUserFromConfig($userId);
        
        return [
            'success' => true,
            'message' => "Utilisateur $userId supprimé avec succès"
        ];
    }
    
    private function userExists($userId) {
        $config = file_get_contents($this->pjsipConfigPath);
        return strpos($config, "[$userId](endpoint_template)") !== false;
    }
    
    private function generateUserConfig($userId, $displayName, $password, $context) {
        return "
; User $userId - $displayName
[$userId](endpoint_template)
auth=$userId
aors=$userId
callerid=$displayName <$userId>

[$userId](aor_template)
type=aor
contact=sip:$userId@dynamic

[$userId](auth_template)
type=auth
username=$userId
password=$password
";
    }
    
    private function addUserToConfig($userConfig) {
        $config = file_get_contents($this->pjsipConfigPath);
        
        // Ajouter à la fin du fichier
        $config .= "\n" . $userConfig;
        
        if (!file_put_contents($this->pjsipConfigPath, $config)) {
            throw new Exception("Impossible d'écrire dans le fichier de configuration");
        }
    }
    
    private function deleteUserFromConfig($userId) {
        $config = file_get_contents($this->pjsipConfigPath);
        $lines = explode("\n", $config);
        $newLines = [];
        $skipUntilNextUser = false;
        
        foreach ($lines as $line) {
            $trimmedLine = trim($line);
            
            // Détecter le début de la section utilisateur à supprimer
            if (preg_match("/^; User $userId\b/", $trimmedLine)) {
                $skipUntilNextUser = true;
                continue;
            }
            
            // Si on est en mode skip et qu'on trouve une autre section utilisateur, arrêter le skip
            if ($skipUntilNextUser && preg_match('/^; User \d+/', $trimmedLine) && !preg_match("/^; User $userId\b/", $trimmedLine)) {
                $skipUntilNextUser = false;
                $newLines[] = $line;
                continue;
            }
            
            // Si on est en mode skip et qu'on trouve une section de configuration non-utilisateur, arrêter le skip
            if ($skipUntilNextUser && preg_match('/^\[(?!\d+\]\()/', $trimmedLine)) {
                $skipUntilNextUser = false;
                $newLines[] = $line;
                continue;
            }
            
            // Garder la ligne si on ne skip pas
            if (!$skipUntilNextUser) {
                $newLines[] = $line;
            }
        }
        
        // Nettoyer les lignes vides en fin de fichier
        while (count($newLines) > 0 && trim(end($newLines)) === '') {
            array_pop($newLines);
        }
        
        $newConfig = implode("\n", $newLines);
        
        if (!file_put_contents($this->pjsipConfigPath, $newConfig)) {
            throw new Exception("Impossible d'écrire dans le fichier de configuration");
        }
    }
    
    private function reloadAsterisk() {
        // Utiliser le script de rechargement Asterisk
        try {
            // Exécuter le rechargement PJSIP
            $output1 = [];
            $returnCode1 = 0;
            $command1 = "docker exec doriav2-asterisk asterisk -rx 'pjsip reload' 2>/dev/null";
            exec($command1, $output1, $returnCode1);
            
            // Exécuter le rechargement du dialplan
            $output2 = [];
            $returnCode2 = 0;
            $command2 = "docker exec doriav2-asterisk asterisk -rx 'dialplan reload' 2>/dev/null";
            exec($command2, $output2, $returnCode2);
            
            // Récupérer le statut des endpoints
            $output3 = [];
            $returnCode3 = 0;
            $command3 = "docker exec doriav2-asterisk asterisk -rx 'pjsip show endpoints' 2>/dev/null";
            exec($command3, $output3, $returnCode3);
            
            $allOutput = array_merge(
                ["=== Rechargement PJSIP ==="],
                $output1,
                ["=== Rechargement Dialplan ==="], 
                $output2,
                ["=== Statut des Endpoints ==="],
                array_slice($output3, 0, 10) // Limiter à 10 lignes
            );
            
            return [
                'success' => true,
                'message' => "Configuration Asterisk rechargée avec succès",
                'output' => implode("\n", $allOutput)
            ];
        } catch (Exception $e) {
            throw new Exception("Erreur lors du rechargement: " . $e->getMessage());
        }
    }
}

// Traitement de la requête
try {
    $api = new UsersManagementAPI();
    $result = $api->handleRequest();
    echo json_encode($result);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
?>
