#!/usr/bin/env bash

array=( "./file1.txt" "./file2.txt" "./file3.txt" "./file4.txt" )
log_file="nginx.log"

max_size_kb=300

while true; do
    log_file >> ${array[0]}
    current_size_kb=$(du -k ${array[0]} | cut -f1)

    if [ "$current_size_kb" -gt "$max_size_kb" ]; then
        date_time=$(date "+%Y-%m-%d %H:%M:%S")
        deleted_entries=$(wc -l < ${array[0]})

        echo "$date_time: Clearing ${array[0]}. Deleted entries: $deleted_entries" >> ${array[1]}
        "" > ${array[0]} # очищаем файл 1
    fi

    for i in 2 3; do
      awk '$9 ~ /^'"$(( $i+2 ))"'[0-9][0-9]$/ {print}' ${array[0]} >> ${array[$(( $i+1 ))]}
    done

    sleep 5
done
