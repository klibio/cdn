#!/bin/bash

log_folder="C:\IDEfix\cdn.klib.io\git\cdn\oomph-console\setups\BndConfiguration"
search_string="No repository found"

# Find all log files in the log folder
log_files=$(find "$log_folder" -type f -name "*.log")

# Iterate over each log file
for log_file in $log_files; do
    echo "Searching in $log_file..."
    echo "----------------------------------------"

    # Search for the string and print 5 lines before and after
    grep -B 5 -A 5 "$search_string" "$log_file"

    echo "----------------------------------------"
done