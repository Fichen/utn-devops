class app_config($app, $environment_var_dir) {

    $directoryTree = ['/var/www', '/var/www/utn-devops-app']
    file { $directoryTree:
        ensure => directory,
    }

    file { 'app-environment' :
        path => "${environment_var_dir}/.env",
        ensure  => present,
        content => epp('app_config/env.epp', $app),
        require => File['/var/www/utn-devops-app'],
    }

    exec { 'backup-authorized_keys':
        path    => ['/usr/bin', '/usr/sbin','/bin' ],
        command => '/bin/cp /home/vagrant/.ssh/authorized_keys /home/vagrant/.ssh/authorized_keys.bk',
        onlyif => 'test ! -f /home/vagrant/.ssh/authorized_keys.bk'
    }->
    file {'ssh-keys':
        path => '/home/vagrant/.ssh/authorized_keys',
        ensure => present,
        content => epp('app_config/authorized_keys.epp'),
    } ->
    exec { 'recover-original-ssh-key':
        path    => ['/usr/bin', '/usr/sbin','/bin' ],
        command => '/bin/cat /home/vagrant/.ssh/authorized_keys.bk >> /home/vagrant/.ssh/authorized_keys',
        onlyif => 'test -f /home/vagrant/.ssh/authorized_keys.bk'
    }

    user { 'service-app-user-01':
        ensure => present,
        home => '/var/www/utn-devops-app',
        shell =>'/bin/bash',
        password  => '$6$D1DhaT8j$MtKymPElAd8F7zFT/iWV2Z47HVSFtPqRR/VhCi85//aOQDrLv2SILkf/9Tx/VTdaCtkShoBtg24nWv2vepwld0',
    }
}
