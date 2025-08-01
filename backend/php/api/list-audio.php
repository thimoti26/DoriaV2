<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER["REQUEST_METHOD"] == "OPTIONS") {
    http_response_code(200);
    exit();
}

// Simuler une liste de fichiers audio
$audioFiles = [
    [
        "id" => 1,
        "name" => "welcome.wav",
        "path" => "/var/lib/asterisk/sounds/custom/welcome.wav",
        "duration" => "5s",
        "size" => "245KB"
    ],
    [
        "id" => 2,
        "name" => "menu-principal.wav",
        "path" => "/var/lib/asterisk/sounds/custom/menu-principal.wav",
        "duration" => "8s",
        "size" => "387KB"
    ],
    [
        "id" => 3,
        "name" => "goodbye.wav",
        "path" => "/var/lib/asterisk/sounds/custom/goodbye.wav",
        "duration" => "3s",
        "size" => "156KB"
    ],
    [
        "id" => 4,
        "name" => "invalid-option.wav",
        "path" => "/var/lib/asterisk/sounds/custom/invalid-option.wav",
        "duration" => "4s",
        "size" => "198KB"
    ]
];

echo json_encode([
    "status" => "success",
    "audio_files" => $audioFiles,
    "total" => count($audioFiles)
]);
