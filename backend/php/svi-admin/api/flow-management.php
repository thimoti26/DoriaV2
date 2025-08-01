<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST');
header('Access-Control-Allow-Headers: Content-Type');

class FlowManagementAPI {
    private $flowsDir;
    private $extensionsConfigPath;
    
    public function __construct() {
        $this->flowsDir = '/var/www/html/flows';
        $this->extensionsConfigPath = '/var/www/html/asterisk-config/extensions.conf';
        
        // Créer le répertoire des flux s'il n'existe pas
        if (!is_dir($this->flowsDir)) {
            mkdir($this->flowsDir, 0755, true);
        }
    }
    
    public function handleRequest() {
        try {
            $method = $_SERVER['REQUEST_METHOD'];
            
            if ($method === 'GET') {
                $action = $_GET['action'] ?? '';
                switch ($action) {
                    case 'list':
                        return $this->listFlows();
                    case 'load':
                        return $this->loadFlow($_GET['id'] ?? '');
                    default:
                        throw new Exception("Action GET non supportée: " . $action);
                }
            } elseif ($method === 'POST') {
                $input = json_decode(file_get_contents('php://input'), true);
                $action = $input['action'] ?? '';
                
                switch ($action) {
                    case 'save':
                        return $this->saveFlow($input['flowData'] ?? []);
                    case 'generate':
                        return $this->generateAsteriskCode($input['flowData'] ?? []);
                    case 'deploy':
                        return $this->deployFlow($input['flowData'] ?? []);
                    default:
                        throw new Exception("Action POST non supportée: " . $action);
                }
            } else {
                throw new Exception("Méthode HTTP non supportée: " . $method);
            }
        } catch (Exception $e) {
            http_response_code(500);
            return [
                'success' => false,
                'error' => $e->getMessage()
            ];
        }
    }
    
    private function saveFlow($flowData) {
        $flowId = 'flow_' . date('Y_m_d_H_i_s');
        $flowFile = $this->flowsDir . '/' . $flowId . '.json';
        
        $flowMetadata = [
            'id' => $flowId,
            'name' => 'Flux SVI ' . date('d/m/Y H:i'),
            'created' => date('Y-m-d H:i:s'),
            'nodes' => $flowData['nodes'] ?? [],
            'connections' => $flowData['connections'] ?? []
        ];
        
        if (file_put_contents($flowFile, json_encode($flowMetadata, JSON_PRETTY_PRINT))) {
            return [
                'success' => true,
                'message' => "Flux sauvegardé avec l'ID: $flowId",
                'flowId' => $flowId
            ];
        } else {
            throw new Exception("Impossible de sauvegarder le flux");
        }
    }
    
    private function listFlows() {
        $flows = [];
        $files = glob($this->flowsDir . '/*.json');
        
        foreach ($files as $file) {
            $content = json_decode(file_get_contents($file), true);
            if ($content) {
                $flows[] = [
                    'id' => $content['id'],
                    'name' => $content['name'],
                    'created' => $content['created'],
                    'nodeCount' => count($content['nodes'] ?? [])
                ];
            }
        }
        
        return [
            'success' => true,
            'flows' => $flows
        ];
    }
    
    private function loadFlow($flowId) {
        $flowFile = $this->flowsDir . '/' . $flowId . '.json';
        
        if (!file_exists($flowFile)) {
            throw new Exception("Flux non trouvé: $flowId");
        }
        
        $flowData = json_decode(file_get_contents($flowFile), true);
        
        return [
            'success' => true,
            'flowData' => $flowData
        ];
    }
    
