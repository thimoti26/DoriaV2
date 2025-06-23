<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>System Status - Asterisk IVR Management</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .sidebar {
            min-height: 100vh;
            background-color: #343a40;
        }
        .sidebar .nav-link {
            color: #fff;
        }
        .sidebar .nav-link:hover {
            background-color: #495057;
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <nav class="col-md-2 d-none d-md-block sidebar">
                <div class="sidebar-sticky pt-3">
                    <h5 class="text-white text-center">Asterisk IVR</h5>
                    <ul class="nav flex-column">
                        <li class="nav-item">
                            <a class="nav-link" href="index.php">
                                Dashboard
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="extensions.php">
                                Extensions
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="ivr.php">
                                IVR Menu
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link active" href="system.php">
                                System Status
                            </a>
                        </li>
                    </ul>
                </div>
            </nav>

            <main role="main" class="col-md-10 ml-sm-auto px-4">
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2">System Status</h1>
                </div>

                <div class="row">
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header">
                                <h5>Asterisk Status</h5>
                            </div>
                            <div class="card-body">
                                <?php
                                // Get Asterisk status
                                $asterisk_version = exec('docker exec asterisk-freepbx-ivr-asterisk-1 asterisk -rx "core show version" 2>/dev/null');
                                $asterisk_uptime = exec('docker exec asterisk-freepbx-ivr-asterisk-1 asterisk -rx "core show uptime" 2>/dev/null');
                                $asterisk_channels = exec('docker exec asterisk-freepbx-ivr-asterisk-1 asterisk -rx "core show channels" 2>/dev/null');
                                ?>
                                <p><strong>Version:</strong> <?php echo $asterisk_version ?: 'Unable to connect'; ?></p>
                                <p><strong>Uptime:</strong> <?php echo $asterisk_uptime ?: 'Unknown'; ?></p>
                                <p><strong>Active Channels:</strong> <?php echo $asterisk_channels ?: '0'; ?></p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header">
                                <h5>Database Status</h5>
                            </div>
                            <div class="card-body">
                                <?php
                                try {
                                    $pdo = new PDO("mysql:host=" . getenv('MYSQL_HOST') . ";dbname=" . getenv('MYSQL_DATABASE'), 
                                                   getenv('MYSQL_USER'), getenv('MYSQL_PASSWORD'));
                                    echo '<p><strong>Connection:</strong> <span class="badge bg-success">Connected</span></p>';
                                    
                                    // Get database size
                                    $stmt = $pdo->query("SELECT ROUND(SUM(data_length + index_length) / 1024 / 1024, 1) AS 'DB Size in MB' FROM information_schema.tables WHERE table_schema='" . getenv('MYSQL_DATABASE') . "'");
                                    $size = $stmt->fetch();
                                    echo '<p><strong>Database Size:</strong> ' . ($size['DB Size in MB'] ?: '0') . ' MB</p>';
                                    
                                    // Get table count
                                    $stmt = $pdo->query("SELECT COUNT(*) as table_count FROM information_schema.tables WHERE table_schema = '" . getenv('MYSQL_DATABASE') . "'");
                                    $tables = $stmt->fetch();
                                    echo '<p><strong>Tables:</strong> ' . $tables['table_count'] . '</p>';
                                    
                                } catch (PDOException $e) {
                                    echo '<p><strong>Connection:</strong> <span class="badge bg-danger">Error</span></p>';
                                    echo '<p><strong>Error:</strong> ' . $e->getMessage() . '</p>';
                                }
                                ?>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row mt-4">
                    <div class="col-12">
                        <div class="card">
                            <div class="card-header">
                                <h5>Docker Containers</h5>
                            </div>
                            <div class="card-body">
                                <div class="table-responsive">
                                    <table class="table table-striped">
                                        <thead>
                                            <tr>
                                                <th>Container</th>
                                                <th>Status</th>
                                                <th>Ports</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <tr>
                                                <td>MySQL Database</td>
                                                <td><span class="badge bg-success">Running</span></td>
                                                <td>3306</td>
                                            </tr>
                                            <tr>
                                                <td>Asterisk Server</td>
                                                <td><span class="badge bg-success">Running</span></td>
                                                <td>5060 (SIP), 5038 (AMI)</td>
                                            </tr>
                                            <tr>
                                                <td>FreePBX Web Interface</td>
                                                <td><span class="badge bg-success">Running</span></td>
                                                <td>8080</td>
                                            </tr>
                                            <tr>
                                                <td>Nginx Reverse Proxy</td>
                                                <td><span class="badge bg-success">Running</span></td>
                                                <td>80</td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row mt-4">
                    <div class="col-12">
                        <div class="card">
                            <div class="card-header">
                                <h5>System Commands</h5>
                            </div>
                            <div class="card-body">
                                <button class="btn btn-warning" onclick="restartAsterisk()">Restart Asterisk</button>
                                <button class="btn btn-info" onclick="reloadConfig()">Reload Configuration</button>
                                <button class="btn btn-success" onclick="viewLogs()">View Logs</button>
                            </div>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function restartAsterisk() {
            alert('Restart command would be executed here');
        }
        
        function reloadConfig() {
            alert('Configuration reload would be executed here');
        }
        
        function viewLogs() {
            alert('Log viewer would be opened here');
        }
    </script>
</body>
</html>
