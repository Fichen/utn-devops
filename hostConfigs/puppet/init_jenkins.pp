class jenkins {

	$jenkins_pwd = 'utndevops'
	$jenkins_usr = 'admin'

    # get key
    exec { 'install_jenkins_key':
        command => '/usr/bin/wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add - ',
    } 

	# source file
    file { '/etc/apt/sources.list.d/jenkins.list':
        content => "deb https://pkg.jenkins.io/debian-stable binary/\n",
		ensure => present,
        mode    => '0644',
        owner   => root,
        group   => root,
        require => Exec['install_jenkins_key'],
    } -> #ordeno la secuencia de pasos en el tiempo mediante el operador "->".
		 # se utiliza para encadenar semanticamente distintas declaraciones	
    # update
    exec { 'apt-get update':
        command => '/usr/bin/apt-get update',
        #require => File['/etc/apt/sources.list.d/jenkins.list'],
    } ->
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
	}
	
	# Notifico al gestor de servicios que un archivo cambio
	exec { 'reload-systemctl':
        command => '/bin/systemctl daemon-reload',
    } 
	
    # aseguro que el servicio de jenkins este activo
    service { 'jenkins':
        ensure  => running,
	    enable  => "true",
		require => Exec['reload-systemctl']
    }
	
	user { 'jenkins':
	    ensure	=> present,
	    password => '$1$hrl1RNSP$DoKnhDdeCLlW.QJGLY8dj1' #utndevops
	}
	
	# Instalo los plugins necesarios de Jenkins para ejecutar Integración Continua con PHP
	#Además esta como ejemplo la utilización de variables en Puppet: ${jenkins_pwd}
	exec { "install_jenkins_cli_and_plugins":
		cwd         => "/tmp",
		command     => "wget http://127.0.0.1:8082/jnlpJars/jenkins-cli.jar && java -jar jenkins-cli.jar -s http://127.0.0.1:8082 install-plugin checkstyle cloverphp crap4j dry htmlpublisher jdepend plot pmd violations warnings xunit git greenballs --username ${jenkins_usr} --password ${jenkins_pwd} && rm -f /tmp/jenkins-cli.jar",
		path    => ['/usr/bin', '/usr/sbin','/bin' ],
	}
	
	# Instalación de PHP en el equipo que tendrá Jenkins, en este caso de ejemplo es el misma máquina virtual
	# que contiene toda la práctica.
	#Archivo que contiene un repositorio para la instalación de paquetes de PHP		 +    # update
	$enhancers = [ 'php7.0', 'php7.0-xdebug', 'php7.0-xsl', 'php7.0-dom', 'php7.0-zip', 'php7.0-mbstring','phpunit', 'php-codesniffer', 'phploc','pdepend','phpmd','phpcpd','phpdox']
	file { '/etc/apt/sources.list.d/ondrej-ubuntu-php-xenial.list':
        content => "deb http://ppa.launchpad.net/ondrej/php/ubuntu xenial main\n",
        mode    => '0644',
        owner   => root,
        group   => root,
	} ->
	exec { "update_sources_apt_php": 
		path	=> ['/usr/bin', '/usr/sbin','/bin' ],
		command => '/usr/bin/apt-get update',
	} ->
	package { $enhancers: 
		ensure => installed,
	    install_options => ['--allow-unauthenticated', '-f'],
	}

	#Instalación del aprovisionamiento de paquetes composer de PHP
	exec { "install_php_composer":
		cwd         => "/tmp",
		environment => ["HOME=/var/lib/jenkins"],
		command     => "curl -sS https://getcomposer.org/installer | php && sudo mv /tmp/composer.phar /usr/local/bin/composer",
		path    => ['/usr/bin', '/usr/sbin', '/bin'],
	}		
}
