<?php
header("Content-Type: application/json");
$input = file_get_contents("php://input");
echo json_encode(["debug" => "received", "input" => $input]);
?>
