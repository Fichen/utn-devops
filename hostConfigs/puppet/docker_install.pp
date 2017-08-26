class docker_install {
exec { 'apt-update':                    
  command => '/usr/bin/apt-get update'  
}

# instalación del paquete docker
package { 'docker-ce':
  require => Exec['apt-update'],       
  ensure => installed,
}

package { 'docker-compose':
  require => Exec['apt-update'],        
  ensure => installed,
}

# asegurar que el servicio docker se este ejecutando
service { 'docker':
  ensure => running,
}

}