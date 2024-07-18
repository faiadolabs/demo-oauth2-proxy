#!/bin/bash

# Chequeo si existe un fichero en ./bin/oauth2-proxy
# En caso de no existir, doy instrucciones y salgo
if [ ! -f "./bin/oauth2-proxy" ]; then
    echo -e "\n\t🚧 No se ha encontrado el binario de oauth2-proxy en ./bin/oauth2-proxy"
    echo -e "\n\tPor favor, descargue el binario de oauth2-proxy para tu arquitectura desde..."
    echo -e "\n\thttps://github.com/oauth2-proxy/oauth2-proxy/releases/tag/v7.6.0"
    echo -e "\n\tDescomprime y renombra colócandolo como ./bin/oauth2-proxy\n"
    exit 1
fi

# Compruebo que tengo docker instalado
if ! [ -x "$(command -v docker)" ]; then
    echo -e "\n\t🚧 No se ha encontrado el comando docker"
    echo -e "\n\tPor favor, instale docker desde..."
    echo -e "\n\thttps://docs.docker.com/get-docker/\n"
    exit 1
fi

echo -e "\n🚧 Se procederá a levantar lo siguiente..."
echo -e "\n\t⚙️ 1- Keycloak en http://localhost:8080"
echo -e "\n\t⚙️ 2- Un servicio WEB protegido en http://localhost:8000"
echo -e "\n\t⚙️ 3- oauth2_proxy en http://localhost:4180 como servicio en docker 🐞 (not working)"
echo -e "\n\t⚙️ 4- oauth2_proxy en http://localhost:5180 ejecutado como binario en host local"
echo -e "\n"

# Implementa una cuenta atrás de 5 segundos
for i in {3..1}; do
    echo -ne "\r🚧 Iniciando en $i..."
    sleep 1
done
echo -e "\r🚀 Vamos allá! Llevará algo de tiempo levantar los servicios...\n"

# Lentantado los servicios con docker compose
docker compose up -d

# Lentantado proxy a través de binario
echo -e "\nLevantando oauth2-proxy alternativo..."
echo -e "\n\tVisita 👉  http://localhost:5180 para acceder ak servicio web a través del proxy"
echo -e "\nCTR+C para finalizar el proxy."
echo -e "\n'docker compose down' para detener resto de servicios"
echo -e "\n\n"

# Inicio oauth2_proxy en host local
./start_oauth2_proxy_to_keycloak.sh
