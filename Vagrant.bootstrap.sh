#!/bin/bash

### Aprovisionamiento de software ###

# Actualizo los paquetes de la maquina virtual
sudo apt-get updates

# Instalo un servidor web
sudo apt-get install -y apache2 


### Configuración del entorno ###

# ruta raíz del servidor web
APACHE_ROOT="/var/www";
# ruta de la aplicación
APP_PATH="$APACHE_ROOT/utn-devops";


## configuración servidor web
#copio el archivo de configuración del repositorio en la configuración del servidor web
sudo mv /tmp/devops.site.conf /etc/apache2/sites-available
#activo el nuevo sitio web
sudo a2ensite devops.site.conf
#refresco el servicio del servidor web para que tome la nueva configuración
sudo service apache2 reload
	
