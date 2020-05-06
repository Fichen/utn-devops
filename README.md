# Práctica integradora - NOT COMPLETED

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

## Host
Iniciar la infraestructura. Suponiendo que el proyecto este en el directorio raíz del usuario actual con el nombre utn-devops.
Si es Windows mediante la terminal Command Pront
```sh
cd %HOMEDRIVE%%HOMEPATH%\utn-devops
```
Si es Windows mediante la terminal PowerShell
```sh
cd ~/utn-devops
```

Actualizar el archivo hosts para resolución de nombres de dominio.
En Windows se encuentra en la ruta "C:\Windows\System32\drivers\etc\hosts"
En Linux es en /etc/hosts
Para la edición se necesita permisos de administrador.

```sh
10.0.0.10       puppet-master.utn-devops.localhost  puppet-master
10.0.0.11       develop.utn-devops.int    develop
10.0.0.12       test.utn-devops.int   test
10.0.0.13       ci-server.utn-devops.int  ci-server docker-registry.int
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

## VM puppet-master
Firmar todo los nodos para el aprovisionamiento y configuración
```sh
$ sudo puppet cert sign --all
```
Se puede verificar la firma si observa un signo "+" como prefijo del nombre de dominio
```sh
$ sudo puppet cert list --all
+ "ci-server.utn-devops.int"           (SHA256) E2:EC:16:DA:7A:49:C3:8C:FC:0A:46:13:10:27:37:3C:5D:93:55:D6:7D:3D:BD:CE:75:3B:BE:08:E8:25:C5:62
+ "develop.utn-devops.int"             (SHA256) DD:39:17:54:4F:DF:EB:02:25:92:6A:4B:F6:32:5A:64:0E:89:ED:E1:2A:E9:51:E8:82:0B:F5:47:23:A2:47:7C
+ "puppet-master.utn-devops.localhost" (SHA256) 0C:EB:34:72:06:CB:99:CA:9D:D7:AC:E3:7A:B7:9D:0B:43:11:BD:7D:9E:60:C4:79:2D:5A:24:A3:A2:BB:D2:48 (alt names: "DNS:puppet", "DNS:puppet-master", "DNS:puppet-master.utn-devops.localhost")
$ exit
```

## VM ci-server
Iniciar el servicio registry, construir la imagen base para la aplicación, y liberación de espacio en disco
```sh
vagrant ssh ci-server
$ sudo su
# rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin
# puppet agent -tv
# cd /home/vagrant/docker-registry
# docker-compose up -d
```
Se puede testear que funcione el contenedor y la autenticación con
```sh
# curl -u admin:admin https://docker-registry.int:5000/v2/_catalog
{"repositories":[]}
```
Puesta en marcha del registry, compilación y subida de la imagen base

```sh
# cd base_image
# docker build -f Dockerfile.base -t myapp-example:latest .
# docker run -d myapp-example
# docker commit $(docker ps -lq) myapp-example:latest
# docker tag myapp-example docker-registry.int:5000/myapp-example:1.0.0
# docker login https://docker-registry.int:5000 --username admin --password admin
# docker push docker-registry.int:5000/myapp-example:1.0.0
# docker rmi myapp-example
#
```
Se puede comprar la subida de la imagen base con el siguiente comando
```sh
# curl -u admin:admin https://docker-registry.int:5000/v2/_catalog
{"repositories":["myapp-example"]}
```

Agregar fingerprints de hosts develop y test a known_hosts. Esto es necesario para que Jenkins pueda hacer el deploy mediante ssh
```sh
# su jenkins -c "ssh-keyscan -H develop test > ~/.ssh/known_hosts"
```

### Steps to configure CI/CD
* Copy initial password and paste it into Jenkins utl
```sh
 sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```
* Enter in [Jenkins CI Server](http://ci-server.utn-devops.localhost:8082/) and paste the hash here.
* Clic on "Install Suggested Plugins"

Create an Admin user. Fields to complete:
```
User
Password
Confirm Password
Full name
Email
```

- Clic on "Save and Continue"
- Clic on "Save and Finish"
- Clic on "Start using Jenkins"

__Job example creation__
- Enter in ["Create new Job"](http://ci-server.utn-devops.localhost:8082/newJob)
- Complete field "Enter an item name": ie, app-test
- Select option: "Pipeline"
- Clic on "Ok"
- Check "discard old builds"
  - Number of build to keep: 3
- Check "Do not allow concurrent builds"
- Check Repository SCM
  - Complete with: * * * * *
- Pipeline
  - Definition: select "Pipeline script from SCM"
  - SCM: Git
  - Repository URL: https://github.com/Fichen/utn-devops.git
  - Branch Specifier: */unidad-5-integrador
  - Script Path: hostConfigs/jenkins/Jenkinsfile
  - Clic on "Apply" & "Save"

__Test pipeline__

- Clic on ["Build now"](http://ci-server.utn-devops.localhost:8082/job/app-test/build?delay=0sec)
- Enter into the build and clic on "console output" to verify the job. To check the first build enter [here](http://ci-server.utn-devops.localhost:8082/job/app-test/1/console)
