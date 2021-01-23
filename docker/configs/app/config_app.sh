#!/bin/bash


cd /var/www/html/myapp;

composer update -n -q
chmod -R 777 storage bootstrap/cache
