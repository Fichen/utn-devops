#!/bin/bash

##Genero una partición swap. Previene errores de falta de memoria
if [ ! -f "/swapdir/swapfile" ]; then
	sudo mkdir /swapdir
	cd /swapdir
	sudo dd if=/dev/zero of=/swapdir/swapfile bs=1024 count=2000000
	sudo mkswap -f  /swapdir/swapfile
	sudo chmod 600 /swapdir/swapfile
	sudo swapon swapfile
	echo "/swapdir/swapfile       none    swap    sw      0       0" | sudo tee -a /etc/fstab /etc/fstab
	sudo sysctl vm.swappiness=10
	echo vm.swappiness = 10 | sudo tee -a /etc/sysctl.conf
fi

###### Puppet ######
#Directories
PUPPET_DIR="/etc/puppet"
CODE_DIR="${PUPPET_DIR}/code"

if [ ! -x "$(command -v puppet)" ]; then

	#### Instalacion puppet master
  #Directorios

	sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe"
 	sudo apt-get update
	sudo apt install -y puppetmaster ruby-msgpack

  # Esto es necesario en entornos reales para posibilitar la sincronizacion
  # entre master y agents
	sudo timedatectl set-timezone America/Argentina/Buenos_Aires
	sudo apt-get -y install ntp
	sudo systemctl restart ntp

  # elimino certificados de que se generan en la instalación.
  # no nos sirven ya que el certificado depende del nombre que se asigne al maestro
  # y en este ejemplo se modifico.
  sudo rm -rf /var/lib/puppet/ssl

  # Agrego el usuario puppet al grupo de sudo, para no necesitar password al reiniciar un servicio
  sudo usermod -a -G sudo,puppet puppet

  sudo cp /usr/share/doc/puppet/examples/etckeeper-integration/*commit* $PUPPET_DIR
  sudo chmod 755 $PUPPET_DIR/etckeeper-commit-p*

fi

if [ -f "/tmp/hosts" ]; then
	sudo cp -f /tmp/hosts /etc/hosts
fi

# muevo los archivos que utiliza Puppet| compartido desde vagrant
#sudo cp -rf /vagrant/code/* $CODE_DIR

#Habilito el puerto en el firewall
sudo ufw allow 8140/tcp

# Muevo el archivo de configuración de Puppet al lugar correspondiente
if [ -f "/tmp/puppet-master.conf" ]; then
	echo "Copying puppet config file and restarting service"
	sudo cp -f /tmp/puppet-master.conf $PUPPET_DIR/puppet.conf
	sudo systemctl stop puppet && sudo systemctl start puppet
fi
