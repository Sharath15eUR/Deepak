#!/bin/bash

ERROR_LOG="errors.log"

search_directory() {
    local directory="$1"
    local keyword="$2"
    
    for file in "$directory"/*; do
    	if [[ -d "$file" ]]; then
    	  search_directory "$file" "$keyword"
    	elif [[ -f "$file" ]]; then
      		if grep -q "$keyword" "$file" 2>>"$ERROR_LOG"; then
        		echo "Found '$keyword' in file: $file"
      		fi
    	fi
    done
}

search_file() {
    local file="$1"
    local keyword="$2"

    if [[ -f "$file" ]]; then
        if grep -q "$keyword" "$file" 2>> "$ERROR_LOG"; then
            echo "Found '$keyword' in: $file"
        else
            echo "Keyword '$keyword' not found in: $file"
        fi
    else
        echo "Error: File '$file' not found!" | tee -a "$ERROR_LOG"
    fi
}

display_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Options:
  -d <directory>   Search for a keyword in a directory (recursive search)
  -k <keyword>     Specify the keyword to search for
  -f <file>        Search for a keyword in a specific file
  --help           Display this help menu

Examples:
  $0 -d Folder -k keyword
  $0 -f Folder/f1.txt -k keyword
  $0 --help
EOF
}


if [[ $# -eq 0 ]]; then
    echo "Error: No arguments provided!" | tee -a "$ERROR_LOG"
    display_help
    exit 1
fi

validate_input() {
  if [[ -z "$keyword" ]]; then
    echo "Error: Keyword cannot be empty." | tee -a "$ERROR_LOG"
    exit 1
  fi
  if [[ -n "$file" && ! -f "$file" ]]; then
    echo "Error: File '$file' does not exist." | tee -a "$ERROR_LOG"
    exit 1
  fi
}

while getopts ":d:k:f:-:" opt; do
    case "$opt" in
        d) directory="$OPTARG" ;;
        k) keyword="$OPTARG" ;;
        f) file="$OPTARG" ;;
        -) case "$OPTARG" in
               help) display_help; exit 0 ;;
               *) echo "Error: Invalid option '--$OPTARG'" | tee -a "$ERROR_LOG"; exit 1 ;;
           esac ;;
        ?) echo "Error: Invalid option '-$OPTARG'" | tee -a "$ERROR_LOG"; exit 1 ;;
    esac
done

if [[ -n "$directory" ]]; then
  if [[ ! -d "$directory" ]]; then
    echo "Error: Directory '$directory' does not exist." | tee -a "$ERROR_LOG"
    exit 1
  fi
  echo "Searching directory '$directory' for keyword '$keyword'..."
  search_directory "$directory" "$keyword"
elif [[ -n "$file" ]]; then
  validate_input
  echo "Searching in file '$file' for keyword '$keyword'..."
  if grep -q "$keyword" "$file" 2>>"$ERROR_LOG"; then
    echo "Keyword '$keyword' found in file '$file'."
  else
    echo "Keyword '$keyword' not found in file '$file'." | tee -a "$ERROR_LOG"
  fi
else
  echo "Error: You must specify either a directory (-d) or a file (-f)." | tee -a "$ERROR_LOG"
  exit 1
fi
