class jenkins::packages_dependencies inherits jenkins {

    $enhancers = ['php7.3', 'php7.3-xdebug', 'php7.3-xsl', 'php7.3-dom', 'php7.3-zip', 'php7.3-mbstring','phpunit', 'php-codesniffer', 'phploc','pdepend','phpmd','phpcpd','phpdox','ant','php7.2-xml','php7.3-xml']
    file { '/etc/apt/sources.list.d/ondrej-ubuntu-php-bionic.list':
        content => "deb http://ppa.launchpad.net/ondrej/php/ubuntu bionic main\n",
        mode    => '0644',
        owner   => root,
        group   => root,
        ensure  => present,
    }

    exec { "add_key_php_repository":
        path    => ['/usr/bin', '/usr/sbin','/bin' ],
        command => '/usr/bin/apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E5267A6C',
        require => File['/etc/apt/sources.list.d/ondrej-ubuntu-php-bionic.list'],
    }

    package { $enhancers:
        ensure => installed,
        install_options => ['--allow-unauthenticated', '-f'],
        require => Exec['apt-get-update'],
    }

    exec { "install_php_composer":
        cwd         => "/tmp",
        environment => ["HOME=/var/lib/jenkins"],
        command     => "curl -sS https://getcomposer.org/installer | php && sudo mv /tmp/composer.phar /usr/local/bin/composer",
        path    => ['/usr/bin', '/usr/sbin', '/bin'],
    }
}