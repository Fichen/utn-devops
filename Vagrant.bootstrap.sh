#!/bin/bash

### Aprovisionamiento de software ###

# Actualizo los paquetes de la maquina virtual
sudo apt-get updates

# Instalo un servidor web
sudo apt-get install -y apache2 

### Configuración del entorno ###

##Genero una partición swap. Previene errores de falta de memoria
mkdir /swapfile
cd /swapfile
sudo dd if=/dev/zero of=swap bs=1024 count=2000000
sudo mkswap -f  swap
sudo swapon swap

# ruta raíz del servidor web
APACHE_ROOT="/var/www";
# ruta de la aplicación
APP_PATH="$APACHE_ROOT/utn-devops-app";


## configuración servidor web
#copio el archivo de configuración del repositorio en la configuración del servidor web
if [ -f "/tmp/devops.site.conf" ]; then
	echo "Copio el archivo de configuracion de apache";
	sudo mv /tmp/devops.site.conf /etc/apache2/sites-available
	#activo el nuevo sitio web
	sudo a2ensite devops.site.conf
	#desactivo el default
	sudo a2dissite 000-default.conf
	#refresco el servicio del servidor web para que tome la nueva configuración
	sudo service apache2 reload
fi
	
## aplicación

# descargo la app del repositorio
if [ ! -d "$APP_PATH" ]; then
	echo "clono el repositorio";
	cd $APACHE_ROOT;
	sudo git clone https://github.com/Fichen/utn-devops-app.git;
	cd $APP_PATH;
	sudo git checkout unidad-1;
fi

