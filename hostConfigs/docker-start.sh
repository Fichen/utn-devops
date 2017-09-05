#!/bin/bash

cd /vagrant/docker;

docker run -link apache2_php -v /var/db/mysql:/var/lib/mysql -d mysql;
docker run -v /var/www/utn-devops-app:/var/www/html -d -p 8081:80 apache2_php
docker run -v /var/db/mysql:/var/lib/mysql -p 4400:3306 -d mysql;
