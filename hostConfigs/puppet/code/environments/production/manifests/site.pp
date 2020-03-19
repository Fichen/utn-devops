node default {}

node 'ci-server.utn-devops.localhost' {
    case $::operatingsystem {
        'Debian', 'Ubuntu' : {
            include docker_install
            include jenkins
        }
        default  : { notify {"$::operatingsystem no esta soportado":} }
    }
}
