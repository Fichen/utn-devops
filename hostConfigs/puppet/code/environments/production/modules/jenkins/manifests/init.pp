class jenkins {

    # source file
    file { '/etc/apt/sources.list.d/jenkins.list':
        content => "deb https://pkg.jenkins.io/debian-stable binary/\n",
        ensure => present,
        mode    => '0644',
        owner   => root,
        group   => root,
    } ->
    # get key
    exec { 'install_jenkins_key':
        command => '/usr/bin/wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo /usr/bin/apt-key add -',
    }

    # update
    exec { 'apt-get update':
        command => '/usr/bin/apt-get update',
        require => File['/etc/apt/sources.list.d/jenkins.list'],
    }

    # jenkins package
    package { 'jenkins':
        ensure  => installed,
        require => [
            File['/etc/apt/sources.list.d/jenkins.list'],
            Exec['apt-get update']
        ]
    } -> #Reemplazo el puerto de jenkins para que este escuchando en el 8082
    exec { 'replace_jenkins_port':
        command => "/bin/sed -i -- 's/HTTP_PORT=8080/HTTP_PORT=8082/g' /etc/default/jenkins",
        notify => Service['jenkins'],
    } -> #Agrego privilegios al usuario jenkins
    exec { 'add_to_sudo':
        command => "/bin/echo 'jenkins ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers",
        notify => Service['jenkins'],
    }


    # Notifico al gestor de servicios que un archivo cambio
    exec { 'reload-systemctl':
        command => '/bin/systemctl daemon-reload',
    }

    # aseguro que el servicio de jenkins este activo
    service { 'jenkins':
        ensure  => running,
        enable  => true,
    }

    user { 'jenkins':
        ensure  => present,
        password => '$6$D1DhaT8j$MtKymPElAd8F7zFT/iWV2Z47HVSFtPqRR/VhCi85//aOQDrLv2SILkf/9Tx/VTdaCtkShoBtg24nWv2vepwld0' #utndevops
    }

    file { 'jenkins-admin-user':
        path => '/var/lib/jenkins/users'
        ensure => present,
        source => 'puppet:///jenkins/users',
    }

    # Instalación de PHP en el equipo que tendrá Jenkins, en este caso de ejemplo es el misma máquina virtual
    # que contiene toda la práctica. Los paquetes de PHP se encuentran listados en la variable $enhancers.
    # Generación de un archivo que contiene un repositorio para la instalación de paquetes de PHP # update
    $enhancers = [ 'php7.3', 'php7.3-xdebug', 'php7.3-xsl', 'php7.3-dom', 'php7.3-zip', 'php7.3-mbstring','phpunit', 'php-codesniffer', 'phploc','pdepend','phpmd','phpcpd','phpdox','ant','php7.2-xml','php7.3-xml']
    file { '/etc/apt/sources.list.d/ondrej-ubuntu-php-bionic.list':
        content => "deb http://ppa.launchpad.net/ondrej/php/ubuntu bionic main\n",
        mode    => '0644',
        owner   => root,
        group   => root,
    } ->
    exec { "add_key_php_repository":
        path    => ['/usr/bin', '/usr/sbin','/bin' ],
        command => '/usr/bin/apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E5267A6C'
    } ->
    exec { "update_sources_apt_php":
        path    => ['/usr/bin', '/usr/sbin','/bin' ],
        command => '/usr/bin/apt-get update',
    } -> # Instalación de paquetes PHP
    package { $enhancers:
        ensure => installed,
        install_options => ['--allow-unauthenticated', '-f'],
    }
    #Instalación del aprovisionamiento de paquetes composer de PHP. Ejemplo de una instalación específica
    exec { "install_php_composer":
        cwd         => "/tmp",
        environment => ["HOME=/var/lib/jenkins"],
        command     => "curl -sS https://getcomposer.org/installer | php && sudo mv /tmp/composer.phar /usr/local/bin/composer",
        path    => ['/usr/bin', '/usr/sbin', '/bin'],
    }
}