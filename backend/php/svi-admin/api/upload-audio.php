<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

try {
    if (!isset($_FILES['audioFile']) || !isset($_POST['language'])) {
        throw new Exception("Fichier audio ou langue manquant");
    }
    
    $file = $_FILES['audioFile'];
    $language = $_POST['language'];
    
    // Validation de la langue
    if (!in_array($language, ['fr', 'en'])) {
        throw new Exception("Langue non supportée: $language");
    }
    
    // Validation du fichier
    if ($file['error'] !== UPLOAD_ERR_OK) {
        throw new Exception("Erreur lors de l'upload: " . $file['error']);
    }
    
    // Vérifier l'extension
    $fileInfo = pathinfo($file['name']);
    if (strtolower($fileInfo['extension']) !== 'wav') {
        throw new Exception("Seuls les fichiers WAV sont autorisés");
    }
    
    // Vérifier le type MIME
    $mimeType = mime_content_type($file['tmp_name']);
    if (!in_array($mimeType, ['audio/wav', 'audio/x-wav', 'audio/wave'])) {
        throw new Exception("Type de fichier invalide. WAV requis.");
    }
    
    // Nom du fichier sécurisé
    $fileName = preg_replace('/[^a-zA-Z0-9_.-]/', '', basename($file['name'], '.wav')) . '.wav';
    
    // Dossiers de destination
    $uploadDir = "../uploads/$language/";
    
    // Créer les dossiers si nécessaires
    if (!is_dir($uploadDir)) {
        mkdir($uploadDir, 0755, true);
    }
    
    $uploadPath = $uploadDir . $fileName;
    
    // Déplacer le fichier directement vers le dossier uploads (qui est lié à Asterisk)
    if (!move_uploaded_file($file['tmp_name'], $uploadPath)) {
        throw new Exception("Impossible de sauvegarder le fichier");
    }
    
    $response = [
        'success' => true,
        'message' => 'Fichier audio uploadé avec succès',
        'data' => [
            'fileName' => $fileName,
            'language' => $language,
            'size' => filesize($uploadPath),
            'path' => $uploadPath
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
