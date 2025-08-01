<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

function generateAsteriskDialplan($flowData) {
    $dialplan = ";; Asterisk Dialplan généré automatiquement\n";
    $dialplan .= ";; Généré le " . date('Y-m-d H:i:s') . "\n\n";
    
    $dialplan .= "[svi-flow-main]\n";
    
    // Traiter les nœuds du flow
    if (isset($flowData['nodes']) && is_array($flowData['nodes'])) {
        foreach ($flowData['nodes'] as $node) {
            switch ($node['type']) {
                case 'start':
                    $dialplan .= "exten => start,1,NoOp(Début du flux SVI)\n";
                    $dialplan .= "same => n,Answer()\n";
                    $dialplan .= "same => n,Wait(1)\n";
                    break;
                    
                case 'welcome':
                    $dialplan .= "exten => welcome,1,NoOp(Message de bienvenue)\n";
                    $dialplan .= "same => n,Playback(welcome)\n";
                    break;
                    
                case 'menu':
                    $dialplan .= "exten => menu,1,NoOp(Menu principal)\n";
                    $dialplan .= "same => n,Background(menu-options)\n";
                    $dialplan .= "same => n,WaitExten(10)\n";
                    break;
                    
                case 'transfer':
                    $number = $node['properties']['number'] ?? '100';
                    $dialplan .= "exten => transfer,1,NoOp(Transfert vers {$number})\n";
                    $dialplan .= "same => n,Dial(SIP/{$number},30,tT)\n";
                    $dialplan .= "same => n,Hangup()\n";
                    break;
                    
                case 'end':
                    $dialplan .= "exten => end,1,NoOp(Fin du flux)\n";
                    $dialplan .= "same => n,Hangup()\n";
                    break;
            }
        }
    }
    
    // Gestion des touches du menu
    $dialplan .= "\n;; Gestion des touches du menu\n";
    $dialplan .= "exten => 1,1,Goto(svi-flow-main,transfer,1)\n";
    $dialplan .= "exten => 2,1,Goto(svi-flow-main,welcome,1)\n";
    $dialplan .= "exten => 0,1,Goto(svi-flow-main,end,1)\n";
    $dialplan .= "exten => t,1,Goto(svi-flow-main,end,1)\n";
    $dialplan .= "exten => i,1,Goto(svi-flow-main,menu,1)\n";
    
    return $dialplan;
}

try {
    $input = file_get_contents('php://input');
    $flowData = json_decode($input, true);
    
    if (json_last_error() !== JSON_ERROR_NONE) {
        http_response_code(400);
        echo json_encode(['error' => 'Invalid JSON data']);
        exit;
    }
    
    // Générer le dialplan Asterisk
    $dialplan = generateAsteriskDialplan($flowData);
    
    // Chemin vers le fichier extensions.conf
    $asteriskConfigDir = '/var/www/html/asterisk-config';
    $extensionsFile = $asteriskConfigDir . '/extensions.conf';
    
    // Créer le répertoire s'il n'existe pas
    if (!is_dir($asteriskConfigDir)) {
        mkdir($asteriskConfigDir, 0755, true);
    }
    
    // Sauvegarder le dialplan
    if (file_put_contents($extensionsFile, $dialplan) !== false) {
        // Sauvegarder également le flux JSON
        $flowFile = $asteriskConfigDir . '/flow-data.json';
        file_put_contents($flowFile, json_encode($flowData, JSON_PRETTY_PRINT));
        
        echo json_encode([
            'success' => true,
            'message' => 'Configuration sauvegardée avec succès',
            'dialplan_preview' => $dialplan,
            'timestamp' => date('Y-m-d H:i:s')
        ]);
    } else {
        http_response_code(500);
        echo json_encode([
            'error' => 'Erreur lors de la sauvegarde',
            'details' => 'Impossible d\'écrire dans le fichier de configuration'
        ]);
    }
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'error' => 'Erreur serveur',
        'details' => $e->getMessage()
    ]);
}
?>
