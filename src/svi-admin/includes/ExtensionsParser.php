<?php

/**
 * Parser et générateur pour fichiers extensions.conf Asterisk
 * Gestion spécialisée pour SVI multilingue DoriaV2
 */
class ExtensionsParser {
    
    private $extensionsFile;
    private $contexts = [];
    
    public function __construct($extensionsFile = '/var/www/html/asterisk-config/extensions.conf') {
        $this->extensionsFile = $extensionsFile;
    }
    
    /**
     * Parse le fichier extensions.conf et extrait la structure SVI
     */
    public function parseSviStructure() {
        if (!file_exists($this->extensionsFile)) {
            throw new Exception("Fichier extensions.conf non trouvé: " . $this->extensionsFile);
        }
        
        $content = file_get_contents($this->extensionsFile);
        $lines = explode("\n", $content);
        
        $sviStructure = [
            'language' => $this->parseContext($lines, 'ivr-language'),
            'main_fr' => $this->parseContext($lines, 'ivr-main'),
            'main_en' => $this->parseContext($lines, 'ivr-main-en')
        ];
        
        return $sviStructure;
    }
    
    /**
     * Parse un contexte spécifique
     */
    private function parseContext($lines, $contextName) {
        $context = [];
        $inContext = false;
        $currentExtension = null;
        
        foreach ($lines as $line) {
            $line = trim($line);
            
            // Ignorer lignes vides et commentaires
            if (empty($line) || strpos($line, ';') === 0) {
                continue;
            }
            
            // Détecter début du contexte
            if ($line === "[$contextName]") {
                $inContext = true;
                continue;
            }
            
            // Détecter fin du contexte
            if (preg_match('/^\[.+\]$/', $line) && $inContext) {
                break;
            }
            
            // Parser les extensions dans le contexte
            if ($inContext && strpos($line, 'exten =>') === 0) {
                if (preg_match('/exten => (.+),(\d+),(.+)/', $line, $matches)) {
                    $extension = trim($matches[1]);
                    $priority = intval($matches[2]);
                    $action = trim($matches[3]);
                    
                    if ($priority === 1) {
                        $context[$extension] = [
                            'extension' => $extension,
                            'action' => $action,
                            'type' => $this->determineActionType($action),
                            'description' => $this->getActionDescription($action)
                        ];
                    }
                }
            }
        }
        
        return $context;
    }
    
    /**
     * Détermine le type d'action
     */
    private function determineActionType($action) {
        if (strpos($action, 'Background(') !== false) {
            return 'menu';
        } elseif (strpos($action, 'Dial(PJSIP/') !== false) {
            return 'transfer';
        } elseif (strpos($action, 'Goto(') !== false) {
            return 'redirect';
        } elseif (strpos($action, 'ConfBridge(') !== false) {
            return 'conference';
        } elseif (strpos($action, 'Hangup()') !== false) {
            return 'hangup';
        } else {
            return 'other';
        }
    }
    
    /**
     * Génère une description lisible de l'action
     */
    private function getActionDescription($action) {
        $type = $this->determineActionType($action);
        
        switch ($type) {
            case 'menu':
                if (preg_match('/Background\((.+)\)/', $action, $matches)) {
                    return "Menu audio: " . $matches[1];
                }
                return "Menu audio";
                
            case 'transfer':
                if (preg_match('/Dial\(PJSIP\/(\d+)/', $action, $matches)) {
                    return "Transfert vers extension " . $matches[1];
                }
                return "Transfert";
                
            case 'redirect':
                if (preg_match('/Goto\(([^,]+)/', $action, $matches)) {
                    return "Redirection vers " . $matches[1];
                }
                return "Redirection";
                
            case 'conference':
                if (preg_match('/ConfBridge\(([^)]+)\)/', $action, $matches)) {
                    return "Conférence " . $matches[1];
                }
                return "Conférence";
                
            case 'hangup':
                return "Raccrocher";
                
            default:
                return $action;
        }
    }
    
    /**
     * Génère le contenu extensions.conf à partir de la structure SVI
     */
    public function generateExtensionsConf($sviStructure) {
        $content = "; Extensions.conf généré par SVI Admin DoriaV2\n";
        $content .= "; " . date('Y-m-d H:i:s') . "\n\n";
        
        // Contexte sélection langue
        $content .= "[ivr-language]\n";
        foreach ($sviStructure['language'] as $ext => $config) {
            $content .= "exten => $ext,1," . $config['action'] . "\n";
        }
        $content .= "\n";
        
        // Contexte principal français
        $content .= "[ivr-main]\n";
        foreach ($sviStructure['main_fr'] as $ext => $config) {
            $content .= "exten => $ext,1," . $config['action'] . "\n";
        }
        $content .= "\n";
        
        // Contexte principal anglais
        $content .= "[ivr-main-en]\n";
        foreach ($sviStructure['main_en'] as $ext => $config) {
            $content .= "exten => $ext,1," . $config['action'] . "\n";
        }
        
        return $content;
    }
    
    /**
     * Valide la syntaxe d'une configuration
     */
    public function validateSyntax($sviStructure) {
        $errors = [];
        
        // Vérifications basiques
        foreach (['language', 'main_fr', 'main_en'] as $context) {
            if (!isset($sviStructure[$context])) {
                $errors[] = "Contexte manquant: $context";
                continue;
            }
            
            foreach ($sviStructure[$context] as $ext => $config) {
                // Vérifier que l'action n'est pas vide
                if (empty($config['action'])) {
                    $errors[] = "Action vide pour extension $ext dans $context";
                }
                
                // Vérifier syntaxe basique des actions
                if (strpos($config['action'], 'Background(') !== false) {
                    if (!preg_match('/Background\(.+\)/', $config['action'])) {
                        $errors[] = "Syntaxe Background incorrecte pour $ext dans $context";
                    }
                }
            }
        }
        
        return $errors;
    }
    
    /**
     * Sauvegarde la configuration dans extensions.conf
     */
    public function saveConfiguration($sviStructure) {
        $errors = $this->validateSyntax($sviStructure);
        if (!empty($errors)) {
            throw new Exception("Erreurs de validation: " . implode(', ', $errors));
        }
        
        $content = $this->generateExtensionsConf($sviStructure);
        
        // Backup actuel
        $backupFile = $this->extensionsFile . '.backup-' . date('Y-m-d-H-i-s');
        if (file_exists($this->extensionsFile)) {
            copy($this->extensionsFile, $backupFile);
        }
        
        // Écriture nouvelle configuration
        if (file_put_contents($this->extensionsFile, $content) === false) {
            throw new Exception("Impossible d'écrire dans " . $this->extensionsFile);
        }
        
        return true;
    }
}
