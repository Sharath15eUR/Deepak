#!/bin/bash

if [ $# -ne 1 ]; then
	echo "Invalid no. of Arguments"
	exit 1
fi


input="$1"
output="output.txt"

>output.txt

awk '
/"frame.time"/ {print "\"frame.time\": " substr($0, index($0, $2)) >> "'"$output"'"}
/"wlan.fc.type"/ {print "\"wlan.fc.type\": " $2 >> "'"$output"'"}
/"wlan.fc.subtype"/ {print "\"wlan.fc.subtype\": " $2 >> "'"$output"'"}
' "$input"

echo "Ouput saved in $output"
