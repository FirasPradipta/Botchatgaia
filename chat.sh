#!/bin/bash

# API Configuration
API_KEY="gaia-MjhiNTQzMTgtZjdmMS00NzM3LTgzN2EtY2ZhZTdiODNlZTRl-BZzhPSucTIDIoLld"
ENDPOINT="https://llama3b.gaia.domains/v1/chat/completions"
KEYWORDS_FILE="keyword.txt"
WAIT_TIME=20  # Time to wait (in seconds) between requests

# Check if keyword.txt exists
if [[ ! -f $KEYWORDS_FILE ]]; then
    echo "Error: File $KEYWORDS_FILE not found!"
    exit 1
fi

# Read keywords and send requests
while IFS= read -r keyword; do
    echo "Sending query: $keyword"

    # Make API request
    RESPONSE=$(curl -s -X POST "$ENDPOINT" \
        -H "Authorization: Bearer $API_KEY" \
        -H "accept: application/json" \
        -H "Content-Type: application/json" \
        -d '{
            "messages": [
                {"role": "system", "content": "You are a helpful assistant."},
                {"role": "user", "content": "'"$keyword"'"}
            ]
        }')

    # Validate JSON response
    if echo "$RESPONSE" | jq empty > /dev/null 2>&1; then
        REPLY=$(echo "$RESPONSE" | jq -r '.choices[0].message.content')
        echo -e "Bot response:\n$REPLY\n"
    else
        echo "Error: Invalid response received from API. Response was:"
        echo "$RESPONSE"
    fi

    # Wait before the next request
    echo "Waiting $WAIT_TIME seconds before the next query..."
    sleep $WAIT_TIME
done < "$KEYWORDS_FILE"

echo "All queries processed."
