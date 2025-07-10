<?php
/**
 * DoriaV2 - SIP Users API
 * RESTful API for managing SIP users
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Handle preflight OPTIONS requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Database configuration
$db_config = [
    'host' => $_ENV['DB_HOST'] ?? 'mysql',
    'dbname' => $_ENV['DB_NAME'] ?? 'doriav2',
    'username' => $_ENV['DB_USER'] ?? 'doriav2_user',
    'password' => $_ENV['DB_PASSWORD'] ?? 'doriav2_password'
];

try {
    $dsn = "mysql:host={$db_config['host']};dbname={$db_config['dbname']};charset=utf8mb4";
    $pdo = new PDO($dsn, $db_config['username'], $db_config['password'], [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Database connection failed: ' . $e->getMessage()]);
    exit();
}

// Parse request path
$request_uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$path_parts = explode('/', trim($request_uri, '/'));
$user_id = null;

// Extract user ID from path if present
if (count($path_parts) > 2 && is_numeric($path_parts[2])) {
    $user_id = (int)$path_parts[2];
}

$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        if ($user_id) {
            getSingleUser($pdo, $user_id);
        } else {
            getAllUsers($pdo);
        }
        break;
    
    case 'POST':
        createUser($pdo);
        break;
    
    case 'PUT':
        if ($user_id) {
            updateUser($pdo, $user_id);
        } else {
            http_response_code(400);
            echo json_encode(['success' => false, 'error' => 'User ID required for update']);
        }
        break;
    
    case 'DELETE':
        if ($user_id) {
            deleteUser($pdo, $user_id);
        } else {
            http_response_code(400);
            echo json_encode(['success' => false, 'error' => 'User ID required for deletion']);
        }
        break;
    
    default:
        http_response_code(405);
        echo json_encode(['success' => false, 'error' => 'Method not allowed']);
        break;
}

function getAllUsers($pdo) {
    try {
        $stmt = $pdo->query("
            SELECT id, username as name, email, username as extension, 
                   'N/A' as department, created_at
            FROM users 
            WHERE role = 'sip_user' OR role IS NULL
            ORDER BY created_at DESC
        ");
        $users = $stmt->fetchAll();
        
        echo json_encode(['success' => true, 'data' => $users]);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['success' => false, 'error' => $e->getMessage()]);
    }
}

function getSingleUser($pdo, $user_id) {
    try {
        $stmt = $pdo->prepare("
            SELECT id, username as name, email, username as extension, 
                   'N/A' as department, created_at
            FROM users 
            WHERE id = ? AND (role = 'sip_user' OR role IS NULL)
        ");
        $stmt->execute([$user_id]);
        $user = $stmt->fetch();
        
        if ($user) {
            echo json_encode(['success' => true, 'data' => $user]);
        } else {
            http_response_code(404);
            echo json_encode(['success' => false, 'error' => 'User not found']);
        }
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['success' => false, 'error' => $e->getMessage()]);
    }
}

function createUser($pdo) {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input || !isset($input['name'], $input['email'], $input['extension'])) {
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'Missing required fields: name, email, extension']);
        return;
    }
    
    try {
        // Generate SIP password
        $sip_password = 'sip' . $input['extension'] . rand(100, 999);
        $password_hash = password_hash($sip_password, PASSWORD_DEFAULT);
        
        $stmt = $pdo->prepare("
            INSERT INTO users (username, email, password_hash, first_name, last_name, role, created_at)
            VALUES (?, ?, ?, ?, '', 'sip_user', NOW())
        ");
        
        $stmt->execute([
            $input['extension'],
            $input['email'],
            $password_hash,
            $input['name']
        ]);
        
        $new_user_id = $pdo->lastInsertId();
        
        echo json_encode([
            'success' => true,
            'data' => [
                'id' => $new_user_id,
                'sip_password' => $sip_password,
                'extension' => $input['extension']
            ],
            'message' => 'User created successfully'
        ]);
        
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['success' => false, 'error' => $e->getMessage()]);
    }
}

function updateUser($pdo, $user_id) {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input) {
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'Invalid JSON input']);
        return;
    }
    
    try {
        $stmt = $pdo->prepare("
            UPDATE users 
            SET username = ?, email = ?, first_name = ?, updated_at = NOW()
            WHERE id = ? AND (role = 'sip_user' OR role IS NULL)
        ");
        
        $stmt->execute([
            $input['extension'] ?? $input['name'],
            $input['email'],
            $input['name'],
            $user_id
        ]);
        
        if ($stmt->rowCount() > 0) {
            echo json_encode(['success' => true, 'message' => 'User updated successfully']);
        } else {
            http_response_code(404);
            echo json_encode(['success' => false, 'error' => 'User not found']);
        }
        
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['success' => false, 'error' => $e->getMessage()]);
    }
}

function deleteUser($pdo, $user_id) {
    try {
        $stmt = $pdo->prepare("
            DELETE FROM users 
            WHERE id = ? AND (role = 'sip_user' OR role IS NULL)
        ");
        
        $stmt->execute([$user_id]);
        
        if ($stmt->rowCount() > 0) {
            echo json_encode(['success' => true, 'message' => 'User deleted successfully']);
        } else {
            http_response_code(404);
            echo json_encode(['success' => false, 'error' => 'User not found']);
        }
        
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['success' => false, 'error' => $e->getMessage()]);
    }
}
?>
