node default {}

node 'ci-server.utn-devops.localhost' {
    case $::operatingsystem {
        'Debian', 'Ubuntu' : {
            #include docker_install
            include jenkins
            #include jenkins::packages_dependencies
            #include jenkins::ssh_keys

             $app = {
                name => 'ci-server-devops-utn',
                env => 'develop',
                key => 'base64:DGFz2h4n4IqTeSE783XpyLtbrM9s2tNpdL8ftjxClQ4=',
                debug => 'true',
                log_level => 'debug',
                url => 'http://ci-server.utn-devops.localhost:8081',
                db_database => 'ci-server_devops_app',
                db_username => 'root',
                db_password => 'root'
            }
            #class {'app_config':
            #    app => $app,
            #    environment_var_dir => '/var/www/utn-devops-app'
            #}
        }
        default  : { notify {"$::operatingsystem no esta soportado":} }
    }
}
