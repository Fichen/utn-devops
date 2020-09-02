class jenkins::dependencies {

    # Instalación de PHP en el equipo que tendrá Jenkins, en este caso de ejemplo es el misma máquina virtual
    # que contiene toda la práctica. Los paquetes de PHP se encuentran listados en la variable $enhancers.
    # Generación de un archivo que contiene un repositorio para la instalación de paquetes de PHP # update
    $enhancers = [ 'php7.3', 'php7.3-xdebug', 'php7.3-xsl', 'php7.3-dom', 'php7.3-zip', 'php7.3-mbstring','phpunit', 'php-codesniffer', 'phploc','pdepend','phpmd','phpcpd','phpdox','ant','php7.2-xml','php7.3-xml']
    file { '/etc/apt/sources.list.d/ondrej-ubuntu-php-bionic.list':
        content => "deb http://ppa.launchpad.net/ondrej/php/ubuntu bionic main\n",
        mode    => '0644',
        owner   => root,
        group   => root,
        require => Exec['add_key_php_repository'],
    }

    exec { "add_key_php_repository":
        path    => ['/usr/bin', '/usr/sbin','/bin' ],
        command => '/usr/bin/apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E5267A6C'
    }

    exec { "update_sources_apt_php":
        command => '/usr/bin/apt-get update -y',
    }
    
    # Instalación de paquetes PHP
    package { $enhancers:
        ensure => installed,
        install_options => ['--allow-unauthenticated', '-f'],
        require => Exec['update_sources_apt_php'],
    }

    #Instalación del aprovisionamiento de paquetes composer de PHP. Ejemplo de una instalación específica
    exec { "install_php_composer":
        cwd         => "/tmp",
        environment => ["HOME=/var/lib/jenkins"],
        command     => "curl -sS https://getcomposer.org/installer | php && sudo mv /tmp/composer.phar /usr/local/bin/composer",
        path    => ['/usr/bin', '/usr/sbin', '/bin'],
        onlyif  => '/usr/bin/test -x "$(which php)"',
    }
}