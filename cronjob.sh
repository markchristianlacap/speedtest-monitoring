#!/bin/bash
RESULT=$(speedtest --format=json)
TMP=/var/www/html/results.json

if [ ! -f "$TMP" ]; then
    echo "[]" > "$TMP"
fi

jq ". += [$RESULT]" "$TMP" > "$TMP.tmp" && mv "$TMP.tmp" "$TMP"
