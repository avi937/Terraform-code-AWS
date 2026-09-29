#!/bin/bash
apt-get update -y
apt-get install -y nginx
systemctl start nginx
systemctl enable nginx

PRIVATE_IP=$(hostname -I | awk '{print $1}')

cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Terraform AWS Server</title>
    <style>
        body {
            margin: 0;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            background: linear-gradient(135deg, #0f172a 0%, #1e1b4b 100%);
            color: #f8fafc;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
        }
        .container {
            background: rgba(30, 41, 59, 0.8);
            border: 1px solid rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(12px);
            border-radius: 16px;
            padding: 40px;
            max-width: 500px;
            width: 90%;
            text-align: center;
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.5);
        }
        h1 { color: #38bdf8; margin-bottom: 8px; font-size: 26px; }
        p.subtitle { color: #94a3b8; margin-top: 0; margin-bottom: 24px; }
        .card {
            background: rgba(15, 23, 42, 0.6);
            border-radius: 8px;
            padding: 16px;
            margin: 12px 0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .card span.label { color: #94a3b8; font-size: 14px; }
        .card span.value { font-weight: 600; color: #f1f5f9; }
        .badge {
            background: #22c55e;
            color: white;
            padding: 4px 10px;
            border-radius: 9999px;
            font-size: 12px;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Terraform Server Live!</h1>
        <p class="subtitle">Provisioned automatically via Terraform & UserData</p>
        <div class="card">
            <span class="label">Region</span>
            <span class="value">ap-south-1 (Mumbai)</span>
        </div>
        <div class="card">
            <span class="label">Instance Name</span>
            <span class="value">Instance-1</span>
        </div>
        <div class="card">
            <span class="label">Private IP</span>
            <span class="value">$PRIVATE_IP</span>
        </div>
        <div class="card">
            <span class="label">Status</span>
            <span class="badge">Running (Nginx)</span>
        </div>
    </div>
</body>
</html>
EOF