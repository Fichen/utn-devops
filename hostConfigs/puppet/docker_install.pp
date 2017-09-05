class docker_install {
exec { 'apt-update':                    
  command => '/usr/bin/apt-get update'  
}

exec { 'agrego-repositorio':                    
  command => '/usr/bin/add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable"'  
}


exec { 'docker_dependences':                    
  command => '/usr/bin/apt-get install -y apt-transport-https ca-certificates curl software-properties-common'  
}

# instalación del paquete docker
package { 'docker-ce':
  require => Exec['agrego-repositorio','apt-update','docker_dependences'],       
  ensure => installed,
}

package { 'docker-compose':
  require => Exec['apt-update'],        
  ensure => installed,
}

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
}