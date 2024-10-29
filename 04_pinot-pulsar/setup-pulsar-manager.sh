#!/bin/bash

# Wait for services to be ready
echo "Waiting for services to be ready..."
sleep 30

# Get CSRF token
CSRF_TOKEN=$(curl http://localhost:7750/pulsar-manager/csrf-token)
echo "CSRF Token: $CSRF_TOKEN"

# Create default user
echo "Creating default admin user..."
curl \
    -H "X-XSRF-TOKEN: $CSRF_TOKEN" \
    -H "Cookie: XSRF-TOKEN=$CSRF_TOKEN;" \
    -H 'Content-Type: application/json' \
    -X PUT http://localhost:7750/pulsar-manager/users/superuser \
    -d '{"name": "admin", "password": "apachepulsar", "description": "default admin", "email": "admin@example.com"}'

echo -e "\nWaiting for user creation to complete..."
sleep 5

# Add local cluster
echo "Adding local cluster..."
curl \
    -H "X-XSRF-TOKEN: $CSRF_TOKEN" \
    -H "Cookie: XSRF-TOKEN=$CSRF_TOKEN;" \
    -H 'Content-Type: application/json' \
    -X PUT http://localhost:7750/pulsar-manager/clusters/local \
    -d '{"name": "local", "serviceUrl": "http://pulsar:8080", "brokerServiceUrl": "pulsar://pulsar:6650"}'

echo -e "\nSetup completed!"
echo "You can now access Pulsar Manager at http://localhost:9527"
echo "Username: admin"
echo "Password: apachepulsar"
