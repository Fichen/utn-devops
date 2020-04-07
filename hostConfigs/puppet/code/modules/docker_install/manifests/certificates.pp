class docker_install::certificates($variables) {

    file { 'docker-host-user-config':
        path => "${variables['workdir']}/.docker/config.json",
        mode => '0600',
        owner => $variables['user'],
        group => $variables['group'],
        source => 'puppet:///modules/docker_install/config.json',
        ensure => present,
    }

    file { 'docker-registry-host-certificate-crt':
        path => '/usr/local/share/ca-certificates/domain.crt',
        source => 'puppet:///modules/docker_install/certs/domain.crt',
        ensure => present,
    }

    exec { 'docker-update-ca-certificates':
        command => '/usr/sbin/update-ca-certificates',
        require => File['docker-registry-host-certificate-crt'],
        notify => Exec['docker-restart'],
    }

    exec { 'docker-restart':
        command => '/bin/systemctl restart docker'
    }

}