    private function generateAsteriskCode($flowData) {
        $nodes = $flowData['nodes'] ?? [];
        $connections = $flowData['connections'] ?? [];
        
        // Construire le graphe des connexions
        $nodeMap = [];
        foreach ($nodes as $node) {
            $nodeMap[$node['id']] = $node;
        }
        
        $connectionMap = [];
        foreach ($connections as $connection) {
            if (!isset($connectionMap[$connection['fromNodeId']])) {
                $connectionMap[$connection['fromNodeId']] = [];
            }
            $connectionMap[$connection['fromNodeId']][] = $connection;
        }
        
        // Trouver le nœud de départ
        $startNode = null;
        foreach ($nodes as $node) {
            if ($node['type'] === 'start') {
                $startNode = $node;
                break;
            }
        }
        
        if (!$startNode) {
            throw new Exception("Aucun nœud de départ trouvé dans le flux");
        }
        
        // Générer le code
        $code = $this->generateExtensionsConf($startNode, $nodeMap, $connectionMap);
        
        return [
            'success' => true,
            'asteriskCode' => $code
        ];
    }
    
    private function generateExtensionsConf($startNode, $nodeMap, $connectionMap) {
        $context = $startNode['properties']['context'] ?? 'from-internal';
        $extension = '9999'; // Extension par défaut pour le SVI
        
        $code = ";; Code Asterisk généré automatiquement\n";
        $code .= ";; Généré le " . date('d/m/Y à H:i:s') . "\n\n";
        $code .= "[$context]\n";
        $code .= "exten => $extension,1,NoOp(Début du flux SVI)\n";
        
        $priority = 2;
        $code .= $this->generateNodeCode($startNode, $nodeMap, $connectionMap, $extension, $priority);
        
        return $code;
    }
    
    private function generateNodeCode($node, $nodeMap, $connectionMap, $extension, &$priority) {
        $code = "";
        $nodeId = $node['id'];
        $type = $node['type'];
        $props = $node['properties'];
        
        switch ($type) {
            case 'start':
                // Le nœud start ne génère pas de code, on passe aux suivants
                break;
                
            case 'say':
                if (!empty($props['audioFile'])) {
                    $code .= "exten => $extension,$priority,Playback({$props['audioFile']})\n";
                } else {
                    $message = str_replace('"', '\\"', $props['message'] ?? 'Message');
                    $voice = $props['voice'] ?? 'fr';
                    $code .= "exten => $extension,$priority,SayText(\"$message\")\n";
                }
                $priority++;
                break;
                
            case 'menu':
                $message = addslashes($props['message'] ?? 'Choisissez une option');
                $timeout = $props['timeout'] ?? 5;
                $retries = $props['retries'] ?? 3;
                
                $code .= "exten => $extension,$priority,Background($message)\n";
                $priority++;
                $code .= "exten => $extension,$priority,WaitExten($timeout)\n";
                $priority++;
                
                // Générer les options du menu
                if (isset($props['options']) && is_array($props['options'])) {
                    foreach ($props['options'] as $option) {
                        $key = $option['key'] ?? '1';
                        $code .= "\n; Option {$option['label']}\n";
                        $code .= "exten => $key,1,NoOp(Option {$option['label']} sélectionnée)\n";
                        
                        // Trouver la connexion correspondante à cette option
                        $nextNode = $this->findNextNodeForMenuOption($nodeId, $key, $connectionMap, $nodeMap);
                        if ($nextNode) {
                            $optionPriority = 2;
                            $code .= $this->generateNodeCode($nextNode, $nodeMap, $connectionMap, $key, $optionPriority);
                        }
                    }
                }
                
                // Gestion timeout et invalid
                $code .= "\nexten => t,1,NoOp(Timeout)\n";
                $code .= "exten => t,2,Goto($extension,1)\n";
                $code .= "exten => i,1,NoOp(Choix invalide)\n";
                $code .= "exten => i,2,Goto($extension,1)\n";
                break;
                
            case 'input':
                $message = addslashes($props['message'] ?? 'Veuillez saisir votre choix');
                $minDigits = $props['minDigits'] ?? 1;
                $maxDigits = $props['maxDigits'] ?? 10;
                $timeout = $props['timeout'] ?? 5;
                $variable = $props['variable'] ?? 'user_input';
                
                $code .= "exten => $extension,$priority,Background($message)\n";
                $priority++;
                $code .= "exten => $extension,$priority,Read($variable,silence,$maxDigits,,$timeout,$minDigits)\n";
                $priority++;
                break;
                
            case 'condition':
                $variable = $props['variable'] ?? 'user_input';
                $operator = $props['operator'] ?? 'equals';
                $value = $props['value'] ?? '1';
                
                $condition = $this->generateCondition($variable, $operator, $value);
                $code .= "exten => $extension,$priority,GotoIf($condition?{$extension},$priority+2:{$extension},$priority+4)\n";
                $priority++;
                $code .= "exten => $extension,$priority,NoOp(Condition vraie)\n";
                $priority++;
                // Ici on ajouterait le code pour la branche vraie
                $code .= "exten => $extension,$priority,NoOp(Condition fausse)\n";
                $priority++;
                break;
                
            case 'transfer':
                $destination = $props['destination'] ?? '100';
                $context = $props['context'] ?? 'from-internal';
                $timeout = $props['timeout'] ?? 30;
                
                $code .= "exten => $extension,$priority,Dial(SIP/$destination@$context,$timeout)\n";
                $priority++;
                break;
                
            case 'hangup':
                $cause = $props['cause'] ?? 'normal';
                $code .= "exten => $extension,$priority,Hangup($cause)\n";
                $priority++;
                return $code; // Arrêter ici
        }
        
        // Continuer avec les nœuds suivants (sauf pour hangup et menu qui gèrent leurs propres suivants)
        if ($type !== 'hangup' && $type !== 'menu') {
            $connections = $connectionMap[$nodeId] ?? [];
            foreach ($connections as $connection) {
                $nextNode = $nodeMap[$connection['toNodeId']] ?? null;
                if ($nextNode) {
                    $code .= $this->generateNodeCode($nextNode, $nodeMap, $connectionMap, $extension, $priority);
                    break; // Prendre seulement la première connexion pour les nœuds simples
                }
            }
        }
        
        return $code;
    }
    
