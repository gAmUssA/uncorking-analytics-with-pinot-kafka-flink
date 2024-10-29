#!/bin/sh

echo "Starting Pulsar Manager initialization script..."

# Install curl
apk add --no-cache curl

# Wait for Pulsar Manager to start
echo "Waiting for Pulsar Manager to start..."

# Create superuser
echo "Creating superuser..."
curl -sS -X PUT http://pulsar-manager:7750/pulsar-manager/users/superuser \
  -H "Content-Type: application/json" \
  -d '{"name": "admin", "password": "apachepulsar", "description": "test", "email": "username@test.org"}'

echo

echo "Pulsar Manager initialization completed."