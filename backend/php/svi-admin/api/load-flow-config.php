<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

try {
    $asteriskConfigDir = '/var/www/html/asterisk-config';
    $flowFile = $asteriskConfigDir . '/flow-data.json';
    
    if (file_exists($flowFile)) {
        $flowData = file_get_contents($flowFile);
        $decodedData = json_decode($flowData, true);
        
        if (json_last_error() === JSON_ERROR_NONE) {
            echo json_encode([
                'success' => true,
                'data' => $decodedData,
                'timestamp' => date('Y-m-d H:i:s', filemtime($flowFile))
            ]);
        } else {
            echo json_encode([
                'success' => false,
                'error' => 'Fichier de flux corrompu'
            ]);
        }
    } else {
        echo json_encode([
            'success' => false,
            'error' => 'Aucun flux sauvegardé trouvé'
        ]);
    }
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Erreur serveur',
        'details' => $e->getMessage()
    ]);
}
?>
