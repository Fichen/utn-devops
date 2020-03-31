class jenkins {

    file { '/etc/apt/sources.list.d/jenkins.list':
        content => "deb https://pkg.jenkins.io/debian-stable binary/\n",
        ensure => present,
        mode    => '0644',
        owner   => root,
        group   => root,
        require => Exec['install_repository_key'],
    }

    exec { 'install_repository_key':
        command => '/usr/bin/wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo /usr/bin/apt-key add -',
    }

    exec { 'apt-get-update':
        command => '/usr/bin/apt-get update',
        require => File['/etc/apt/sources.list.d/jenkins.list'],
    }

    $packages = ['openjdk-8-jre', 'jenkins']
    package { $packages:
        ensure  => installed,
        require => [
            File['/etc/apt/sources.list.d/jenkins.list'],
            Exec['apt-get-update']
        ]
    }

    user { 'jenkins':
        ensure  => present,
        home => '/var/lib/jenkins',
        shell =>'/bin/bash',
        groups => ['jenkins', 'sudo'],
        membership => minimum,
        password => '$6$D1DhaT8j$MtKymPElAd8F7zFT/iWV2Z47HVSFtPqRR/VhCi85//aOQDrLv2SILkf/9Tx/VTdaCtkShoBtg24nWv2vepwld0'
    } ->
    group { 'jenkins':
        name => 'jenkins',
        ensure => present,
    } ->
    exec { 'replace_default_jenkins_port':
        command => "/bin/sed -i -- 's/HTTP_PORT=8080/HTTP_PORT=8082/g' /etc/default/jenkins",
    } ->
    exec { 'add_to_sudo':
        command => "/bin/echo 'jenkins ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers",
        notify => Service['jenkins'],
        unless => '/usr/bin/test  -n "$(grep jenkins /etc/sudoers)"'
    }

    exec { 'reload-systemctl':
        command => '/bin/systemctl daemon-reload',
    }

    service { 'jenkins':
        ensure  => running,
        enable  => true,
        require => Exec['reload-systemctl']
    }
}
