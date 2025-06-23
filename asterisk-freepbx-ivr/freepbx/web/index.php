<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Asterisk IVR Management</title>
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
                            <a class="nav-link active" href="index.php">
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
                            <a class="nav-link" href="system.php">
                                System Status
                            </a>
                        </li>
                    </ul>
                </div>
            </nav>

            <main role="main" class="col-md-10 ml-sm-auto px-4">
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2">Dashboard</h1>
                </div>

                <div class="row">
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header">
                                <h5>System Status</h5>
                            </div>
                            <div class="card-body">
                                <?php
                                $asterisk_status = exec('docker exec asterisk-freepbx-ivr-asterisk-1 asterisk -rx "core show version" 2>/dev/null');
                                if ($asterisk_status) {
                                    echo '<span class="badge bg-success">Asterisk Running</span>';
                                } else {
                                    echo '<span class="badge bg-danger">Asterisk Stopped</span>';
                                }
                                ?>
                                <br><br>
                                <?php
                                try {
                                    $pdo = new PDO("mysql:host=" . getenv('MYSQL_HOST') . ";dbname=" . getenv('MYSQL_DATABASE'), 
                                                   getenv('MYSQL_USER'), getenv('MYSQL_PASSWORD'));
                                    echo '<span class="badge bg-success">Database Connected</span>';
                                } catch (PDOException $e) {
                                    echo '<span class="badge bg-danger">Database Error</span>';
                                }
                                ?>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header">
                                <h5>Quick Actions</h5>
                            </div>
                            <div class="card-body">
                                <a href="ivr.php" class="btn btn-primary">Configure IVR</a>
                                <a href="extensions.php" class="btn btn-secondary">Manage Extensions</a>
                                <a href="system.php" class="btn btn-info">System Info</a>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row mt-4">
                    <div class="col-12">
                        <div class="card">
                            <div class="card-header">
                                <h5>Current IVR Configuration</h5>
                            </div>
                            <div class="card-body">
                                <p><strong>Main Menu (Extension 1000):</strong></p>
                                <ul>
                                    <li>Press 1 for Sales Department</li>
                                    <li>Press 2 for Technical Support</li>
                                    <li>Press 9 to repeat this menu</li>
                                </ul>
                                <p><strong>Audio Files:</strong></p>
                                <ul>
                                    <li>welcome.wav - Welcome message</li>
                                    <li>menu.wav - Menu options</li>
                                    <li>goodbye.wav - Goodbye message</li>
                                </ul>
                            </div>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
