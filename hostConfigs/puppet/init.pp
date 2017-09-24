class docker_install {
# Actualización de repositorio
exec { 'apt-update':                    
  command => '/usr/bin/apt-get update'  
}
## Este archivo corresponde al módulo de configuración de puppet, el cual define
# una clase con ciertas especificaciones para instalación y aprovisionamiento. Si bien
# esta nombrado como docker install (instalación de docker) tiene una
# responsabilidad más amplia que es instalar algunos paquetes útiles para
# la aplicación así como también un archivo de configuración. Lo recomendando
# es que lo que es propio de la aplicación sea un módulo distinto.


# Agrego el repositorio para la instalación de Docker
exec { 'agrego-repositorio':                    
  command => '/usr/bin/add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable"'  
}

# Aprovisionamiento de software útil para docker y la aplicación
exec { 'docker_dependences':                    
  command => '/usr/bin/apt-get install -y apt-transport-https ca-certificates curl software-properties-common dos2unix'  
}

# Instalación del paquete docker
package { 'docker-ce':
  require => Exec['agrego-repositorio','apt-update','docker_dependences'],       
  ensure => installed,
}

# Instalación del paquete docker-compose
package { 'docker-compose':
  require => Exec['apt-update'],        
  ensure => installed,
}

# Aprovisionamiento de configuración para la aplicación
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