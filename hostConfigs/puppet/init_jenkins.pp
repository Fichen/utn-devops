class jenkins {

	$jenkins_pwd = 'utndevops'

    # get key
    exec { 'install_jenkins_key':
        command => '/usr/bin/wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add - ',
    }

    # actualizo los repositorios
    exec { 'apt-get update':
        command => '/usr/bin/apt-get update',
        require => File['/etc/apt/sources.list.d/jenkins.list','/etc/apt/sources.list.d/ondrej-ubuntu-php-xenial.list'],
    }

    # archivo que contiene el repositorio para la instalación de Jenkins
    file { '/etc/apt/sources.list.d/jenkins.list':
        content => "deb https://pkg.jenkins.io/debian-stable binary/\n",
        mode    => '0644',
        owner   => root,
        group   => root,
        require => Exec['install_jenkins_key'],
    }
	
	#Archivo que contiene un repositorio para la instalación de paquetes de PHP
	file { '/etc/apt/sources.list.d/ondrej-ubuntu-php-xenial.list':
        content => "deb http://ppa.launchpad.net/ondrej/php/ubuntu xenial main\n",
        mode    => '0644',
        owner   => root,
        group   => root,
    }

    # Instalación de jenkins 
    package { 'jenkins':
        ensure  => present,
        require => Exec['apt-get update'],
    }
	
	# Configuración por defecto para jenkins. La diferencia en este archivo 
	#solo es el cambio de puerto. Del 8080 al 8082
    file { '/etc/default/jenkins':
	    ensure  => present,
		force  => true,
        mode    => '0644',
        owner   => root,
        group   => root,
        require => Package['jenkins'],
		source => 'puppet:///modules/jenkins/jenkins_default',
    }
	#Archivo para el inicio del servicio de Jenkins. Mismo proposito que el anterior
	file { '/etc/init.d/jenkins':
	    ensure  => present,	
		force  => true,	
        mode    => '0755',
        owner   => root,
        group   => root,
        require => Package['jenkins'],
		source => 'puppet:///modules/jenkins/jenkins_init_d',
    }

    # Aseguro que jenkins siempre se ejecute 
    service { 'jenkins':
        ensure  => running,
        require => Package['jenkins'],
    }
	
	# Cambio la clave del usuario de sistema mediante el valor encriptado
	user { 'jenkins':
	    ensure	=> present,
	    password => '$1$hrl1RNSP$DoKnhDdeCLlW.QJGLY8dj1' #utndevops
	}
	
	# Instalo los plugins necesarios de Jenkins para ejecutar Integración Continua con PHP
	#Además esta como ejemplo la utilización de variables en Puppet: ${jenkins_pwd}
	exec { "install_jenkins_cli_and_plugins":
		cwd         => "/tmp",
		command     => "wget http://127.0.0.1:8082/jnlpJars/jenkins-cli.jar && java -jar jenkins-cli.jar -s http://127.0.0.1:8082 install-plugin checkstyle cloverphp crap4j dry htmlpublisher jdepend plot pmd violations warnings xunit git greenballs --username jenkins --password ${jenkins_pwd} && rm -f /tmp/jenkins-cli.jar",
		path    => ['/usr/bin', '/usr/sbin','/bin' ],
	}
	
	# Instalación de PHP en el equipo que tendrá Jenkins, en este caso de ejemplo es el misma máquina virtual
	# que contiene toda la práctica.
	$enhancers = [ 'php7.0', 'php7.0-xdebug', 'php7.0-xsl', 'php7.0-dom', 'php7.0-zip', 'php7.0-mbstring','phpunit', 'php_codesniffer', 'phploc','pdepend','phpmd','phpcpd','php-codebrowse','phpdox']
	package { $enhancers: ensure => 'installed' }

	#Instalación del aprovisionamiento de paquetes composer de PHP
	exec { "install_php_composer":
		cwd         => "/tmp",
		command     => "php -r \"copy('https://getcomposer.org/installer', 'composer-setup.php');\" && sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer && rm -f /tmp/composer-setup.php && sudo chown -R jenkins:jenkins /var/lib/jenkins/.composer",
		path    => ['/usr/bin', '/usr/sbin', '/bin'],
	}	
}
