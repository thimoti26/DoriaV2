<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER["REQUEST_METHOD"] == "OPTIONS") {
    http_response_code(200);
    exit();
}

echo json_encode([
    "status" => "success",
    "message" => "API connection test successful",
    "timestamp" => date("Y-m-d H:i:s"),
    "server" => "DoriaV2 Backend"
]);
