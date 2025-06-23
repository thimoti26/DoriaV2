<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>IVR Configuration - Asterisk IVR Management</title>
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
                            <a class="nav-link active" href="ivr.php">
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
                    <h1 class="h2">IVR Menu Configuration</h1>
                </div>

                <?php
                if ($_POST['update_ivr']) {
                    // Handle IVR update
                    $welcome_message = $_POST['welcome_message'];
                    $menu_options = $_POST['menu_options'];
                    
                    // Here you would update the Asterisk configuration
                    echo '<div class="alert alert-success">IVR configuration updated successfully!</div>';
                }
                ?>

                <div class="row">
                    <div class="col-md-8">
                        <div class="card">
                            <div class="card-header">
                                <h5>IVR Settings</h5>
                            </div>
                            <div class="card-body">
                                <form method="POST">
                                    <div class="mb-3">
                                        <label for="welcome_message" class="form-label">Welcome Message</label>
                                        <textarea class="form-control" id="welcome_message" name="welcome_message" rows="3">Welcome to our company. Please listen carefully as our menu options have changed.</textarea>
                                    </div>
                                    
                                    <div class="mb-3">
                                        <label for="menu_options" class="form-label">Menu Options</label>
                                        <textarea class="form-control" id="menu_options" name="menu_options" rows="5">Press 1 for Sales Department
Press 2 for Technical Support  
Press 3 for Billing
Press 9 to repeat this menu
Press 0 to speak with an operator</textarea>
                                    </div>
                                    
                                    <button type="submit" name="update_ivr" class="btn btn-primary">Update IVR</button>
                                </form>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-4">
                        <div class="card">
                            <div class="card-header">
                                <h5>Audio Files</h5>
                            </div>
                            <div class="card-body">
                                <p><strong>Current Files:</strong></p>
                                <ul class="list-group">
                                    <li class="list-group-item d-flex justify-content-between align-items-center">
                                        welcome.wav
                                        <span class="badge bg-success rounded-pill">Active</span>
                                    </li>
                                    <li class="list-group-item d-flex justify-content-between align-items-center">
                                        menu.wav
                                        <span class="badge bg-success rounded-pill">Active</span>
                                    </li>
                                    <li class="list-group-item d-flex justify-content-between align-items-center">
                                        goodbye.wav
                                        <span class="badge bg-success rounded-pill">Active</span>
                                    </li>
                                </ul>
                                <br>
                                <button class="btn btn-outline-primary btn-sm">Upload New Audio</button>
                            </div>
                        </div>
                        
                        <div class="card mt-3">
                            <div class="card-header">
                                <h5>Test IVR</h5>
                            </div>
                            <div class="card-body">
                                <p>Call extension <strong>1000</strong> to test the IVR system.</p>
                                <button class="btn btn-info btn-sm">Test Call</button>
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
