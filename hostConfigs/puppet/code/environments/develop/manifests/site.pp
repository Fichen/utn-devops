node default {}

node 'develop.utn-devops.localhost' {
    $app = {
        name => 'develop-devops-utn',
        env => 'develop',
        key => 'base64:DGFz2h4n4IqTeSE783XpyLtbrM9s2tNpdL8ftjxClQ4=',
        debug => 'true',
        log_level => 'debug',
        url => 'http://develop.utn-devops.localhost:8081',
        db_database => 'develop_devops_app',
        db_username => 'root',
        db_password => 'root',
        workdir => '/var/www/utn-devops-app',
        domain => 'develop.utn-develop.localhost',
    }
    class {'app_config':
        app => $app
    }

    include docker_install
}
