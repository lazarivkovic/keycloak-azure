#!/bin/bash

set +x

set -a
source .env
set +a

set -x

# Check if the argument --vm is provided
if [[ "$1" == "--vm" ]]; then
    # Use public IP as domain
    DOMAIN=$(curl -s http://ifconfig.me)

    # Replace localhost and host.docker.internal with public IP in nginx.conf
    sed -i "s/localhost/$DOMAIN/g" ./nginx/nginx-default.conf && sed -i "s/host.docker.internal/$DOMAIN/g" ./nginx/nginx-default.conf
else
    # If --vm is not provided, use localhost as domain
    DOMAIN="localhost"

    # Add host.docker.internal to /etc/hosts if not already present
    if ! grep -q "host.docker.internal" /etc/hosts; then
        echo "127.0.0.1 host.docker.internal" | sudo tee -a /etc/hosts > /dev/null
    fi
fi

# Start Keycloak and Postgres containers
docker-compose up -d keycloak postgres

# Wait until Keycloak is available
until $(curl --output /dev/null --silent --head --fail http://$DOMAIN:8080); do
    printf '.'
    sleep 5
done

# Configure database
docker exec postgres psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -c "UPDATE realm SET ssl_required='NONE' WHERE name = 'master';"

# Restart keycloak container after database update
docker restart keycloak
sleep 15

# Configure Keycloak credentials
docker exec keycloak /opt/keycloak/bin/kcadm.sh config credentials --server http://$DOMAIN:8080 --realm master --user ${KEYCLOAK_ADMIN} --password ${KEYCLOAK_ADMIN_PASSWORD}

# Create the client in Keycloak
docker exec keycloak /opt/keycloak/bin/kcadm.sh create clients -r master -s clientId=nginx -s enabled=true -s "redirectUris=[\"http://$DOMAIN/*\"]"

# Get the client secret for nginx
CLIENT_SECRET=$(docker exec keycloak /opt/keycloak/bin/kcadm.sh get clients -r master --fields id,clientId,secret | grep -A 2 '"nginx"' | grep '"secret"' | sed 's/.*"secret": "\(.*\)".*/\1/' | xargs)

# Escape special characters in the secret
ESCAPED_SECRET=$(printf '%s\n' "$CLIENT_SECRET" | sed 's/[\/&]/\\&/g')

# Extract the secret without extra formatting
SECRET_ONLY=$(echo "$ESCAPED_SECRET" | sed 's/^secret : //')

# Update the nginx config file with the client secret
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/CLIENT_SECRET/$SECRET_ONLY/" ./nginx/nginx-default.conf
else
    sed -i "s/CLIENT_SECRET/$SECRET_ONLY/" ./nginx/nginx-default.conf
fi

# Start nginx container
docker-compose up -d nginx