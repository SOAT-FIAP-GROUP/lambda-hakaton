#!/usr/bin/env bash
set -e

API_URL=$1
EMAIL="test$(date +%s)@example.com"
PASS="Passw0rd!"

echo "➡️  Signup..."
curl -s -X POST $API_URL/signup -d "{\"email\":\"$EMAIL\",\"password\":\"$PASS\"}" -H "Content-Type: application/json"

echo -e "\n➡️  Signin..."
TOKENS=$(curl -s -X POST $API_URL/signin -d "{\"email\":\"$EMAIL\",\"password\":\"$PASS\"}" -H "Content-Type: application/json")
ACCESS=$(echo $TOKENS | jq -r .access_token)

echo -e "\n➡️  Me..."
curl -s -X GET $API_URL/me -H "Authorization: Bearer $ACCESS"
