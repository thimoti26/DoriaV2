<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST');
header('Access-Control-Allow-Headers: Content-Type');

// Répertoire des tests
$testsDir = '/var/www/tests';

// Liste des tests disponibles avec leurs descriptions
$availableTests = [
    // Tests système
    'system' => [
        'test-stack.sh' => 'Test complet de la pile Docker',
        'test-volumes.sh' => 'Test des volumes Docker',
        'test-final.sh' => 'Test final du système'
    ],
    
    // Tests SVI
    'svi' => [
        'test-svi-fonctionnel.sh' => 'Test fonctionnel du SVI',
        'test-svi-multilingual.sh' => 'Test SVI multilingue',
        'test-svi-navigation.sh' => 'Test navigation SVI',
        'test-svi-navigation-fixed.sh' => 'Test navigation SVI (version corrigée)',
        'test-svi-navigation-new.sh' => 'Test navigation SVI (nouvelle version)',
        'test-svi-paths.sh' => 'Test des chemins SVI',
        'svi/test-svi-improvements.sh' => 'Test des améliorations SVI'
    ],
    
    // Tests interface
    'interface' => [
        'test-interface-final.sh' => 'Test final de l\'interface',
        'test-interface-moderne.sh' => 'Test interface moderne',
        'test-interface-v2.sh' => 'Test interface v2'
    ],
    
    // Tests audio
    'audio' => [
        'test-audio-auto.sh' => 'Test audio automatique',
        'debug-audio.sh' => 'Debug audio'
    ],
    
    // Tests réseau
    'network' => [
        'test-linphone.sh' => 'Test Linphone',
        'network/test-network.sh' => 'Test réseau'
    ],
    
    // Tests de validation
    'validation' => [
        'test-complete.sh' => 'Test complet',
        'test-fonctionnel.sh' => 'Test fonctionnel',
        'test-validation-finale.sh' => 'Test de validation finale'
    ],
    
    // Tests de debug
    'debug' => [
        'debug/test-drag-drop.sh' => 'Debug drag & drop',
        'debug/test-tabs-debug.sh' => 'Debug onglets',
        'debug/test-tabs-quick.sh' => 'Test rapide onglets'
    ]
];

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Retourner la liste des tests disponibles
    echo json_encode([
        'success' => true,
        'tests' => $availableTests
    ]);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($input['test'])) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'error' => 'Paramètre test manquant'
        ]);
        exit;
    }
    
    $testFile = $input['test'];
    
    // Si le testFile contient déjà un slash, c'est un chemin de catégorie/fichier
    if (strpos($testFile, '/') !== false) {
        $testPath = $testsDir . '/' . $testFile;
    } else {
        // Rechercher le test dans toutes les catégories
        $testPath = null;
        foreach ($availableTests as $category => $tests) {
            if (isset($tests[$testFile])) {
                $testPath = $testsDir . '/' . $testFile;
                break;
            }
        }
        if (!$testPath) {
            $testPath = $testsDir . '/' . $testFile;
        }
    }
    
    // Vérifier que le fichier de test existe
    if (!file_exists($testPath)) {
        http_response_code(404);
        echo json_encode([
            'success' => false,
            'error' => 'Test non trouvé: ' . $testFile
        ]);
        exit;
    }
    
    // Vérifier que le fichier est exécutable
    if (!is_executable($testPath)) {
        chmod($testPath, 0755);
    }
    
    // Capturer le répertoire de travail actuel
    $originalDir = getcwd();
    
    // Changer vers le répertoire du projet
    chdir('/var/www/html/..');
    
    // Exécuter le test avec capture des sorties
    $startTime = microtime(true);
    $output = [];
    $returnCode = 0;
    
    // Exécuter la commande et capturer la sortie
    $command = "bash " . escapeshellarg($testPath) . " 2>&1";
    exec($command, $output, $returnCode);
    
    $endTime = microtime(true);
    $duration = round($endTime - $startTime, 2);
    
    // Restaurer le répertoire de travail
    chdir($originalDir);
    
    // Déterminer le statut
    $status = $returnCode === 0 ? 'success' : 'failure';
    
    // Analyser la sortie pour extraire des informations utiles
    $outputText = implode("\n", $output);
    $summary = extractTestSummary($outputText, $returnCode);
    
    echo json_encode([
        'success' => true,
        'test' => $testFile,
        'status' => $status,
        'return_code' => $returnCode,
        'duration' => $duration,
        'output' => $outputText,
        'summary' => $summary,
        'timestamp' => date('Y-m-d H:i:s')
    ]);
    exit;
}

function extractTestSummary($output, $returnCode) {
    $lines = explode("\n", $output);
    $summary = [
        'total_tests' => 0,
        'passed' => 0,
        'failed' => 0,
        'errors' => [],
        'warnings' => []
    ];
    
    foreach ($lines as $line) {
        // Détecter les tests passés
        if (preg_match('/✅|PASS|SUCCESS|OK/', $line)) {
            $summary['passed']++;
            $summary['total_tests']++;
        }
        
        // Détecter les tests échoués
        if (preg_match('/❌|FAIL|ERROR|ERREUR/', $line)) {
            $summary['failed']++;
            $summary['total_tests']++;
            $summary['errors'][] = trim($line);
        }
        
        // Détecter les avertissements
        if (preg_match('/⚠️|WARNING|WARN/', $line)) {
            $summary['warnings'][] = trim($line);
        }
    }
    
    // Si aucun test détecté mais code de retour non-zéro
    if ($summary['total_tests'] === 0 && $returnCode !== 0) {
        $summary['failed'] = 1;
        $summary['total_tests'] = 1;
        $summary['errors'][] = "Test terminé avec le code de retour: $returnCode";
    }
    
    // Si aucun test détecté mais code de retour zéro
    if ($summary['total_tests'] === 0 && $returnCode === 0) {
        $summary['passed'] = 1;
        $summary['total_tests'] = 1;
    }
    
    return $summary;
}
?>
