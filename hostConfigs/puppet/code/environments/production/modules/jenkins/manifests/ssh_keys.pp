class jenkins::ssh_keys {
    file { 'ssh-private_key':
        path => '/home/vagrant/.ssh/id_rsa',
        ensure => present,
        source => 'puppet:///modules/jenkins/private_key',
    }
}