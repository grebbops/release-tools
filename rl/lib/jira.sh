#!/usr/bin/env bash

jira() {

  NAME=$1
  DESCRIPTION=$2
  RELEASED=false

  CREDS="${JIRA_API_USER}:${JIRA_API_TOKEN}"
  ENCODED_AUTH=$(echo -n "$CREDS" | base64)

  read -r -d '' DATA <<-EOF
    {
      "archived": false,
      "description": "$DESCRIPTION",
      "name": "$NAME",
      "projectId": "$JIRA_PROJECT_ID",
      "released": "$RELEASED"
    }
EOF

  {
    RESPONSE=$(curl -X POST -i --location "${JIRA_API_URL}/version" \
      --header 'Accept: application/json' \
      --header 'Content-Type: application/json' \
      --header "Authorization: Basic ${ENCODED_AUTH}" \
      --data "$DATA")

    # Extract the URL of the created version
    RELEASE_ID=$(echo "$RESPONSE" | grep -o '"id": *"[^"]*' | awk -F'"' '{print $4}')
  } 2>/dev/null
  URL="$JIRA_URL/projects/$JIRA_PROJECT_ID/versions/$RELEASE_ID"

  echo "Fix Version: $URL"

}

# Example usage:
# jira "Version Name" "Version Description"
