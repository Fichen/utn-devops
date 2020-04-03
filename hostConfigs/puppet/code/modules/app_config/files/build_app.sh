#!/bin/bash

APP_WORKDIR=$1
COMMIT=$2
ENVIRONMENT=$3
DEFAULT_BRANCH="unidad-2-rc"

if [ "$APP_WORKDIR" = "" ]; then
    echo "APP_WORKDIR required; ie /var/www/utn-devops-app"
    exit 1
fi

if [ "$COMMIT" = "" ]; then
    echo "Not commit ref assigned, switching to unidad-2-rc"
    COMMIT=$DEFAULT_BRANCH
fi

if [ "$ENVIRONMENT" = "ci-server" ]; then
    sudo cp "${APP_WORKDIR}/.env" .
    cd "$APP_WORKDIR/myapp"
    sudo docker-compose down
    composer install --no-scripts --prefer-dist
    chmod 777 myapp/storage/app myapp/storage/framework myapp/storage/logs bootstrap/cache
    sudo docker-compose build --pull
    sudo docker-compose up -d
    exit 0
fi

echo "Applying puppet manifests"
sudo puppet agent -t

cd $APP_WORKDIR
CURRENT_USER=$(ls -ld . | awk '{print $3}')
APP_USER_COMMAND="sudo su $CURRENT_USER -c "

if [ ! -d "$APP_WORKDIR/.git" ]; then
    $APP_USER_COMMAND 'git init'
    $APP_USER_COMMAND 'git remote add origin https://github.com/Fichen/utn-devops-app.git'
    $APP_USER_COMMAND 'git fetch --all'
fi

$APP_USER_COMMAND 'git pull'
$APP_USER_COMMAND "git checkout $COMMIT"

$APP_USER_COMMAND "cp -p $APP_WORKDIR/.env $APP_WORKDIR/myapp/.env"
cd "$APP_WORKDIR/myapp"
sudo docker-compose down
sudo docker-compose build --pull
sudo docker-compose up -d
sudo docker exec -ti apache2_php composer install --no-scripts --prefer-dist
sudo docker exec -ti apache2_php chmod 777 storage/app storage/framework storage/logs bootstrap/cache