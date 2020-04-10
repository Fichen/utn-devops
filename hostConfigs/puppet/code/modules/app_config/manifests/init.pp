class app_config($app) {

    $environment_var_dir = $app['workdir']

    file { '/var/www':
        ensure => directory,
    }

    file { $environment_var_dir:
        owner => 'service-app-user-01',
        group => 'service-app-user-01',
        mode => '0755',
        ensure => directory,
    }

    file { "${environment_var_dir}/.ssh":
        owner => 'service-app-user-01',
        group => 'service-app-user-01',
        mode => '0700',
        ensure => directory,
    }

    file { "${environment_var_dir}/.docker":
        owner => 'service-app-user-01',
        group => 'service-app-user-01',
        mode => '0700',
        ensure => directory,
    }

    file {'ssh-keys-service-user':
        path => "${environment_var_dir}/.ssh/authorized_keys",
        ensure => present,
        owner => 'service-app-user-01',
        group => 'service-app-user-01',
        mode => '0600',
        content => epp('app_config/authorized_keys.epp'),
    }

    file { 'app-environment' :
        path => "${environment_var_dir}/.env",
        ensure  => present,
        content => epp('app_config/env.epp', $app),
        require => File[$environment_var_dir],
    }

    file {'app-build-script':
        path => "${environment_var_dir}/build_app.sh",
        ensure => present,
        source => 'puppet:///modules/app_config/build_app.sh',
        mode => '0755',
        owner => 'service-app-user-01',
        group => 'service-app-user-01',
        require => File[$environment_var_dir],
    }

    user { 'service-app-user-01':
        ensure => present,
        home => $environment_var_dir,
        shell =>'/bin/bash',
        password  => '$6$D1DhaT8j$MtKymPElAd8F7zFT/iWV2Z47HVSFtPqRR/VhCi85//aOQDrLv2SILkf/9Tx/VTdaCtkShoBtg24nWv2vepwld0',
    }

    exec { 'add_user_to_sudo':
        command => "/bin/echo 'service-app-user-01 ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers",
        unless => '/usr/bin/test  -n "$(grep service-app-user-01 /etc/sudoers)"'
    }
}
