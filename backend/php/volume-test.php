<?php
header('Content-Type: application/json');

// Test de la configuration avec volumes
echo json_encode([
    'status' => 'success',
    'message' => 'Volume configuration test - Web files mounted successfully!',
    'timestamp' => date('Y-m-d H:i:s'),
    'server' => $_SERVER['SERVER_NAME'] ?? 'localhost',
    'php_version' => phpversion(),
    'test_modification' => 'Modified from host filesystem via volume mount'
], JSON_PRETTY_PRINT);
?>
