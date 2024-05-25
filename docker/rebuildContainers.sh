#!/bin/bash

docker-compose down --remove-orphans --volumes
docker-compose build --no-cache
docker-compose up --force-recreate --detach
