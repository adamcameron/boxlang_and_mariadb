#!/bin/bash
docker-compose stop
docker-compose up --detach mariadb
docker-compose up --detach boxlang
