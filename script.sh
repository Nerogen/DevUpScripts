#!/usr/bin/env bash

array=("./file1.txt" "./file2.txt" "./file3.txt" "./file4.txt")
log_file="/var/log/nginx/access.log"

#!/bin/bash
cpu () {
# Get CPU usage using the top command
echo "Cpu unit"
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')

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
        // Reload the page every 5 seconds
        setTimeout(function() {
            location.reload();
        }, 2500);
    </script>
</head>
<body>
    <h1>CPU Usage Monitor</h1>
    <p id='cpuUsage'>CPU Usage: $cpu_usage%</p>
</body>
</html>"


# Write HTML content to a file
echo "$html_content" > /usr/share/nginx/html/index.html
}

ps aux | grep script.sh
# kill -KILL <PID>

max_size_kb=300

process() {
while true; do
    cpu

    cat $log_file >> ${array[0]}
    echo "Log nginx to firt"
    current_size_kb=$(du -k ${array[0]} | cut -f1)
    if [ "$current_size_kb" -gt "$max_size_kb" ]; then
        echo "clear file 1 log to 2"
        date_time=$(date "+%Y-%m-%d %H:%M:%S")
        deleted_entries=$(wc -l < ${array[0]})

        echo "$date_time: Clearing ${array[0]}. Deleted entries: $deleted_entries" >> ${array[1]}
        echo "" > ${array[0]} # очищаем файл 1
    fi


    echo "Log first file to 3,4 errors"
    awk '$9 ~ /^4[0-9][0-9]$/ {print}' ${array[0]} >> ${array[2]}
    awk '$9 ~ /^5[0-9][0-9]$/ {print}' ${array[0]} >> ${array[3]}

    sleep 5
done
}
process
# Запускаем функцию write_logs в фоновом режиме
# process &

# Ожидаем завершения работы
# wait
