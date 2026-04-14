#!/bin/bash

# docker compose --> v2 (GA, plugin)
# docker-compose --> v1/v2 (standalone binary, may not be installed)
if command -v docker-compose &>/dev/null; then
    VERSION=$(docker-compose version --short 2>/dev/null)
    if [[ "$VERSION" =~ ^1\.[0-9]+\.[0-9]+ ]]; then
        echo "Detected docker-compose v1, using docker compose (v2 plugin)"
        DOCKER_COMMAND="docker compose -f ${FILE} ${COMPOSE_FLAGS}"
    else
        echo "Detected docker-compose v2"
        DOCKER_COMMAND="docker-compose -f ${FILE} ${COMPOSE_FLAGS}"
    fi
else
    echo "docker-compose not found, using docker compose (v2 plugin)"
    DOCKER_COMMAND="docker compose -f ${FILE} ${COMPOSE_FLAGS}"
fi

eval $DOCKER_COMMAND ps
eval $DOCKER_COMMAND logs

regx='\(healthy\)'

# Set interval (duration) in seconds.
secs=${TIMEOUT}
endTime=$(( $(date +%s) + secs ))

# Loop until interval has elapsed.
# Version 2.21.0 of Docker Compose has introduced a change in its output format. This script must support both the old and new formats.
while [ $(date +%s) -lt $endTime ]; do
    # initialise counter with 0 since we're checking the status of each service
    cnt=0
    while IFS= read -r line; do
        if [[ $line =~ $regx ]]; then
            cnt=$((cnt+1))
        fi
    done <<< $(eval $DOCKER_COMMAND ps --format json | jq -n '[inputs] | flatten | .[].Status')
    echo -en "\rWaiting for services... $cnt/$(eval $DOCKER_COMMAND ps --format json | jq -n '[inputs] | flatten | .[].Status' | wc -l)"

    # see what happens
    eval $DOCKER_COMMAND ps
    eval $DOCKER_COMMAND logs

    if [[ $cnt -eq $(eval $DOCKER_COMMAND ps --format json | jq -n '[inputs] | flatten | .[].Status' | wc -l) ]]; then
        echo ""
        exit 0
    fi
    sleep 1
done

eval $DOCKER_COMMAND ps
eval $DOCKER_COMMAND logs

exit 1
