node default {}

node 'ci-server.utn-devops.localhost' {
    case $::operatingsystem {
        'Debian', 'Ubuntu' : {
            include jenkins
            #include jenkins::packages_dependencies
            include jenkins::ssh_keys

             $app = {
                name => 'ci-server-devops-utn',
                env => 'develop',
                key => 'base64:DGFz2h4n4IqTeSE783XpyLtbrM9s2tNpdL8ftjxClQ4=',
                debug => 'true',
                log_level => 'debug',
                url => 'http://ci-server.utn-devops.localhost:8081',
                db_database => 'ci-server_devops_app',
                db_username => 'root',
                db_password => 'root',
                workdir => '/var/www/utn-devops-app',
                domain => 'ci-server.utn-develop.localhost',
            }
            class {'app_config':
                app => $app
            }

            #include docker_install
        }
        default  : { notify {"$::operatingsystem no esta soportado":} }
    }
}
