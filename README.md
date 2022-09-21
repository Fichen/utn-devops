# TP #1
Crear una API (web service) que se ejecute en su dispositivo. La API debe exponer un recurso llamado players ("/players").
Debe tener dos "jugadores" distintos pre cargados sin necesidad de usar una base de datos.
Al hacer un HTTP request mediante el méthodo GET a /players debe devolver los jugadores con formato de respuesta JSON.
Los atributos de un jugador son los siguientes:
 - id: int
 - first name: string
 - last name: string
 - birthday: int (timestamp)

 La visualizacion del atributo birthday debe ser en formato dd/mm/yyyy)

## Requisitos
 - nodejs: >=14
 - npm: >= 8.14

### Instalación y ejecución
```
npm install
npm run dev
```

Abrir la url http://localhost:3000/players para visualizar el resultado
