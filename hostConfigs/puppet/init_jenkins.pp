#
class jenkins {

    # get key
    exec { 'install_jenkins_key':
        command => '/usr/bin/wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -',
    }

    # source file
    file { '/etc/apt/sources.list.d/jenkins.list':
        ensure  => present,
        content => "deb https://pkg.jenkins.io/debian-stable binary/\n",
        mode    => '0644',
        owner   => root,
        group   => root,
        require => Exec['install_jenkins_key'],
    }

    # update
    exec { 'apt-get update':
        command => '/usr/bin/apt-get update',
    }

    #install jenkins
    $enhancers = [ 'openjdk-8-jre', 'jenkins' ]

    # jenkins package
    package { $enhancers:
        ensure  => installed,
        require => [
            File['/etc/apt/sources.list.d/jenkins.list'],
            Exec['apt-get update']
        ]
    } -> exec { 'replace_jenkins_port': #Reemplazo el puerto de jenkins para que este escuchando en el 8082
        command => "/bin/sed -i -- 's/HTTP_PORT=8080/HTTP_PORT=8082/g' /etc/default/jenkins",

    } -> exec { 'reload': # Notifico al gestor de servicios que un archivo cambio
        command => '/bin/systemctl restart jenkins',
        path    => '/usr/bin:/usr/sbin:/bin',
        unless  => 'netstat -pant |grep LISTEN |grep 80182 | awk  \'{print $7}\'',
    }

    service { 'jenkins':
        ensure => running,
        enable => true,
    }

    user { 'jenkins':
        ensure   => present,
        password => '$1$hrl1RNSP$DoKnhDdeCLlW.QJGLY8dj1',
        home     => '/var/lib/jenkins',
        shell    => '/bin/bash',
    }

}
