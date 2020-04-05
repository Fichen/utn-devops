node default {}

node 'test.utn-devops.localhost' {
    include docker_install
    $app = {
        name => 'test-devops-utn',
        env => 'test',
        key => 'base64:DGFz2h4n4IqTeSE783XpyLtbrM9s2tNpdL8ftjxClQ4=',
        debug => 'false',
        log_level => 'debug',
        url => 'http://test.utn-devops.localhost:8081',
        db_database => 'test_devops_app',
        db_username => 'root',
        db_password => 'rootabcd',
        workdir => '/var/www/utn-devops-app',
        domain => 'test.utn-develop.localhost',
    }
    class {'app_config':
        app => $app
    }
}
