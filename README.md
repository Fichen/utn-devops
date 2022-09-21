# TP #2
A partir del TP anterior, dockerizar la API desarrollada y almacenar los jugadores en una base de datos.
Los contenedores tienen que tener una única responsabilidad por lo cual uno tiene que actuar de aplicación y el otro de ejecutar la instancia de la base de datos. El puerto de acceso desde la máquina host tiene que el 8081. Es decir se tiene que poder acceder através de http://localhost:8081/players.
Además tienen que agregar un test unitario que pueda ejecutarse por la terminal de comandos

## Requisitos
 - nodejs: >=14
 - npm: >= 8.14
 - Docker y docker-compose

### Instalación y ejecución
```
npm install
npm run build
docker-compose build
docker-compose up -d
```

Abrir la url http://localhost:8081/players para visualizar el resultado
