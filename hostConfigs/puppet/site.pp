# Configuración específica para los nodos por defectos. En este caso no es ninguna
node default { }

# Configuración para un nodo específico. En este caso el nuestro que tiene como nombre
# de host 'utn-devops'. En este caso el nombre de host esta dado por el archivo que se
# encuentra en "utn-devops/hostConfigs/etc_hosts.txt". En una configuración más orientada
# a la realidad, y no para un ejemplo como es este caso, se utilizan servidores de nombre
# de dominio (DNS)
node 'utn-devops.localhost' {

# Incluyo lo definido en la clase docker_install correspondiente al archivo
# utn-devops/hostConfigs/puppet/init.pp
#include 'docker_install'
include 'jenkins'

# Instalación de Jenkins. Solo lo instalo si el nodo cliente contiene los
# sistemas operativos Debian o Ubuntu
case $::operatingsystem {
        'Debian', 'Ubuntu' : { include jenkins }
        default  : { notify {"$::operatingsystem no esta soportado":} }
    }

}
