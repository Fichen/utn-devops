#!/usr/bin/bash

# Agrego repositorios a la maquina virtual
cat > /etc/apt/sources.list << EOF
# /etc/apt/sources.list :
deb http://security.debian.org/ jessie/updates main contrib non-free 
deb-src http://security.debian.org/ jessie/updates main contrib non-free

# /etc/apt/sources.list :
deb http://ftp.au.debian.org/debian/ jessie main contrib non-free
deb-src http://ftp.au.debian.org/debian/ jessie main contrib non-free
EOF

# Actualizo los paquetes de la maquina virtual con los nuevos repositorios
apt-get updates

# Instalo un servidor web
apt-get install -y apache2 

# Creo un enlace símbolico (en el caso que no este) entre el directorio compartido de Vagrant y el directorio
# público del servidor web recién instalado
if ! [ -L /var/www ]; then
  rm -rf /var/www
  ln -fs /vagrant /var/www
fi

