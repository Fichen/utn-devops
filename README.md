# Práctica integradora

Esta práctica tiene como objetivo mostrar la utilización un stack de herramientas para instanciar un pipeline de Integración Continua y Despliegue Continuo (CI/CD)

El stack de herramientas es el siguiente:
  - [Vagrant](https://www.vagrantup.com/)
  - [VirtualBox](https://www.virtualbox.org/)
  - [Git](https://git-scm.com/)
  - [Docker y Docker-compose](https://www.docker.com/)
  - [Puppet](https://puppet.com/)
  - [Jenkins](https://jenkins.io/)
  - [Laravel](https://laravel.com/) como aplicación de ejemplo

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

# Setup

### Host
Iniciar la infraestructura. Suponiendo que el proyecto este en el directorio raíz del usuario actual con el nombre utn-devops.
Si es Windows mediante la terminal Command Pront
```sh
cd %HOMEDRIVE%%HOMEPATH%\utn-devops
```
Si es Windows mediante la terminal PowerShell
```sh
cd ~/utn-devops
```
Iniciar las máquinas virtuales y aprovisionarlas.
```sh
vagrant up --provision
```
A las VMs se ingresa mediante Vagrant: vagrant ssh [NOMBRE VM].
Ejemplo de ingresar a puppet-master
```sh
vagrant ssh puppet-master
```

### puppet-master
Firmar todo los nodos para el aprovisionamiento y configuración
```sh
$ sudo puppet cert sign --all
```
Se puede verificar la firma si observa un signo "+" como prefijo del nombre de dominio
```sh
sudo puppet cert list --all
+ "ci-server.utn-devops.int"           (SHA256) E2:EC:16:DA:7A:49:C3:8C:FC:0A:46:13:10:27:37:3C:5D:93:55:D6:7D:3D:BD:CE:75:3B:BE:08:E8:25:C5:62
+ "develop.utn-devops.int"             (SHA256) DD:39:17:54:4F:DF:EB:02:25:92:6A:4B:F6:32:5A:64:0E:89:ED:E1:2A:E9:51:E8:82:0B:F5:47:23:A2:47:7C
+ "puppet-master.utn-devops.localhost" (SHA256) 0C:EB:34:72:06:CB:99:CA:9D:D7:AC:E3:7A:B7:9D:0B:43:11:BD:7D:9E:60:C4:79:2D:5A:24:A3:A2:BB:D2:48 (alt names: "DNS:puppet", "DNS:puppet-master", "DNS:puppet-master.utn-devops.localhost")
```

### ci-server
Iniciar el servicio registry, construir la imagen base para la aplicación, y liberación de espacio en disco
```sh
$ sudo su
# rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin
# cd /home/vagrant/docker-registry
# docker-compose up -d
# cd base_image
# docker build -f Dockerfile.base -t myapp-example:latest .
# docker run -d myapp-example
# docker commit $(docker ps -lq) myapp-example:latest
# docker tag myapp-example docker-registry.int:5000/myapp-example:latest
# docker login https://docker-registry.int:5000 --username admin --password admin
# docker push docker-registry.int:5000/myapp-example
# docker rmi myapp-example
# docker rmi $(docker images --filter dangling=true -q --no-trunc) --force
# for i in $(docker ps --all -q); do docker container rm $i;done
```

Se puede testear que funcione el contenedor y la autenticación con
```sh
# curl https://docker-registry.int:5000/v2/_catalog
{"errors":[{"code":"UNAUTHORIZED","message":"authentication required","detail":[{"Type":"registry","Class":"","Name":"catalog","Action":"*"}]}]}
```

Agregar fingerprints de hosts develop y test a known_hosts. Esto es necesario para que Jenkins pueda hacer el deploy mediante ssh
```sh
$ sudo su jenkins
# ssh-keyscan -H develop test > ~/.ssh/known_hosts
```
