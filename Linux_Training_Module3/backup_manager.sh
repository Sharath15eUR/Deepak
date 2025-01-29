#!/bin/bash

#To check the no of arguments in terminal
if [ $# -ne 3 ]; then
    echo "Usage: $0 <source_directory> <backup_directory> <file_extension>"
    exit 1
fi

#Source directory, backup directory, File extension
source="$1"
backup="$2"
file_ext="$3"


if [ ! -d "$source" ]; then
    echo "Error: The source directory does not exist."
    exit 1
fi


if [ ! -d "$backup" ]; then
    mkdir -p "$backup"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create the backup directory."
        exit 1
    fi
fi

#Globbing to find all files in source directory
files=$(ls "$source"/*"$file_ext" 2>/dev/null)

# If there is no files then exit
if [ -z "$files" ]; then
    echo "No files found with the extension $file_ext in $source"
    exit 1
fi

# Count and size of total files backedup
export count=0
size=0

# Array operation (looping through each file in files array)
for file in $files; do
    if [ -f "$file" ]; then
        name=$(basename "$file")
        dest="$backup/$name"
        f_size=$(stat -c%s "$file")

        echo "Backing up: $name ($f_size bytes)"

        # Check if the file already exists in the backup directory and compare
        if [ -f "$dest" ]; then
            if [ "$file" -nt "$dest" ]; then
                cp "$file" "$dest"
                echo "Updated: $name"
            else
                echo "Skipped: $name"
                continue
            fi
        else
            cp "$file" "$dest"
            echo "Copied: $name"
        fi

        count=$((count + 1))
        size=$((size + f_size))
    fi
done

# To Create a backup report and store it in a backup_report.log file
report="$backup/backup_report.log"
echo "Backup Summary:" > "$report"
echo "Total files backed up: $count" >> "$report"
echo "Total size of files: $size bytes" >> "$report"
echo "Backup directory: $backup" >> "$report"

echo "Backup finished! Report saved at: $report"

