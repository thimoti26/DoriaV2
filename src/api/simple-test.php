<?php
header('Content-Type: application/json');
echo json_encode(['message' => 'API is working', 'timestamp' => date('Y-m-d H:i:s')]);
?>
