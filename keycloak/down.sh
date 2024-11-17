#!/bin/bash

set -x

if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' 's/client_secret = "[^"]*"/client_secret = "CLIENT_SECRET"/' ./nginx/nginx-default.conf
else
    sed -i 's/client_secret = "[^"]*"/client_secret = "CLIENT_SECRET"/' ./nginx/nginx-default.conf
fi

docker-compose down
