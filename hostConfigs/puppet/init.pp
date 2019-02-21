class docker_install {
## Este archivo corresponde al módulo de configuración de puppet, el cual define
# una clase con ciertas especificaciones para instalación y aprovisionamiento. Si bien
# esta nombrado como docker install (instalación de docker) tiene una
# responsabilidad más amplia que es instalar algunos paquetes útiles para
# la aplicación así como también un archivo de configuración. Lo recomendando
# es que lo que es propio de la aplicación sea un módulo distinto.


# Agrego el repositorio para la instalación de Docker
exec { 'agrego-repositorio':                    
  command => '/usr/bin/add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable" && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -'  
} ->
# Actualización de repositorio. La declaracion de un bloque exec permite definir
# comandos que ejecutara el nodo cliente de Puppet
exec { 'apt-update':                    
  command => '/usr/bin/apt-get update'  
}

# Instalación del paquete docker. Tambien es para ejemplicar que se puede declarar
# como requisito que se ejecuten una serie de comandos antes de la instalación
package { 'docker-ce':
  require => Exec['apt-update','agrego-repositorio','apt-update'],       
  ensure => installed,
}

# Instalación del paquete docker-compose
package { 'docker-compose':
  require => Exec['apt-update'],        
  ensure => installed,
}

# Aprovisionamiento de configuración para la aplicación. Con esta declaracion
# se transfiere un archivo del servidor Puppet Master al nodo que contiene el agente
file { "/var/www/utn-devops-app/myapp/.env":
	mode => "0644",
    owner => 'root',
    group => 'root',
	ensure => 'present', 
    source => 'puppet:///modules/docker_install/env',
}

# asegurar que el servicio docker se este ejecutando
service { 'docker':
  ensure => running,
}

exec { 'config-app':
  command => 'docker-compose -f /vagrant/docker/docker-compose.yml up -d',       
  path => '/usr/bin',  
  onlyif => 'test $(docker ps |grep apache)',
}

 
}