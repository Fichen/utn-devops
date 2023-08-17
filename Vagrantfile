# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

   if Vagrant.has_plugin?("vagrant-vbguest") then
    config.vbguest.auto_update = false
  end
  
  #Imagen por defecto
  box = 'ubuntu/jammy64'
  
  #Si se ejecuta sobre macOS se configura otra imagen
  if Vagrant::Util::Platform.darwin? 
    box = "bento/ubuntu-22.04-arm64"
  else
    config.vm.provision "shell", inline: "sudo apt-get update && sudo apt-get install -y virtualbox-guest-x11"
  end

  # Con esto le indicamos a Vagrant que vaya al directorio de "cajas" (boxes) que contiene su Atlas e instale un
  # Ubuntu 64 bits mediante el gestor de maquinas virtuales VirtualBox
  # El directorio completo de boxes se puede ver en la siguiente URL https://app.vagrantup.com/boxes/search
  config.vm.box = box
  
 # Redirecciono puertos desde la maquina virtual a la maquina real. Por ejemplo
  # del puerto 8082 de la VM se podrá acceder a través del puerto 8082 de nuestro navegador.
  # Esto se realiza para poder darle visibilidad a los puertos de la maquina virtual
  # y además para que no se solapen los puertos con los de nuestra equipo en el caso de que
  # ese número de puerto este en uso.
  config.vm.network "forwarded_port", guest: 8082, host: 8082, auto_correct: true
  # Puerto en que escuchar el servidor maestro de Puppet
  config.vm.network "forwarded_port", guest: 8140, host: 8140, auto_correct: true
  
  #Permite descargas con certificados vencidos o por http
  config.vm.box_download_insecure = true

  # configuración del nombre de maquina
  config.vm.hostname = "utn-devops.localhost"
  config.vm.boot_timeout = 3600

  #Configuro la cantidad de memoria ram de la VM para el proveedor VirtualBox
  config.vm.provider "virtualbox" do |v|
	  v.name = "utn-devops-vagrant-ubuntu"
    v.memory = "1024"
  end

  # Mapeo de directorios que se comparten entre la maquina virtual y nuestro equipo. En este caso es
  # el propio directorio donde está el archivo  y el directorio "/vagrant" dentro de la maquina virtual.
  config.vm.synced_folder ".", "/vagrant"

  #Configuro la cantidad de memoria ram de la VM para el proveedor VMware
  config.vm.provider "vmware_desktop" do |vm|
    vm.memory = "1024"
  end

  # Con esta sentencia lo que hara Vagrant es copiar el archivo a la máquina Ubuntu.
  # Además de usarlo como ejemplo para distinguir dos maneras de aprovisionamiento el archivo contiene
  # una definición del firewall de Ubuntu para permitir el tráfico de red que se redirecciona internamente.
  config.vm.provision "file", source: "hostConfigs/ufw", destination: "/tmp/utw"
  config.vm.provision "file", source: "hostConfigs/etc_hosts.txt", destination: "/tmp/etc_hosts.txt"
  # Archivos de Puppet
  config.vm.provision "file", source: "hostConfigs/puppet/site.pp", destination: "/tmp/site.pp"
  config.vm.provision "file", source: "hostConfigs/puppet/init.pp", destination: "/tmp/init.pp"
  config.vm.provision "file", source: "hostConfigs/puppet/init_jenkins.pp", destination: "/tmp/init_jenkins.pp"
  config.vm.provision "file", source: "hostConfigs/puppet/puppet-master.conf", destination: "/tmp/puppet-master.conf"
  config.vm.provision "file", source: "hostConfigs/puppet/.env", destination: "/tmp/env"

  # En este archivo tendremos el provisionamiento de software necesario para nuestra
  # maquina virtual. Por ejemplo, servidor web, servidor de base de datos, etc.
  config.vm.provision :shell, path: "Vagrant.bootstrap.sh", run: "always"
end
