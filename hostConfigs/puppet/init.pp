## Este archivo corresponde al módulo de configuración de puppet, el cual define
# una clase con ciertas especificaciones para instalación y aprovisionamiento. Si bien
# esta nombrado como docker install (instalación de docker) tiene una
# responsabilidad más amplia que es instalar algunos paquetes útiles para
# la aplicación así como también un archivo de configuración. Lo recomendando
# es que lo que es propio de la aplicación sea un módulo distinto
class docker_install {

# Agrego el repositorio para la instalación de Docker
# La declaracion de un bloque exec permite definir comandos que ejecutara el nodo cliente de Puppet
exec { 'agrego-repositorio':
  command => 'install -m 0755 -d /etc/apt/keyrings | curl -fsSL https://download.docker.com/linux/ubuntu/gpg  
  | gpg --dearmor -o /etc/apt/keyrings/docker.gpg 
  |	chmod a+r /etc/apt/keyrings/docker.gpg
  | echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null',
  path    => '/usr/bin',
} -> exec { 'apt-update':# Actualización de repositorio. 
  command => '/usr/bin/apt-get update',
}

# Instalación del paquete docker. Tambien es para ejemplicar que se puede declarar
# como requisito que se ejecuten una serie de comandos antes de la instalación
$packages = ['docker-ce', 'docker-ce-cli', 'containerd.io', 'docker-buildx-plugin', 'docker-compose-plugin', 'docker-compose']

package { $packages:
  ensure  => installed,
  require => Exec['agrego-repositorio','apt-update'],
}

# Aprovisionamiento de configuración para la aplicación. Con esta declaracion
# se transfiere un archivo del servidor Puppet Master al nodo que contiene el agente
file { '/var/www/utn-devops-app/myapp/.env':
  ensure => 'present',
  mode   => '0644',
  owner  => 'root',
  group  => 'root',
  source => 'puppet:///modules/docker_install/env',
}

# asegurar que el servicio docker se este ejecutando
service { 'docker':
  ensure => running,
}

exec { 'config-app':
  command => 'docker-compose -f /vagrant/docker/docker-compose.yml up -d',
  path    => '/usr/bin',
  onlyif  => 'test $(docker ps |grep apache)',
}

}
