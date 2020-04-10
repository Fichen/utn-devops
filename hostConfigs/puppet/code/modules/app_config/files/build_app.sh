#!/bin/bash

APP_WORKDIR=$1
COMMIT=$2
ENVIRONMENT=$3
CI_SERVER_WORKSPACE=$4
DEFAULT_BRANCH="unidad-2-rc"


function command_as_current_user_dir() {
    local ARG=$1
    cd $APP_WORKDIR
    CURRENT_USER=$(ls -ld . | awk '{print $3}')
    sudo su $CURRENT_USER -c " ${ARG} "
    #echo "sudo su $CURRENT_USER -c ${ARG} "
}

function regenerate_docker_images() {
    cd "$APP_WORKDIR/myapp"
    echo "cd $APP_WORKDIR/myapp"
    echo "Stopping docker-compose"
    sudo docker-compose down
    echo "Building context"
    sudo docker-compose build
    echo "Starting up and configuring app"
    sudo docker-compose up -d
    sudo docker exec apache2_php composer install --no-scripts --prefer-dist
    sudo docker exec apache2_php chmod 0777 -R storage bootstrap/cache
    sudo docker exec apache2_php php artisan migrate:refresh
    sudo docker exec apache2_php php artisan config:clear
}

if [ "$APP_WORKDIR" = "" ]; then
    echo "APP_WORKDIR required; ie /var/www/utn-devops-app"
    exit 1
fi

if [ "$COMMIT" = "" ]; then
    echo "No commit ref assigned, switching to unidad-2-rc"
    COMMIT=$DEFAULT_BRANCH
fi

if [ "$ENVIRONMENT" = "ci-server" ]; then
    echo "Copying env file in ${ENVIRONMENT}"
    sudo cp -f ${APP_WORKDIR}/.env ${CI_SERVER_WORKSPACE}/myapp/.env
    regenerate_docker_images
    exit 0
fi

if [ ! -d "$APP_WORKDIR/.git" ]; then
    command_as_current_user_dir 'git init'
    command_as_current_user_dir 'git remote add origin https://github.com/Fichen/utn-devops-app.git'
    command_as_current_user_dir 'git fetch --all'
fi

command_as_current_user_dir 'git pull'
command_as_current_user_dir "git checkout $COMMIT"

echo "Copying env file"
command_as_current_user_dir "cp -p $APP_WORKDIR/.env $APP_WORKDIR/myapp/.env"
regenerate_docker_images

exit 0
