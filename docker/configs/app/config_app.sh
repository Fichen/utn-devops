#!/bin/bash


cd /var/www/html/myapp;

php composer.phar update -n
chmod -R 777 storage bootstrap/cache
