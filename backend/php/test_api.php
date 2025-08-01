<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

echo "API endpoint reached\n";

try {
    $mysql_host = $_ENV['DB_HOST'] ?? 'mysql';
    $mysql_db = $_ENV['DB_NAME'] ?? 'doriav2';
    $mysql_user = $_ENV['DB_USER'] ?? 'doriav2_user';
    $mysql_pass = $_ENV['DB_PASSWORD'] ?? 'doriav2_password';
    
    echo "Connecting to database...\n";
    $dsn = "mysql:host={$mysql_host};dbname={$mysql_db};charset=utf8mb4";
    $pdo = new PDO($dsn, $mysql_user, $mysql_pass);
    echo "Database connected successfully\n";
    
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM users WHERE role = 'sip_user'");
    $result = $stmt->fetch();
    echo "SIP users count: " . $result['count'] . "\n";
    
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
?>
