#!/bin/bash

##Genero una partición swap. Previene errores de falta de memoria
if [ ! -f "/swapdir/swapfile" ]; then
	sudo mkdir /swapdir
	cd /swapdir
	sudo dd if=/dev/zero of=/swapdir/swapfile bs=1024 count=2000000
	sudo chmod 0600 /swapdir/swapfile
	sudo mkswap -f  /swapdir/swapfile
	sudo swapon swapfile
	echo "/swapdir/swapfile       none    swap    sw      0       0" | sudo tee -a /etc/fstab /etc/fstab
	sudo sysctl vm.swappiness=10
	echo vm.swappiness = 10 | sudo tee -a /etc/sysctl.conf
fi

if [ ! -x "$(command -v puppet)" ]; then
	#### Instalacion puppet
	sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe"
 	sudo apt-get update

	#### Instalacion puppet agent
	sudo apt install -y puppet ruby-msgpack

  	# Necesario para la sincronización entre puppet master y agent
	sudo timedatectl set-timezone America/Argentina/Buenos_Aires
	sudo apt-get -y install ntp
	sudo systemctl restart ntp
	echo "Ensure puppet agent is always running"
	sudo puppet resource service puppet ensure=running enable=true
fi

if [ -f "/tmp/hosts" ]; then
	sudo cp -f /tmp/hosts /etc/hosts
fi

# Allow port in firewall
sudo ufw allow 8140/tcp

if [ -f "/tmp/puppet-agent.conf" ]; then
	echo "Copying puppet config file and restarting service"
	sudo cp -f /tmp/puppet-agent.conf /etc/puppet/puppet.conf
	sudo systemctl stop puppet && sudo systemctl start puppet
fi

PUPPET_EXEC=$(sudo puppet agent -t --noop)
if [ $? -eq 0 ]; then
	echo "Try to remove certificates from this node and revoke the certificate in puppet master."
	echo "Execute the command sudo puppet agent -tv --noop and then login into puppet master and sign in the certificates"
fi

