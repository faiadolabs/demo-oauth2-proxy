#!/bin/bash

URL_PROTECTED_SERVICE=http://localhost:8000
COOKIE_SECRET=1234567890123456
PROVIDER=google
CLIENT_ID=prueba01
CLIENT_SECRET=Zqkm3hbK3YztdTHhCTEFAxlgcQCrPVxj
PROXY_PORT=6180

./oauth2-proxy \
    --http-address=0.0.0.0:$PROXY_PORT \
    --email-domain=* \
    --cookie-secure=false \
    --cookie-secret=$COOKIE_SECRET \
    --upstream=$URL_PROTECTED_SERVICE \
    --provider=$PROVIDER \
    --client-id=$CLIENT_ID \
    --client-secret=$CLIENT_SECRET