<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

// Configuration de la base de données
$host = 'mysql';
$port = '3306';
$dbname = 'asterisk';
$username = 'doriav2_user';
$password = 'doriav2_password';

try {
    $pdo = new PDO("mysql:host=$host;port=$port;dbname=$dbname;charset=utf8", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    $action = $_GET['action'] ?? 'list';
    $period = $_GET['period'] ?? 'month';
    $status = $_GET['status'] ?? 'all';
    $limit = intval($_GET['limit'] ?? 50);
    $offset = intval($_GET['offset'] ?? 0);
    
    // Construction de la clause WHERE selon la période
    $whereClause = "WHERE 1=1";
    
    switch ($period) {
        case 'today':
            $whereClause .= " AND DATE(call_start) = CURDATE()";
            break;
        case 'yesterday':
            $whereClause .= " AND DATE(call_start) = DATE_SUB(CURDATE(), INTERVAL 1 DAY)";
            break;
        case 'week':
            $whereClause .= " AND call_start >= DATE_SUB(NOW(), INTERVAL 1 WEEK)";
            break;
        case 'month':
            $whereClause .= " AND call_start >= DATE_SUB(NOW(), INTERVAL 1 MONTH)";
            break;
    }
    
    // Filtrage par statut
    if ($status !== 'all') {
        $whereClause .= " AND hangup_status = '$status'";
    }
    
    if ($action === 'stats') {
        // Statistiques
        $sql = "SELECT COUNT(*) as total FROM svi_call_history $whereClause";
        $stmt = $pdo->prepare($sql);
        $stmt->execute();
        $total = $stmt->fetch(PDO::FETCH_ASSOC)['total'];
        
        $sql = "SELECT hangup_status, COUNT(*) as count FROM svi_call_history $whereClause GROUP BY hangup_status";
        $stmt = $pdo->prepare($sql);
        $stmt->execute();
        $by_status_raw = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        // Formatage des statuts
        $by_status = array_map(function($row) {
            return [
                'status' => translateCallStatus($row['hangup_status']),
                'status_raw' => $row['hangup_status'],
                'count' => intval($row['count'])
            ];
        }, $by_status_raw);
        
        echo json_encode([
            'success' => true,
            'stats' => [
                'total_calls' => $total,
                'by_status' => $by_status,
                'by_language' => [['language_selected' => 'FR', 'count' => $total]]
            ]
        ]);
    } elseif ($action === 'export') {
        // Export CSV
        $sql = "SELECT * FROM svi_call_history $whereClause ORDER BY call_start DESC";
        $stmt = $pdo->prepare($sql);
        $stmt->execute();
        $calls = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        header('Content-Type: text/csv; charset=utf-8');
        header('Content-Disposition: attachment; filename="historique_appels_svi_' . date('Y-m-d_H-i-s') . '.csv"');
        
        $output = fopen('php://output', 'w');
        
        // En-têtes CSV
        fputcsv($output, ['Date/Heure', 'Numéro', 'Durée (sec)', 'Statut', 'Parcours SVI'], ';');
        
        // Données
        foreach ($calls as $call) {
            fputcsv($output, [
                $call['call_start'],
                $call['phone_number'],
                $call['duration'],
                $call['hangup_status'],
                $call['svi_path']
            ], ';');
        }
        
        fclose($output);
        exit;
    } else {
        // Liste des appels
        $sql = "SELECT * FROM svi_call_history $whereClause ORDER BY call_start DESC LIMIT $limit OFFSET $offset";
        $stmt = $pdo->prepare($sql);
        $stmt->execute();
        $calls = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        // Compter le total
        $countSql = "SELECT COUNT(*) as total FROM svi_call_history $whereClause";
        $countStmt = $pdo->prepare($countSql);
        $countStmt->execute();
        $total = $countStmt->fetch(PDO::FETCH_ASSOC)['total'];
        
        // Formater les données
        $enrichedCalls = array_map(function($call) {
            return [
                'id' => $call['id'],
                'date' => $call['call_start'],
                'caller' => formatPhoneNumber($call['phone_number']),
                'called' => 'SVI Système',
                'duration' => formatDuration($call['duration']),
                'status' => translateCallStatus($call['hangup_status']),
                'status_raw' => $call['hangup_status'],
                'svi_path' => $call['svi_path'],
                'call_end' => $call['call_end']
            ];
        }, $calls);
        
        echo json_encode([
            'success' => true,
            'data' => $enrichedCalls,
            'pagination' => [
                'total' => intval($total),
                'limit' => $limit,
                'offset' => $offset
            ]
        ]);
    }
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}

function formatPhoneNumber($number) {
    if (empty($number)) return 'Inconnu';
    $cleaned = preg_replace('/[^\d+]/', '', $number);
    if (strlen($cleaned) == 10 && $cleaned[0] == '0') {
        return substr($cleaned, 0, 2) . ' ' . substr($cleaned, 2, 2) . ' ' . 
               substr($cleaned, 4, 2) . ' ' . substr($cleaned, 6, 2) . ' ' . 
               substr($cleaned, 8, 2);
    }
    return $cleaned;
}

function formatDuration($seconds) {
    if ($seconds < 60) {
        return $seconds . 's';
    } elseif ($seconds < 3600) {
        return floor($seconds / 60) . 'm ' . ($seconds % 60) . 's';
    } else {
        $hours = floor($seconds / 3600);
        $minutes = floor(($seconds % 3600) / 60);
        $secs = $seconds % 60;
        return $hours . 'h ' . $minutes . 'm ' . $secs . 's';
    }
}

function translateCallStatus($status) {
    $translations = [
        'completed' => 'Terminé',
        'timeout' => 'Délai expiré',
        'abandoned' => 'Abandonné',
        'busy' => 'Occupé',
        'no_answer' => 'Non répondu',
        'failed' => 'Échec'
    ];
    return $translations[$status] ?? $status;
}
?>
