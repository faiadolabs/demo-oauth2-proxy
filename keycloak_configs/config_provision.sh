#!/bin/bash

echo -e "\n 🚧 🚧 Intentando setup... puede que no esté todavía listo... 🚧 🚧 \n";

CONFIG_FILE="/tmp/kcadm.config"
REALM=master
CLIENT_ID_FOR_PROXY="oauth2_proxy"
CLIENT_ID_FOR_SCRIPT="pyscript"

# Usuario
username="bob"
email="bob@example.com"
firstName="Bob"
lastName="Smith"
user_password="123"

# Obtener un token para administrar keycloak
/opt/keycloak/bin/kcadm.sh config credentials \
    --server http://keycloak:8080 \
    --realm $REALM \
    --user $KEYCLOAK_ADMIN \
    --password $KEYCLOAK_ADMIN_PASSWORD \
    --config "$CONFIG_FILE"

/opt/keycloak/bin/kcadm.sh get clients -r $REALM --config "$CONFIG_FILE" | grep -q '"clientId" *: *"oauth2_proxy"' \
        && RESPONSE="Client exists" \
        || RESPONSE="Client does not exist"

if [ "$RESPONSE" = "Client does not exist" ]; then

    set -e
    
    # creo un client en el realm
    /opt/keycloak/bin/kcadm.sh create clients \
        --server http://keycloak:8080 \
        -r $REALM \
        -f "$CLIENT_ID_FOR_PROXY.json" \
        --config "$CONFIG_FILE"
    echo -e "✅ El client_Id $CLIENT_ID_FOR_PROXY se ha creado correctamente"
    
    /opt/keycloak/bin/kcadm.sh create clients \
        --server http://keycloak:8080 \
        -r $REALM \
        -f "$CLIENT_ID_FOR_SCRIPT.json" \
        --config "$CONFIG_FILE"
    echo -e "✅ El client_Id $CLIENT_ID_FOR_SCRIPT se ha creado correctamente"

    # Creo un usuario 
    /opt/keycloak/bin/kcadm.sh create users \
        --server http://keycloak:8080 \
        -r $REALM -s "username=$username" \
        -s "email=$email" \
        -s "firstName=$firstName" \
        -s "lastName=$lastName" \
        -s "enabled=true" \
        --config "$CONFIG_FILE"

    echo -e "✅ El usuario $username ($email) se ha creado correctamente"

    # Recupero el ID del usuario creado (pero ya no hace falta)
    # USER_ID=$(/opt/keycloak/bin/kcadm.sh get users --server http://keycloak:8080 -r $REALM -q username=$username --fields id --config "$CONFIG_FILE" --format csv |  tr -d '"')

    # Re-establezco la contraseña
    /opt/keycloak/bin/kcadm.sh set-password --server http://keycloak:8080 -r $REALM --username $username --new-password $user_password --config "$CONFIG_FILE"

    echo -e "✅ Restablecida la contraseña del $username a '$user_password' ☠️"

else 
    echo -e "\n\n✅ El client_Id $CLIENT_ID ya existe ✅ \n\n"
fi

/opt/keycloak/bin/kcadm.sh create users \
    --server http://keycloak:8080 \
    -r $REALM \
    -s "username=$username" \
    -s "email=$email" \
    -s "firstName=Bob" \
    -s "lastName=Smith" \
    --config "$CONFIG_FILE"

rm $CONFIG_FILE
