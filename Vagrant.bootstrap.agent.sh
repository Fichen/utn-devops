#!/bin/bash

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

if [ -f "/tmp/ufw" ]; then
	sudo cp -f /tmp/ufw /etc/default/ufw
fi

if [[ ! -z $(grep demo-puppet.int /etc/hosts) ]]; then
	sudo echo "10.0.1.10       master.demo-puppet.int  master" >> /etc/hosts
	sudo echo "10.0.1.11       master.demo-puppet.int  master" >> /etc/hosts
fi

###### Puppet ######
if [ ! -x "$(command -v puppet)" ]; then
	sudo apt-get update -y
	sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common linux-image-extra-virtual-hwe-$(lsb_release -r |awk  '{ print $2 }') linux-image-extra-virtual

	sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe"
	sudo apt-get update
	sudo apt install -y puppet ruby-msgpack

  	# sync master - agents
	sudo timedatectl set-timezone America/Argentina/Buenos_Aires
	sudo apt-get -y install ntp
	sudo systemctl restart ntp

	#
	sudo rm -rf /var/lib/puppet/ssl

	sudo usermod -a -G sudo,puppet puppet

	sudo puppet resource service puppet ensure=running enable=true
fi

# firewall
sudo ufw allow 8140/tcp

if [ -f "/tmp/puppet.conf" ]; then
	sudo cp -f /tmp/puppet.conf /etc/puppet/puppet.conf
	sudo systemctl stop puppet && sudo systemctl start puppet
fi
