<?php
// Configuration FreePBX pour MySQL
$amp_conf = array(
    'AMPDBHOST' => getenv('DB_HOST') ?: 'mysql',
    'AMPDBNAME' => getenv('DB_NAME') ?: 'doriav2', 
    'AMPDBUSER' => getenv('DB_USER') ?: 'doriav2_user',
    'AMPDBPASS' => getenv('DB_PASSWORD') ?: 'doriav2_password',
    'AMPDBPORT' => '3306',
    'AMPDBENGINE' => 'mysql',
    
    // Asterisk Manager Interface
    'AMPMGRUSER' => 'admin',
    'AMPMGRPASS' => 'amp111',
    'AMPMANAGERHOST' => getenv('ASTERISK_HOST') ?: 'asterisk',
    'AMPMANAGERPORT' => '5038',
    
    // FreePBX Configuration
    'AMPWEBROOT' => '/var/www/html',
    'AMPWEBADDRESS' => '0.0.0.0',
    'AMPADMINLOGO' => 'logo.png',
    'AMPMODULEXML' => 'http://mirror.freepbx.org',
    
    // Security
    'AMPMASTERDBHOST' => getenv('DB_HOST') ?: 'mysql',
    'AMPMASTERDBNAME' => getenv('DB_NAME') ?: 'doriav2',
    'AMPMASTERDBUSER' => getenv('DB_USER') ?: 'doriav2_user',
    'AMPMASTERDBPASS' => getenv('DB_PASSWORD') ?: 'doriav2_password',
    
    // Paths
    'ASTVARLIBDIR' => '/var/lib/asterisk',
    'ASTLOGDIR' => '/var/log/asterisk',
    'ASTSPOOLDIR' => '/var/spool/asterisk',
    'ASTCONFDIR' => '/etc/asterisk',
    'ASTSBINDIR' => '/usr/sbin',
    'AMPBIN' => '/var/lib/asterisk/bin',
    'AMPCGIBIN' => '/var/www/html/cgi-bin',
    'AMPPLAYBACK' => '/var/lib/asterisk/playback'
);

// Écrire la configuration
$config_content = "<?php\n";
foreach ($amp_conf as $key => $value) {
    $config_content .= "\$amp_conf['$key'] = '$value';\n";
}

file_put_contents('/var/www/html/amportal.conf', $config_content);
?>
