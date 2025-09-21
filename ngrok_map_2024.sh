#!/bin/bash
# Script to detect the external port mapped to internal 2024 and start ngrok to map it to 2024

# Find the external port mapped to internal 2024
# This assumes you are running inside a devcontainer and want to expose internal port 2024

# Try to find the port mapping using lsof
EXTERNAL_PORT=$(lsof -i -P -n | grep LISTEN | grep ':2024' | awk '{print $9}' | sed 's/.*://')

if [ -z "$EXTERNAL_PORT" ]; then
  echo "No process is listening on internal port 2024."
  exit 1
fi

echo "Detected external port mapped to internal 2024: $EXTERNAL_PORT"

echo "Starting ngrok to map external port $EXTERNAL_PORT to 2024..."
# Start ngrok to forward external port to 2024
ngrok tcp $EXTERNAL_PORT --remote-addr=0.tcp.ngrok.io:2024
