<?php
header('Content-Type: application/json');
echo json_encode(['test' => 'success', 'timestamp' => date('Y-m-d H:i:s')]);
?>
