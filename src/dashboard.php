<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DoriaV2 - System Dashboard</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            margin: 0;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
        }
        .header {
            text-align: center;
            color: white;
            margin-bottom: 30px;
        }
        .services-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .service-card {
            background: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            transition: transform 0.2s;
        }
        .service-card:hover {
            transform: translateY(-2px);
        }
        .service-title {
            font-size: 18px;
            font-weight: bold;
            margin-bottom: 10px;
            color: #333;
        }
        .service-description {
            color: #666;
            margin-bottom: 15px;
        }
        .service-url {
            display: inline-block;
            background: #667eea;
            color: white;
            padding: 8px 16px;
            text-decoration: none;
            border-radius: 5px;
            transition: background 0.2s;
        }
        .service-url:hover {
            background: #5a67d8;
        }
        .status-section {
            background: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        .status-indicator {
            display: inline-block;
            width: 12px;
            height: 12px;
            border-radius: 50%;
            margin-right: 8px;
        }
        .status-online { background: #48bb78; }
        .status-offline { background: #f56565; }
        .refresh-btn {
            background: #48bb78;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            margin-bottom: 15px;
        }
        .refresh-btn:hover {
            background: #38a169;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚀 DoriaV2 VoIP/PBX System</h1>
            <p>Comprehensive telephony and web application platform</p>
            <div style="margin-top: 15px;">
                <a href="/system-status.html" style="background: #10b981; color: white; padding: 8px 16px; text-decoration: none; border-radius: 5px; font-size: 14px;">📊 Detailed System Status</a>
            </div>
        </div>

        <div class="services-grid">
            <div class="service-card">
                <div class="service-title">📱 FreePBX Web Interface</div>
                <div class="service-description">PBX management, extensions, and telephony configuration</div>
                <a href="http://localhost:8082" target="_blank" class="service-url">Open FreePBX</a>
            </div>

            <div class="service-card">
                <div class="service-title">🗄️ phpMyAdmin</div>
                <div class="service-description">Database administration and management</div>
                <a href="http://localhost:8081" target="_blank" class="service-url">Open phpMyAdmin</a>
            </div>

            <div class="service-card">
                <div class="service-title">📧 Mailhog</div>
                <div class="service-description">Email testing and SMTP debugging</div>
                <a href="http://localhost:8025" target="_blank" class="service-url">Open Mailhog</a>
            </div>

            <div class="service-card">
                <div class="service-title">🌐 Web Application</div>
                <div class="service-description">Main application interface (PHP/Apache)</div>
                <a href="http://localhost:8080" target="_blank" class="service-url">Open Application</a>
            </div>

            <div class="service-card">
                <div class="service-title">🔧 Connection Test</div>
                <div class="service-description">Test database and cache connectivity</div>
                <a href="http://localhost:8080/test_connections.php" target="_blank" class="service-url">Test Connections</a>
            </div>

            <div class="service-card">
                <div class="service-title">👥 SIP Users Management</div>
                <div class="service-description">Manage SIP extensions, users, and telephony accounts</div>
                <a href="http://localhost:8080/sip-users.html" target="_blank" class="service-url">Manage Users</a>
            </div>

            <div class="service-card">
                <div class="service-title">📞 SIP Configuration</div>
                <div class="service-description">
                    <strong>SIP Server:</strong> localhost:5060<br>
                    <strong>AMI Port:</strong> 5038<br>
                    <strong>RTP Range:</strong> 10000-10100
                </div>
                <a href="#" onclick="showSipInfo()" class="service-url">SIP Details</a>
            </div>
        </div>

        <div class="status-section">
            <h3>System Status</h3>
            <button class="refresh-btn" onclick="refreshStatus()">🔄 Refresh Status</button>
            <div id="status-container">
                <div id="connection-status">Loading connection status...</div>
            </div>
        </div>
    </div>

    <script>
        async function refreshStatus() {
            try {
                const response = await fetch('/test_connections.php');
                const data = await response.json();
                
                let statusHtml = '<h4>Service Connectivity:</h4>';
                
                // MySQL Status
                const mysqlStatus = data.mysql.status === 'success' ? 'online' : 'offline';
                statusHtml += `
                    <div style="margin: 10px 0;">
                        <span class="status-indicator status-${mysqlStatus}"></span>
                        <strong>MySQL Database:</strong> ${data.mysql.message}
                    </div>
                `;
                
                // Redis Status
                const redisStatus = data.redis.status === 'success' ? 'online' : 'offline';
                statusHtml += `
                    <div style="margin: 10px 0;">
                        <span class="status-indicator status-${redisStatus}"></span>
                        <strong>Redis Cache:</strong> ${data.redis.message}
                    </div>
                `;
                
                statusHtml += `<p style="margin-top: 15px; color: #666;"><small>Last updated: ${data.timestamp}</small></p>`;
                
                document.getElementById('connection-status').innerHTML = statusHtml;
            } catch (error) {
                document.getElementById('connection-status').innerHTML = 
                    '<div style="color: #f56565;">Error loading status: ' + error.message + '</div>';
            }
        }

        function showSipInfo() {
            alert(`SIP Configuration Details:

Server: localhost:5060 (UDP/TCP)
Manager Interface: localhost:5038
RTP Ports: 10000-10100

To configure a SIP client:
1. Use FreePBX web interface to create extensions
2. Configure your SIP client with the extension credentials
3. Server: localhost or your Docker host IP
4. Port: 5060
5. Protocol: UDP (recommended) or TCP`);
        }

        // Load status on page load
        document.addEventListener('DOMContentLoaded', refreshStatus);
    </script>
</body>
</html>
