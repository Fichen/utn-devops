#!/bin/bash


cd /var/www/html/myapp;

php composer.phar update -n -q
chmod -R 777 storage bootstrap/cache
