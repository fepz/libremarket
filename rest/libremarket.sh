#!/bin/bash

start() {
    # Levantar los contenedores en segundo plano
    export COOKIE=secret
    export DOCKER_UID=$UID
    export DOCKER_GID=$GID
    docker compose up -d "$@"
}

stop() {
    export COOKIE=secret
    export DOCKER_UID=$UID
    export DOCKER_GID=$GID
    docker compose down
}

# Comprobar el argumento proporcionado
if [[ $1 == "start" ]]; then
    shift
    start "$@"
elif [[ $1 == "stop" ]]; then
    stop
elif [[ $1 == "build" ]]; then
    docker run -it --rm -v "$(pwd)":/app -w /app -u $(id -u):$(id -g) -e MIX_HOME=/app/mix_home -e HEX_HOME=/app/hex_home --network host elixir:alpine mix compile
elif [[ $1 == "iex" ]]; then
    shift
    SNAME="${1:-n1}"
    COOKIE="${2:-secret}"
    docker run -it --rm -v "$(pwd)":/app -w /app -u $(id -u):$(id -g) --network host -e COOKIE=$COOKIE -e MIX_HOME=/app/mix_home -e HEX_HOME=/app/hex_home elixir:alpine iex --sname $SNAME --cookie $COOKIE -S mix 
else
    echo "Uso: $0 {start|stop|build|iex nombre_de_contenedor}"
    exit 1
fi
