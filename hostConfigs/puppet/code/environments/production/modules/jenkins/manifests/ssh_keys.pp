class jenkins::ssh_keys {

    file { 'jenkins-create-ssh-folder':
        ensure => directory,
        path => "${jenkins::user_home}/.ssh",
        owner => 'jenkins',
        group => 'jenkins',
        mode => '0700',
    }

    file { 'ssh-user-jenkins-private_key':
        ensure => present,
        path => "${jenkins::user_home}/.ssh/id_rsa",
        owner => 'jenkins',
        group => 'jenkins',
        mode => '0600',
        source =>  'puppet:///modules/jenkins/jenkins_id_rsa',
        require => File['jenkins-create-ssh-folder'],
    }

    file { 'ssh-user-jenkins-public_key':
        ensure => present,
        path => "${jenkins::user_home}/.ssh/id_rsa.pub",
        owner => 'jenkins',
        group => 'jenkins',
        mode => '0600',
        source => 'puppet:///modules/jenkins/jenkins_id_rsa.pub',
        require => File['jenkins-create-ssh-folder'],
    }
}