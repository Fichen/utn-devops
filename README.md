# Práctica integradora

Esta práctica tiene como objetivo mostrar la utilización de un stack de herramientas para instanciar un pipeline de Integración Continua y Despliegue Continuo (CI/CD)

El stack de herramientas es el siguiente:
  - [Vagrant](https://www.vagrantup.com/)
  - [VirtualBox](https://www.virtualbox.org/)
  - [Git](https://git-scm.com/)
  - [Docker y Docker-compose](https://www.docker.com/)
  - [Puppet](https://puppet.com/)
  - [Jenkins](https://jenkins.io/)
  - [Laravel](https://laravel.com/) como aplicación de ejemplo

## Requisitos
 __Instalación en el equipo host:__
 - Vagrant
 - Virtualbox
 - Git

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
git clone https://github.com/Fichen/utn-devops.git
```
```sh
cd %HOMEDRIVE%%HOMEPATH%\utn-devops
```
Si es Windows mediante la terminal PowerShell
```sh
cd ~/utn-devops
```
```sh
git checkout demo
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

## Puppet
Una vez instalados todas las VMs ingresar a puppet-master y revocar todos los certificados:
```sh
vagrant ssh puppet-master
$ sudo puppet node clean ci-server.utn-devops.int develop.utn-devops.int test.utn-devops.int
```
Se pueden verifican los certificados firmados si observa un signo "+" como prefijo del nombre de dominio. Ejemplo
```sh
$ sudo puppet cert list --all
Notice: Signed certificate request for ca
+ "puppet-master.utn-devops.int" (SHA256) 0C:EB:34:72:06:CB:99:CA:9D:D7:AC:E3:7A:B7:9D:0B:43:11:BD:7D:9E:60:C4:79:2D:5A:24:A3:A2:BB:D2:48 (alt names: "DNS:puppet", "DNS:puppet-master", "DNS:puppet-master.utn-devops.int")
$ exit
```

Para comenzar a utilizar Puppet en los agentes, hay que borrar los certificados autogenerados en la instalación y realizar una petición a Master
Esto hay que realizarlo en los servidores: ci-server, develop y test para generar los certificados SSL.
Ejemplo para ci-server
```sh
vagrant ssh ci-server
$ sudo rm -rf /var/lib/puppet/ssl
$ sudo puppet agent -tv
$ exit
```
__Repetir esto último para develop y test__


Si durante la ejecución de puppet agent -tv se observa algún error, esperar que finalice y ejecutarlo nuevamente.
Hay ocasiones que por timeout algunos paquetes no logran instalarse correctamente. Ej:
```sh
Error: Command exceeded timeout
Error: /Stage[main]/Docker_install/Exec[install-docker-compose]/returns: change from 'notrun' to ['0'] failed: Command exceeded timeout
Notice: /Stage[main]/Docker_install/Exec[permission-docker-compose]: Dependency Exec[install-docker-compose] has failures: true
Warning: /Stage[main]/Docker_install/Exec[permission-docker-compose]: Skipping because of failed dependencies
```


Luego hay que ingresar a puppet-master y firmar el certificado. En este caso es para el servidor ci-server
```sh
vagrant ssh puppet-master
$ sudo puppet cert sign ci-server.utn-devops.int
Signing Certificate Request for:
  "ci-server.utn-devops.int" (SHA256) 4B:60:DB:D0:17:B2:A3:14:59:FB:47:F3:B7:6C:99:D8:C6:DD:6E:43:63:2A:CD:67:B1:C4:34:AE:73:24:E7:F6
Notice: Signed certificate request for ci-server.utn-devops.int
Notice: Removing file Puppet::SSL::CertificateRequest ci-server.utn-devops.int at '/var/lib/puppet/ssl/ca/requests/ci-server.utn-devops.int.pem'
```

Con este comando se pueden firman todos los nodos agent, sin necesidad de espeficiar el dominio.
```sh
$ sudo puppet cert sign --all
$ exit
```

## VM ci-server

__Docker Registry__


```sh
vagrant ssh ci-server
$ sudo su
# cd /home/vagrant/docker-registry
# docker-compose up -d
```
Se puede testear que funcione el contenedor y la autenticación con
```sh
# curl -u admin:admin https://docker-registry.int:5000/v2/_catalog
{"repositories":["myapp-example"]}
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
```
Se puede comprobar la subida de la imagen base con el siguiente comando
```sh
# curl -u admin:admin https://docker-registry.int:5000/v2/myapp-example/tags/list
{"name":"myapp-example","tags":["1.0.0","latest"]}
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
User: admin
Password: secret
Confirm Password: secret
Full name: Admin
Email: admin@test
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
  - Branch Specifier: */demo
  - Script Path: hostConfigs/jenkins/Jenkinsfile
  - Clic on "Apply" & "Save"

__Test pipeline__

- Clic on ["Build now"](http://ci-server.utn-devops.localhost:8082/job/app-test/build?delay=0sec)
- Enter into the build and clic on "console output" to verify the job. To check the first build enter [here](http://ci-server.utn-devops.localhost:8082/job/app-test/1/console)

__Check deploy at develop server__
 - Enter into http://develop.utn-devops.int:8081

You should view three boxes with some data. The first one which is on the top it should have a message like this:
 - "Aplicación de ejemplo: PHP (Laravel) + MySQL"

__That is pretty much all__
