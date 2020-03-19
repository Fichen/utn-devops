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

if [ ! -x "$(command -v puppet)" ]; then

	#### Instalacion puppet master
  	#Directorios

	sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe"
 	sudo apt-get update

	#### Instalacion puppet agent
	sudo apt install -y puppet

  	# Esto es necesario en entornos reales para posibilitar la sincronizacion
  	# entre master y agents
	sudo timedatectl set-timezone America/Argentina/Buenos_Aires
	sudo apt-get -y install ntp
	sudo systemctl restart ntp
	sudo mv -f /tmp/puppet-agent.conf /etc/puppet/puppet.conf
fi

sudo cp -f /tmp/hosts /etc/hosts

#Habilito el puerto en el firewall
sudo ufw allow 8140/tcp

# al detener e iniciar el servicio se regeneran los certificados
echo "Reiniciando servicio puppet agent"
sudo systemctl stop puppet && sudo systemctl start puppet

sudo puppet resource service puppet ensure=running enable=true
