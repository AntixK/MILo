CONTAINER_NAME := "milo-dev"

build-docker:
    docker compose -f docker-compose.yml build

run-docker:
    #!/usr/bin/env bash
    set -e
    if docker compose ps --services --filter "status=running" | grep -q {{CONTAINER_NAME}}; then
        echo "Attaching to running container {{CONTAINER_NAME}}"
        docker compose exec -it {{CONTAINER_NAME}} /bin/bash
    else
        echo "Starting container {{CONTAINER_NAME}}"
        docker compose -f docker-compose.yml up -d --build
        docker compose exec -it {{CONTAINER_NAME}} /bin/bash
    fi

stop-docker:
    #!/usr/bin/env bash
    if docker compose ps --services --filter "status=running" | grep -q {{CONTAINER_NAME}}; then
        echo "Stopping container {{CONTAINER_NAME}}"
        docker compose stop
    else
        echo "No running container {{CONTAINER_NAME}} found"
    fi

clean-docker:
    #!/usr/bin/env bash
    if docker compose ps -q {{CONTAINER_NAME}} | grep -q .; then
        echo "Stopping and removing container {{CONTAINER_NAME}}"
        docker compose down
    else
        echo "No running container {{CONTAINER_NAME}} found"
    fi