class app_config {

    $directoryTree = ['/var/www', '/var/www/utn-devops-app']
    file { $directoryTree:
        ensure => directory,
    }

    file { 'app-environment' :
        path => '/var/www/utn-devops-app/.env',
        ensure  => present,
        source => 'puppet:///modules/app_config/env',
    }

    user { 'service-app-user-01':
        ensure => present,
        home => '/var/www/utn-devops-app',
        password  => '$6$D1DhaT8j$MtKymPElAd8F7zFT/iWV2Z47HVSFtPqRR/VhCi85//aOQDrLv2SILkf/9Tx/VTdaCtkShoBtg24nWv2vepwld0', #utndevops
    }
}
