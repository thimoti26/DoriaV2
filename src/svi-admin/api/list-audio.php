<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

try {
    $audioFiles = ['fr' => [], 'en' => []];
    
    // Scanner les dossiers audio
    foreach (['fr', 'en'] as $lang) {
        $uploadDir = "../uploads/$lang/";
        $asteriskDir = "/var/www/html/asterisk-sounds/custom/$lang/";
        
        // Créer les dossiers s'ils n'existent pas
        if (!is_dir($uploadDir)) {
            mkdir($uploadDir, 0755, true);
        }
        
        // Scanner le dossier upload
        if (is_dir($uploadDir)) {
            $files = glob($uploadDir . "*.wav");
            foreach ($files as $file) {
                $fileName = basename($file);
                $audioFiles[$lang][] = [
                    'name' => $fileName,
                    'language' => $lang,
                    'path' => "uploads/$lang/$fileName",
                    'size' => filesize($file),
                    'lastModified' => filemtime($file)
                ];
            }
        }
        
        // Scanner aussi le dossier Asterisk pour les fichiers existants
        if (is_dir($asteriskDir)) {
            $files = glob($asteriskDir . "*.wav");
            foreach ($files as $file) {
                $fileName = basename($file);
                
                // Éviter les doublons
                $exists = false;
                foreach ($audioFiles[$lang] as $existing) {
                    if ($existing['name'] === $fileName) {
                        $exists = true;
                        break;
                    }
                }
                
                if (!$exists) {
                    $audioFiles[$lang][] = [
                        'name' => $fileName,
                        'language' => $lang,
                        'path' => "uploads/$lang/$fileName",
                        'size' => filesize($file),
                        'lastModified' => filemtime($file),
                        'source' => 'asterisk'
                    ];
                }
            }
        }
    }
    
    $response = [
        'success' => true,
        'data' => $audioFiles,
        'total' => count($audioFiles['fr']) + count($audioFiles['en'])
    ];
    
    echo json_encode($response, JSON_PRETTY_PRINT);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
