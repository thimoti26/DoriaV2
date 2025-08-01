<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER["REQUEST_METHOD"] == "OPTIONS") {
    http_response_code(200);
    exit();
}

$action = $_GET["action"] ?? "";

switch ($action) {
    case "list":
        echo json_encode([
            "status" => "success",
            "users" => [
                [
                    "id" => 1,
                    "username" => "user1001",
                    "extension" => "1001",
                    "secret" => "secret123",
                    "callerid" => "User 1001",
                    "status" => "active"
                ],
                [
                    "id" => 2,
                    "username" => "user1002",
                    "extension" => "1002",
                    "secret" => "secret456",
                    "callerid" => "User 1002",
                    "status" => "active"
                ]
            ]
        ]);
        break;
    
    case "add":
        $input = json_decode(file_get_contents("php://input"), true);
        echo json_encode([
            "status" => "success",
            "message" => "User added successfully",
            "user" => $input
        ]);
        break;
    
    case "update":
        $input = json_decode(file_get_contents("php://input"), true);
        echo json_encode([
            "status" => "success",
            "message" => "User updated successfully",
            "user" => $input
        ]);
        break;
    
    case "delete":
        $id = $_GET["id"] ?? 0;
        echo json_encode([
            "status" => "success",
            "message" => "User deleted successfully",
            "id" => $id
        ]);
        break;
    
    default:
        echo json_encode([
            "status" => "error",
            "message" => "Invalid action"
        ]);
}
