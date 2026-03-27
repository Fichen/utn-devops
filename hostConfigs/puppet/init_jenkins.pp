#
class jenkins {

    # get key
    exec { 'install_jenkins_key':
        command => '/usr/bin/sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key',
    }

    -> exec {'add-repository-key':
        command => 'echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null',
        path => ['/usr/bin/'],
    }
    -> exec { 'apt-get update':
        command => '/usr/bin/apt-get update -y',
    }

    #install jenkins
    $enhancers = [ 'fontconfig', 'openjdk-21-jre', 'jenkins' ]

    package { $enhancers:
        ensure => 'installed',
    } #Reemplazo el puerto de jenkins para que este escuchando en el 8082
    -> exec { 'replace_jenkins_port':
        command => "/bin/sed -i -- 's/JENKINS_PORT=8080/JENKINS_PORT=8082/g' /lib/systemd/system/jenkins.service",
    } -> exec { 'reload-systemctl':
        command => '/bin/systemctl daemon-reload',
        notify  => Service['jenkins'],
    }

    # aseguro que el servicio de jenkins este activo
    service { 'jenkins':
        ensure  => running,
    }
}
