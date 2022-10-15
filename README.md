# TP #3
Crear una instancia de Jenkins y configurar los plugins iniciales. Hay una guía de instalación de Jenkins que la pueden encontrar [acá](https://www.jenkins.io/doc/book/installing/docker/) y está dividida según el sistema operativo que se utiliza (tengan en cuenta que tienen que instalar en Jenkins todas las dependencias que necesita su aplicación para se ejecute.

(Instalar los plugins sugeridos)

Crear un archivo Jenkinsfile para los siguientes stages:

* Checkout (obtiene los cambios del repositorio)
* Build (compila la aplicación que hayan construido)
* Test (ejecuta los tests que crearon)
* Deploy: solo cuando hay un nuevo tag con el prefijo "v". Por ejemplo, "v1.0.0". Como no habrá un deploy real solo se requiere mostrar por pantalla que se está haciendo el deploy.

## Requisitos
 - nodejs: >=14
 - npm: >= 8.14
 - Docker y docker-compose

### Instalación y ejecución de la aplicación
```
npm install
npm run build
docker-compose build
docker-compose up -d
```

Abrir la url http://localhost:8081/players para visualizar el resultado

-----------------

### Instalación Jenkins
```
sh jenkins/create.sh
docker logs myjenkins
```
Con el último comando van obtener los logs del contenedor que ejecuta Jenkins. De aquí podrán extraer la clave que se genera para poder ingresar como administrador en Jenkins

- Abrir la url http://localhost:8080/
- Instalar plugins sugeridos
- Crear una nueva tarea/job como pipemultibranch. 
 - Configurar los parametros de Git e incluir "Discover tags" como compartamiento (Behaviour) en branch sources
 - Configurar Scan Repository Triggers
 - El Jenkinsfile esta en el directorio: jenkins/Jenkinsfile
