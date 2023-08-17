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
  # del puerto 8081 (web) de la maquina virtual se podrá acceder a través
  # del puerto 8081 de nuestro navegador.
  # Esto se realiza para poder darle visibilidad a los puertos de la maquina virtual
  # y además para que no se solapen los puertos con los de nuestra equipo en el caso de que
  # ese número de puerto este en uso.
  config.vm.network "forwarded_port", guest: 8081, host: 8081, auto_correct: true
  config.vm.network "forwarded_port", guest: 4400, host: 4400, auto_correct: true

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


  # Este comando transfiere un archivo desde la maquina host a la maquina cliente. 
  # Es para permitir el redireccionamiento de tráfico entre el máquina host y la vm
  config.vm.provision "file", source: "hostConfigs/ufw", destination: "/tmp/ufw"

  # En este archivo tendremos el provisionamiento de software necesario para nuestra
  # maquina virtual. Por ejemplo, servidor web, servidor de base de datos, etc.
  config.vm.provision :shell, path: "Vagrant.bootstrap.sh", run: "always"
end