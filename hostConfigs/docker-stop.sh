#!/bin/bash

#Detener todos los contenedores
docker stop $( docker ps |awk '{print $1}' |grep -v CONTAINER);
