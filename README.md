# Práctica integradora

Esta práctica tiene como objetivo mostrar la utilización un stack de herramientas para instanciar un pipeline de Integración Continua y Despliegue Continuo (CI/CD)

El stack de herramientas es el siguiente:
  - [Vagrant](https://www.vagrantup.com/)
  - [VirtualBox](https://www.virtualbox.org/)
  - [Git](https://git-scm.com/)
  - [Docker y Docker-compose](https://www.docker.com/)
  - [Puppet](https://puppet.com/)
  - [Jenkins](https://jenkins.io/)
  - [Laravel](https://laravel.com/) como una aplicación de ejemplo

## La arquitectura planteada consiste de los siguientes servidores:
### puppet-master
Configuration management para todos los nodos. Se encarga de aprovisionar y mantener los nodos en el estado deseado. Por ejemplo: ssh keys, usuarios, etc.
### ci-server
Ejecuta Jenkins para CI/CD: Se encarga de hacer el build de la aplicación, ejecutar las pruebas automáticas y lanzar el deploy en el resto de los ambientes.
Además, en este mismo servidor contiene un registry privado para tener una imagen base de la aplicación ya compilada y posibiiltr despligues en los ambientes develop y test sin necesidad de ir al Hub cloud.
### develop
Ambiente de pruebas para desarrolladores
### test
Ambiente de pruebas de aceptación
### local-dev
Ambiente de desarrollo local para un desarrollador

### Private docker registry - ci-server
Iniciar el servicio registry y construir la imagen base para la aplicación
```sh
# cd /home/vagrant/docker-registry
# docker-compose up -d
# cd base_image
# docker build -f Dockerfile.base -t docker-registry.int:5000/myapp-example:latest .
# docker run -d docker-registry.int:5000/myapp-example
# docker commit $(docker ps -lq) docker-registry.int:5000/myapp-example:latest
# docker login https://docker-registry.int:5000 --username admin --password admin
# docker push docker-registry.int:5000/myapp-example
```

Se puede testear con
```sh
# curl https://docker-registry.int:5000/v2/_catalog
```

