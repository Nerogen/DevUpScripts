#!/usr/bin/env bash

array=("/home/ubuntu/file1.txt" "/home/ubuntu/file2.txt" "/home/ubuntu/file3.txt" "/home/ubuntu/file4.txt")
log_file="/var/log/nginx/access.log"

max_size_kb=300

process() {
while true; do

    cat $log_file >> ${array[0]}
    echo "" > $log_file;
    echo "Logs nginx to first file"
    current_size_kb=$(du -k ${array[0]} | cut -f1)
    if [ "$current_size_kb" -gt "$max_size_kb" ]; then
        echo "clear file 1 | create log to 2"
        date_time=$(date "+%Y-%m-%d %H:%M:%S")
        deleted_entries=$(wc -l < ${array[0]})

        echo "$date_time: Clearing ${array[0]}. Deleted entries: $deleted_entries" >> ${array[1]}
        echo "" > ${array[0]} # очищаем файл 1
    fi


    echo "Logs first file to 3 - 4XX,4 - 5XX errors"
    awk '$9 ~ /^4[0-9][0-9]$/ {print}' ${array[0]} >> ${array[2]}
    awk '$9 ~ /^5[0-9][0-9]$/ {print}' ${array[0]} >> ${array[3]}

    sleep 5
done
}
process