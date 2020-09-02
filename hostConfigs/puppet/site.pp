# Configuración específica para los nodos por defectos. En este caso no es ninguna
node default {}

# Configuración para un nodo específico. En este caso el nuestro que tiene como nombre
# de host 'utn-devops'. En este caso el nombre de host esta dado por el archivo que se
# encuentra en "utn-devops/hostConfigs/etc_hosts.txt". En una configuración más orientada
# a la realidad, y no para un ejemplo como es este caso, se utilizan servidores de nombre
# de dominio (DNS)
node 'utn-devops.localhost' {

    #incluyo el modulo sudo
    class { 'sudo': }

    #Genero entradas en sudo para el grupo admins y usuarios vagrant y jenkins
    sudo::conf { 'admins':
        ensure  => present,
        content => '%admin ALL=(ALL) ALL',
    }
    sudo::conf { 'vagrant':
        ensure  => present,
        content => 'vagrant ALL=(ALL) NOPASSWD: ALL',
    }
    sudo::conf { 'jenkins':
        content  => "jenkins ALL=(ALL) NOPASSWD: ALL",
    }

    # Instalación de Jenkins. Solo lo instalo si el nodo cliente contiene los
    # sistemas operativos Debian o Ubuntu.
    # La variable $::operatingsystem se obtiene de los "facts" que envían los agentes y representa el
    # el sistema operativo del nodo.
    case $::operatingsystem {
        'Debian', 'Ubuntu' : { 
            include jenkins 
            include jenkins::dependencies
        }
        default  : { notify {"$::operatingsystem no esta soportado":} }
    }

}
