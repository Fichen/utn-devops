class jenkins {

    # get key
    exec { 'install_jenkins_key':
        command => '/usr/bin/wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo apt-key add -',
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
    }

    #install jenkins
    $enhancers = [ 'openjdk-8-jre', 'jenkins' ]
    #$enhancers = [ 'jenkins' ]

    package { $enhancers:
        ensure => 'installed',
    } ->
    #Reemplazo el puerto de jenkins para que este escuchando en el 8082
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
}