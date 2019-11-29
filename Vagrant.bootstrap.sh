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

###### Configuración de Puppet ######
#configuración de repositorio
if [ -x "$(command -v puppet)" ]; then


    #### Instalacion puppet master
    #Directorios
    PUPPET_DIR="/etc/puppet"
    ENVIRONMENT_DIR="${PUPPET_DIR}/code/environments/production"
    PUPPET_MODULES="${ENVIRONMENT_DIR}/modules"

    sudo mv -f /tmp/puppet-master.conf $PUPPET_DIR/puppet.conf
    
    # muevo los archivos que utiliza Puppet
    sudo mv -f /tmp/site.pp $ENVIRONMENT_DIR/manifests #/etc/puppet/manifests/
    sudo mv -f /tmp/init.pp $PUPPET_MODULES/docker_install/manifests/init.pp
    sudo mv -f /tmp/env $PUPPET_MODULES/docker_install/files
    sudo mv -f /tmp/init_jenkins.pp $PUPPET_MODULES/jenkins/manifests/init.pp
    sudo mv -f /tmp/jenkins_default $PUPPET_MODULES/jenkins/files/jenkins_default
    sudo mv -f /tmp/jenkins_init_d $PUPPET_MODULES/jenkins/files/jenkins_init_d

    # elimino certificados de que se generan en la instalación.
    # no nos sirven ya que el certificado depende del nombre que se asigne al maestro
    # y en este ejemplo se modifico.
    sudo rm -rf /var/lib/puppet/ssl

    # Acepto conexiones desde el puerto 8140
    sudo ufw allow 8140/tcp

    echo "Reiniciando servicios puppetmaster y puppet agent"
    sudo systemctl stop puppetmaster && sudo systemctl start puppetmaster
    sudo systemctl stop puppet && sudo systemctl start puppet

    # limpieza de configuración del dominio utn-devops.localhost es nuestro nodo agente.
    # en nuestro caso es la misma máquina
    sudo puppet node clean utn-devops

    # Habilito el agente
    sudo puppet agent --certname utn-devops --enable

fi