    private function findNextNodeForMenuOption($menuNodeId, $optionKey, $connectionMap, $nodeMap) {
        $connections = $connectionMap[$menuNodeId] ?? [];
        
        // Pour l'instant, on prend les connexions dans l'ordre
        // Dans une version plus avancée, on pourrait étiqueter les connexions avec l'option
        if (!empty($connections)) {
            $index = intval($optionKey) - 1;
            if (isset($connections[$index])) {
                return $nodeMap[$connections[$index]['toNodeId']] ?? null;
            }
        }
        
        return null;
    }
    
    private function generateCondition($variable, $operator, $value) {
        switch ($operator) {
            case 'equals':
                return "\${$variable}=$value";
            case 'not_equals':
                return "\${$variable}!=$value";
            case 'greater':
                return "\${$variable}>$value";
            case 'less':
                return "\${$variable}<$value";
            default:
                return "\${$variable}=$value";
        }
    }
    
    private function deployFlow($flowData) {
        // Générer le code
        $result = $this->generateAsteriskCode($flowData);
        if (!$result['success']) {
            throw new Exception("Erreur lors de la génération du code");
        }
        
        $asteriskCode = $result['asteriskCode'];
        
        // Sauvegarder le code dans le fichier extensions.conf
        $this->backupExtensionsConf();
        
        // Ajouter le nouveau code
        $existingConfig = file_get_contents($this->extensionsConfigPath);
        $newConfig = $existingConfig . "\n\n" . $asteriskCode;
        
        if (file_put_contents($this->extensionsConfigPath, $newConfig)) {
            // Recharger Asterisk
            $this->reloadAsterisk();
            
            return [
                'success' => true,
                'message' => 'Flux déployé avec succès dans Asterisk'
            ];
        } else {
            throw new Exception("Impossible d'écrire dans le fichier extensions.conf");
        }
    }
    
    private function backupExtensionsConf() {
        $backupFile = $this->extensionsConfigPath . '.backup-' . date('Y-m-d-H-i-s');
        copy($this->extensionsConfigPath, $backupFile);
    }
    
    private function reloadAsterisk() {
        $command = "docker exec doriav2-asterisk asterisk -rx 'dialplan reload' 2>/dev/null";
        exec($command);
    }
}

// Traitement de la requête
try {
    $api = new FlowManagementAPI();
    $result = $api->handleRequest();
    echo json_encode($result);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
?>
