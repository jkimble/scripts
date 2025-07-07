#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Deploy (Vito)
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🚀
# @raycast.argument1 { "type": "text", "placeholder": "Server" }
# @raycast.argument2 { "type": "text", "placeholder": "Site" }
# @raycast.packageName Development

# Documentation:
# @raycast.description Deploy site from VitoDeploy instance.
# @raycast.author Justin
# @raycast.authorURL https://github.com/jkimble

source "$(dirname "$0")/.env"

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Error: Server and Site parameters are required."
  exit 1
fi

response_code=$(curl --silent --output /dev/null --write-out "%{http_code}" --request POST \
  "${VITO_SERVER_URL}/api/projects/1/servers/${1}/sites/${2}/deploy" \
  --header "Authorization: Bearer ${VITO_API_KEY}" \
  --header "Content-Type: application/json" \
  --header "Accept: application/json")

if [ "$response_code" -eq 200 ]; then
  echo "Deployment succeeded for site '$2' on server '$1'."
else
  echo "Deployment failed with status code $response_code."
fi
