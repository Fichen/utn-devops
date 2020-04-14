node default {}

node 'ci-server.utn-devops.int' {
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
                url => 'http://ci-server.utn-devops.int:8081',
                db_database => 'ci-server_devops_app',
                db_username => 'root',
                db_password => 'root',
                workdir => '/var/www/utn-devops-app',
                domain => 'utn-develop.int',
                user => 'service-app-user-01',
                group => 'service-app-user-01',
                hostname => 'ci-server',
            }
            class {'app_config':
                app => $app
            }

            include docker_install
            #class { 'docker_install::registry': }
        }
        default  : { notify {"$::operatingsystem no esta soportado":} }
    }
}
