#!/bin/bash

#Actualizo los paquetes de la maquina virtual
sudo apt-get update -y

#Aprovisionamiento de software
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common linux-image-extra-virtual-hwe-$(lsb_release -r |awk  '{ print $2 }') linux-image-extra-virtual

##Genero una partición swap. Previene errores de falta de memoria
if [ ! -f "/swapdir/swapfile" ]; then
	sudo mkdir /swapdir
	cd /swapdir
	sudo dd if=/dev/zero of=/swapdir/swapfile bs=1024 count=2000000
  sudo chmod 600 /swapdir/swapfile
	sudo mkswap -f  /swapdir/swapfile
	sudo swapon swapfile
	echo "/swapdir/swapfile       none    swap    sw      0       0" | sudo tee -a /etc/fstab /etc/fstab
	sudo sysctl vm.swappiness=10
	echo vm.swappiness = 10 | sudo tee -a /etc/sysctl.conf
fi
 

###### Puppet ######
#Directorios
PUPPET_DIR="/etc/puppet"
ENVIRONMENT_DIR="${PUPPET_DIR}/code/environments/production"
PUPPET_MODULES="${ENVIRONMENT_DIR}/modules"
if [ ! -x "$(command -v puppet)" ]; then
  #configuración de repositorio
  sudo add-apt-repository universe -y
  sudo add-apt-repository multiverse -y
  sudo apt-get update
  sudo apt install -y puppet-master
  
  #### Instalacion puppet agent
  sudo apt install -y puppet

  # Esto es necesario en entornos reales para posibilitar la sincronizacion
  # entre master y agents
  sudo timedatectl set-timezone America/Argentina/Buenos_Aires
  sudo apt-get -y install ntp

  # Muevo el archivo de configuración de Puppet al lugar correspondiente
  sudo mv -f /tmp/puppet-master.conf $PUPPET_DIR/puppet.conf

  # elimino certificados de que se generan en la instalación.
  # no nos sirven ya que el certificado depende del nombre que se asigne al maestro
  # y en este ejemplo se modifico.
  sudo rm -rf /var/lib/puppet/ssl

  # Agrego el usuario puppet al grupo de sudo, para no necesitar password al reiniciar un servicio
  sudo usermod -a -G sudo,puppet puppet

  # Estructura de directorios para crear el entorno de Puppet
  sudo mkdir -p $ENVIRONMENT_DIR/{manifests,modules,hieradata}

  # Estructura de directorios para crear el modulo de Jenkins
  sudo mkdir -p $PUPPET_MODULES/jenkins/{manifests,files}

  # Estructura de directorios para crear el modulo de Jenkins
  sudo mkdir -p $PUPPET_MODULES/jenkins/{manifests,files}

  sudo cp /usr/share/doc/puppet/examples/etckeeper-integration/*commit* $PUPPET_DIR
  sudo chmod 755 $PUPPET_DIR/etckeeper-commit-p*

fi

# muevo los archivos que utiliza Puppet
if [ -f "/tmp/site.pp" ]; then
  sudo cp -f /tmp/site.pp $ENVIRONMENT_DIR/manifests
fi

if [ -f "/tmp/init.pp" ]; then
  sudo cp -f /tmp/init.pp $PUPPET_MODULES/docker_install/manifests/init.pp
fi

if [ -f "/tmp/init_jenkins.pp" ]; then
  sudo cp -f /tmp/init_jenkins.pp $PUPPET_MODULES/jenkins/manifests/init.pp
fi
if [ -f "/tmp/jenkins_dependencies.pp" ]; then
  sudo cp -f /tmp/jenkins_dependencies.pp $PUPPET_MODULES/jenkins/manifests/dependencies.pp
fi


#Habilito el puerto en el firewall
sudo ufw allow 8140/tcp

sudo apt install ca-certificates && sudo apt-get update

# al detener e iniciar el servicio se regeneran los certificados
echo "Reiniciando servicios puppetmaster y puppet agent"
sudo systemctl stop puppetmaster && sudo systemctl start puppetmaster
sudo systemctl stop puppet && sudo systemctl start puppet

# limpieza de configuración del dominio utn-devops.localhost es nuestro nodo agente.
# en nuestro caso es la misma máquina
sudo puppet node clean utn-devops.localhost

# Habilito el agente
sudo puppet agent --certname utn-devops.localhost --enable
