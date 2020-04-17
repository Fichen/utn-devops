class docker_install::registry {

    file { 'docker-registry-host-certificate-crt':
        path => '/usr/local/share/ca-certificates/domain.crt',
        source => 'puppet:///modules/docker_install/certs/domain.crt',
        ensure => present,
    }

    file { 'docker-registry-host-certificate-csr':
        path => '/usr/local/share/ca-certificates/domain.csr',
        source => 'puppet:///modules/docker_install/certs/domain.csr',
        ensure => present,
    }

    file { 'docker-registry-host-certificate-key':
        path => '/usr/local/share/ca-certificates/domain.key',
        source => 'puppet:///modules/docker_install/certs/domain.key',
        ensure => present,
    }

    file { 'docker-registry-host-certificate-key.org':
        path => '/usr/local/share/ca-certificates/domain.key.org',
        source => 'puppet:///modules/docker_install/certs/domain.key.org',
        ensure => present,
    }

    exec { 'docker-update-ca-certificates':
        command => '/usr/sbin/update-ca-certificates',
        require => File['/usr/local/share/ca-certificates/domain.crt'],
        onlyif => '/usr/bin/test ! -n "$(ls -l /etc/ssl/certs/|grep domain.pem)"',
        notify => Exec['docker-restart'],
    }

    exec { 'docker-restart':
        command => '/bin/systemctl restart docker',
        unless => '/usr/bin/test -L "/etc/ssl/certs/domain.pem"',
    }
}