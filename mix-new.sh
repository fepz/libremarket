docker container run --rm -v "$(pwd)":/app -w /app --user $(id -u):$(id -g) elixir:alpine mix new $1
