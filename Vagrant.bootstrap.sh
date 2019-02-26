#!/bin/bash

sudo mkdir /swapdir
cd /swapdir
sudo dd if=/dev/zero of=/swapdir/swapfile bs=1024 count=2000000
sudo mkswap -f  /swapdir/swapfile
sudo chmod 600 /swapdir/swapfile
sudo swapon swapfile

#Aprovisionamiento de software

###### Configuración de Puppet ######

# Muevo el archivo de configuración de Puppet al lugar correspondiente
sudo mv -f /tmp/puppet-master.conf /etc/puppet/puppet.conf

# elimino certificados de que se generan en la instalación.
# no nos sirven ya que el certificado depende del nombre que se asigne al maestro
# y en este ejemplo se modifico.
sudo rm -rf /var/lib/puppet/ssl

# muevo los archivos que utiliza Puppet
sudo mv -f /tmp/site.pp /etc/puppet/manifests/
sudo mv -f /tmp/init.pp /etc/puppet/modules/docker_install/manifests/init.pp
sudo mv -f /tmp/env /etc/puppet/modules/docker_install/files
sudo mv -f /tmp/init_jenkins.pp /etc/puppet/modules/jenkins/manifests/init.pp
sudo mv -f /tmp/jenkins_default /etc/puppet/modules/jenkins/files/jenkins_default
sudo mv -f /tmp/jenkins_init_d /etc/puppet/modules/jenkins/files/jenkins_init_d

sudo dos2unix /etc/puppet/modules/jenkins/files/jenkins_init_d


# al detener e iniciar el servicio se regeneran los certificados 
sudo service puppetmaster stop && service puppetmaster start

# limpieza de configuración del dominio utn-devops.localhost es nuestro nodo agente.
# en nuestro caso es la misma máquina
sudo puppet node clean utn-devops

# Habilito el agente
sudo puppet agent --certname utn-devops --enable

