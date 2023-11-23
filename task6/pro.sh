#!/usr/bin/env bash

cpu () {
# Get CPU usage using the top command

cpu_usage=$(top -bn1 | awk '{print 100 - $1"%"}'
)
# HTML content with CPU usage
html_content="<!DOCTYPE html>
<html lang='en'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>CPU Usage Monitor</title>
    <style>
        body {
            font-family: 'Arial', sans-serif;
            text-align: center;
            margin: 50px;
            background-color: #333;
            color: #eee;
        }
        h1 {
            color: #4caf50;
        }
        #cpuUsage {
            font-size: 36px;
            font-weight: bold;
            color: #1e88e5;
            margin-top: 20px;
        }
    </style>
    <script>
        // Reload the page every 2.5 seconds
        setTimeout(function() {
            location.reload();
        }, 2500);
    </script>
</head>
<body>
    <h1>CPU Usage Monitor</h1>
    <p id='cpuUsage'>CPU Usage: $cpu_usage</p>
</body>
</html>"


# Write HTML content to a file
echo "$html_content" > /usr/share/nginx/html/index.html
}

process() {
while true; do
    cpu
    sleep 1
done
}
process