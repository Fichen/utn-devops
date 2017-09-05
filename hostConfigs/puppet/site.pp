node default { }

node 'utn-devops' {
include 'docker_install'
#exec { 'docker-compose-up':                    
 # command => '/usr/bin/apt-get update'  
#}

}