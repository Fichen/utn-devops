class jenkins {
    # get key
    exec { 'install_jenkins_key':
        command => '/usr/bin/wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add - ',
    }

    # update
    exec { 'apt-get update':
        command => '/usr/bin/apt-get update',
        require => File['/etc/apt/sources.list.d/jenkins.list'],
    }

    # source file
    file { '/etc/apt/sources.list.d/jenkins.list':
        content => "deb https://pkg.jenkins.io/debian-stable binary/\n",
        mode    => '0644',
        owner   => root,
        group   => root,
        require => Exec['install_jenkins_key'],
    }

    # jenkins package
    package { 'jenkins':
        ensure  => present,
        require => Exec['apt-get update'],
    }

    # jenkins service
    service { 'jenkins':
        ensure  => running,
        require => Package['jenkins'],
    }
}
