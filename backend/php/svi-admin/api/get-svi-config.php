<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

require_once '../includes/ExtensionsParser.php';

try {
    // Chemin vers le fichier extensions.conf
    $extensionsFile = '/var/www/html/asterisk-config/extensions.conf';
    
    if (!file_exists($extensionsFile)) {
        throw new Exception("Fichier extensions.conf non trouvé: $extensionsFile");
    }
    
    $parser = new ExtensionsParser($extensionsFile);
    $sviStructure = $parser->parseSviStructure();
    
    // Ajouter des métadonnées
    $response = [
        'success' => true,
        'data' => $sviStructure,
        'metadata' => [
            'file' => $extensionsFile,
            'lastModified' => filemtime($extensionsFile),
            'size' => filesize($extensionsFile)
        ]
    ];
    
    echo json_encode($response, JSON_PRETTY_PRINT);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
