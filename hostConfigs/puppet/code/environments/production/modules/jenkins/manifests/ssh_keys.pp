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

    # Add fingerprints of develop and test environments to known host. It's necessary to deploy
    exec { 'known-host-ssh-to-pipeline-environments':
        command => 'sudo su jenkins -c "ssh-keyscan -H develop test > ~/.ssh/known_hosts"',
        path    => ['/usr/bin', '/usr/local/bin'],
        require => File['jenkins-create-ssh-folder'],
    }
}