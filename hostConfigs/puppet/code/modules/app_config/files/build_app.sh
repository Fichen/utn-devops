#!/bin/bash

set -e
trap "exit 1" ERR


APP_WORKDIR=$1
COMMIT=$2
DEFAULT_BRANCH="unidad-2-rc"


function command_as_current_user_dir() {
    local ARG=$1
    cd $APP_WORKDIR
    CURRENT_USER=$(ls -ld . | awk '{print $3}')
    echo "Executing: sudo su $CURRENT_USER -c ${ARG} "
    sudo su $CURRENT_USER -c " ${ARG} "

    if [ $? -ne 0 ]; then
        echo "Error: aborting deploy"
        exit 1
    fi
}

function regenerate_docker_images() {
    cd "$APP_WORKDIR"
    echo "Pulling images"
    command_as_current_user_dir 'sudo docker-compose pull'
    echo "Restarting up and configuring app"
    command_as_current_user_dir 'sudo docker-compose stop'
    command_as_current_user_dir 'sudo docker-compose up -d'
    echo "Running migration scrips"
    command_as_current_user_dir 'sudo docker exec apache2_php chmod 0777 -R storage bootstrap/cache'
    command_as_current_user_dir 'sudo docker exec apache2_php php artisan migrate'
    command_as_current_user_dir 'sudo docker exec apache2_php php artisan config:clear'
}

function check_command_exit_code() {
    local $command=$1
}

if [ "$APP_WORKDIR" = "" ]; then
    echo "APP_WORKDIR required; ie /var/www/utn-devops-app"
    exit 1
fi

if [ "$COMMIT" = "" ]; then
    echo "No commit ref assigned, switching to $DEFAULT_BRANCH"
    COMMIT=$DEFAULT_BRANCH
fi

if [ ! -d "$APP_WORKDIR/.git" ]; then
    command_as_current_user_dir 'git init'
    command_as_current_user_dir 'git remote add origin https://github.com/Fichen/utn-devops-app.git'
    command_as_current_user_dir 'git fetch --all'
fi

command_as_current_user_dir 'git pull'
command_as_current_user_dir "git checkout $COMMIT"

echo "Building docker images and starting services"
regenerate_docker_images

exit 0
