<?php
/**
 * DoriaV2 - Connection Test Script
 * Tests connectivity to MySQL and Redis
 */

header('Content-Type: application/json');

$results = [
    'mysql' => ['status' => 'error', 'message' => ''],
    'redis' => ['status' => 'error', 'message' => ''],
    'timestamp' => date('Y-m-d H:i:s')
];

// Test MySQL Connection
try {
    $mysql_host = $_ENV['DB_HOST'] ?? 'mysql';
    $mysql_db = $_ENV['DB_NAME'] ?? 'doriav2';
    $mysql_user = $_ENV['DB_USER'] ?? 'doriav2_user';
    $mysql_pass = $_ENV['DB_PASSWORD'] ?? 'doriav2_password';
    
    $dsn = "mysql:host={$mysql_host};dbname={$mysql_db};charset=utf8mb4";
    $pdo = new PDO($dsn, $mysql_user, $mysql_pass, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);
    
    // Test query
    $stmt = $pdo->query("SELECT COUNT(*) as table_count FROM information_schema.tables WHERE table_schema = '{$mysql_db}'");
    $row = $stmt->fetch();
    
    $results['mysql']['status'] = 'success';
    $results['mysql']['message'] = "Connected successfully. Database has {$row['table_count']} tables.";
    $results['mysql']['host'] = $mysql_host;
    $results['mysql']['database'] = $mysql_db;
} catch (Exception $e) {
    $results['mysql']['message'] = "Connection failed: " . $e->getMessage();
}

// Test Redis Connection
try {
    $redis_host = $_ENV['REDIS_HOST'] ?? 'redis';
    $redis_pass = $_ENV['REDIS_PASSWORD'] ?? 'doriav2_redis_password';
    
    // Using basic socket connection since Redis extension might not be installed
    $redis_socket = fsockopen($redis_host, 6379, $errno, $errstr, 10);
    if (!$redis_socket) {
        throw new Exception("Cannot connect to Redis: {$errstr}");
    }
    
    // Send AUTH command
    fwrite($redis_socket, "AUTH {$redis_pass}\r\n");
    $auth_response = trim(fgets($redis_socket));
    
    if ($auth_response !== '+OK') {
        throw new Exception("Redis authentication failed");
    }
    
    // Send PING command
    fwrite($redis_socket, "PING\r\n");
    $ping_response = trim(fgets($redis_socket));
    
    if ($ping_response !== '+PONG') {
        throw new Exception("Redis PING failed");
    }
    
    fclose($redis_socket);
    
    $results['redis']['status'] = 'success';
    $results['redis']['message'] = "Connected successfully. PING response: PONG";
    $results['redis']['host'] = $redis_host;
} catch (Exception $e) {
    $results['redis']['message'] = "Connection failed: " . $e->getMessage();
}

// Output results
echo json_encode($results, JSON_PRETTY_PRINT);
?>
