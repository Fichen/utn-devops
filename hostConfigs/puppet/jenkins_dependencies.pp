# Instalación de PHP en el equipo que tendrá Jenkins, en este caso de ejemplo es el misma máquina virtual
# que contiene toda la práctica. 
class jenkins::dependencies {

    file { '/etc/sudoers.d/jenkins':
        ensure  => present,
        content => "jenkins ALL=(ALL) NOPASSWD: ALL",
        mode    => '0644',
        owner   => root,
        group   => root,
    } -> exec { 'restart': 
        command => '/bin/systemctl restart jenkins',
        path    => '/usr/bin:/usr/sbin:/bin',
    }

    #listado de dependencias
    $enhancers = [
        'libmcrypt-dev',
        'mariadb-client',
        'libmagickwand-dev',
        'zip',
        'zlib1g-dev',
        'libzip-dev',
        'libonig-dev',
        'php7.4',
        'php7.4-xdebug',
        'php7.4-xsl',
        'php7.4-dom',
        'php7.4-zip',
        'php7.4-mbstring',
        'phpunit',
        'php-codesniffer',
        'phploc',
        'pdepend',
        'phpmd',
        'phpcpd',
        'phpdox',
        'ant',
        'php7.4-xml',
        ]

    # Generación de un archivo que contiene un repositorio para la instalación de paquetes de PHP # update
    file { '/etc/apt/sources.list.d/ondrej-ubuntu-php-jammy.list':
        content => "deb http://ppa.launchpad.net/ondrej/php/ubuntu jammy main\n",
        mode    => '0644',
        owner   => root,
        group   => root,
        require => Exec['add_key_php_repository'],
    }

    exec {'add_key_php_repository':
        path    => ['/usr/bin', '/usr/sbin','/bin' ],
        command => '/usr/bin/apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E5267A6C'
    }

    exec { 'update_sources_apt_php':
        command => '/usr/bin/apt-get update -y',
    }
    # Instalación de paquetes PHP
    package { $enhancers:
        ensure          => installed,
        install_options => ['--allow-unauthenticated', '-f'],
        require         => Exec['update_sources_apt_php'],
    }

    #Instalación del aprovisionamiento de paquetes composer de PHP. Ejemplo de una instalación específica
    exec { 'install_php_composer':
        cwd         => '/tmp',
        environment => ['HOME=/var/lib/jenkins'],
        command     => 'curl -sS https://getcomposer.org/installer | php && sudo mv /tmp/composer.phar /usr/local/bin/composer',
        path        => ['/usr/bin', '/usr/sbin', '/bin'],
        onlyif      => '/usr/bin/test -x "$(which php)"',
    }
}
