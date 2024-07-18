#!/bin/bash

# docker run -d --rm -p 8000:80 nginx

URL_PROTECTED_SERVICE=http://localhost:8000
COOKIE_SECRET=1234567890123456
PROVIDER=oidc
CLIENT_ID=oauth2_proxy
CLIENT_SECRET=M1wfTHzrqb6Jp1TjAmqnvPUQnOfJPRFU
PROXY_PORT=5180

./bin/oauth2-proxy \
    --http-address=0.0.0.0:$PROXY_PORT \
    --email-domain="*" \
    --cookie-secure=false \
    --cookie-secret=$COOKIE_SECRET \
    --upstream=$URL_PROTECTED_SERVICE \
    --provider=$PROVIDER \
    --oidc-issuer-url="http://localhost:8080/realms/master" \
    --insecure-oidc-allow-unverified-email=true \
    --login-url="http://localhost:8080/realms/master/protocol/openid-connect/auth" \
    --redeem-url="http://localhost:8080/realms/master/protocol/openid-connect/token" \
    --profile-url="http://localhost:8080/realms/master/protocol/openid-connect/userinfo" \
    --validate-url="http://localhost:8080/realms/master/protocol/openid-connect/userinfo" \
    --redirect-url="http://localhost:$PROXY_PORT/oauth2/callback" \
    --client-id=$CLIENT_ID \
    --client-secret=$CLIENT_SECRET