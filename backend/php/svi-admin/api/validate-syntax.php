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
    
    $parser = new ExtensionsParser();
    
    // Valider la syntaxe
    $errors = $parser->validateSyntax($data);
    
    $response = [
        'success' => empty($errors),
        'errors' => $errors,
        'message' => empty($errors) ? 'Syntaxe valide' : 'Erreurs de syntaxe détectées'
    ];
    
    echo json_encode($response, JSON_PRETTY_PRINT);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
