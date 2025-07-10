<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

try {
    // Utiliser l'interface Manager d'Asterisk pour recharger la configuration
    $asteriskHost = 'asterisk';
    $asteriskPort = 5038;
    $username = 'admin';
    $password = 'amp111';
    
    // Connexion à l'interface Manager d'Asterisk
    $socket = fsockopen($asteriskHost, $asteriskPort, $errno, $errstr, 10);
    
    if (!$socket) {
        throw new Exception("Impossible de se connecter à Asterisk Manager: $errstr ($errno)");
    }
    
    // Lire la bannière de bienvenue
    $response = fgets($socket);
    
    // Authentification
    $loginRequest = "Action: Login\r\n";
    $loginRequest .= "Username: $username\r\n";
    $loginRequest .= "Secret: $password\r\n";
    $loginRequest .= "\r\n";
    
    fwrite($socket, $loginRequest);
    
    // Lire la réponse d'authentification
    $authResponse = "";
    while (!feof($socket)) {
        $line = fgets($socket);
        $authResponse .= $line;
        if (trim($line) === "") break;
    }
    
    if (strpos($authResponse, "Response: Success") === false) {
        fclose($socket);
        throw new Exception("Échec de l'authentification Manager");
    }
    
    // Commande de rechargement du dialplan
    $reloadRequest = "Action: Command\r\n";
    $reloadRequest .= "Command: dialplan reload\r\n";
    $reloadRequest .= "\r\n";
    
    fwrite($socket, $reloadRequest);
    
    // Lire la réponse du rechargement
    $reloadResponse = "";
    $linesRead = 0;
    while (!feof($socket) && $linesRead < 20) {
        $line = fgets($socket);
        $reloadResponse .= $line;
        $linesRead++;
        
        // Si on trouve la fin de la réponse
        if (trim($line) === "" && strpos($reloadResponse, "Response:") !== false) {
            break;
        }
    }
    
    // Déconnexion
    $logoffRequest = "Action: Logoff\r\n\r\n";
    fwrite($socket, $logoffRequest);
    fclose($socket);
    
    // Vérifier le succès - Asterisk Manager renvoie toujours "Response: Success" pour les commandes valides
    if (strpos($reloadResponse, "Response: Success") !== false) {
        $response = [
            'success' => true,
            'message' => 'Configuration Asterisk rechargée avec succès',
            'output' => trim($reloadResponse)
        ];
    } else {
        throw new Exception("Échec du rechargement. Réponse: " . trim($reloadResponse));
    }
    
    echo json_encode($response, JSON_PRETTY_PRINT);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
