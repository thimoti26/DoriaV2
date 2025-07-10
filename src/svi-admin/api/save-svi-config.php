<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once '../includes/ExtensionsParser.php';

try {
    // Lire les données JSON envoyées
    $input = file_get_contents('php://input');
    $data = json_decode($input, true);
    
    if (!$data) {
        throw new Exception("Données JSON invalides");
    }
    
    // Chemin vers le fichier extensions.conf
    $extensionsFile = '/var/www/html/asterisk-config/extensions.conf';
    
    if (!file_exists($extensionsFile)) {
        throw new Exception("Fichier extensions.conf non trouvé: $extensionsFile");
    }
    
    $parser = new ExtensionsParser($extensionsFile);
    
    // Valider la configuration
    $errors = $parser->validateSyntax($data);
    if (!empty($errors)) {
        throw new Exception("Erreurs de validation: " . implode(', ', $errors));
    }
    
    // Sauvegarder la configuration
    $parser->saveConfiguration($data);
    
    $response = [
        'success' => true,
        'message' => 'Configuration SVI sauvegardée avec succès',
        'timestamp' => date('Y-m-d H:i:s')
    ];
    
    echo json_encode($response, JSON_PRETTY_PRINT);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
