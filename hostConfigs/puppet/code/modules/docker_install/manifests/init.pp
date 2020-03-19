class docker_install {

  exec { 'apt-update':
    command => '/usr/bin/apt-get update'
  }

  file { 'docker-repository':
    path => '/etc/apt/sources.list.d/docker.list',
    content => 'deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable/\n',
    ensure => present,
    mode    => '0644',
    owner   => root,
    group   => root
  }

  exec { 'repository-key':
    command => '/usr/bin/curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -',
    require => File['docker-repository']
  }

  $packages = ['apt-transport-https', 'ca-certificates', 'curl', 'software-properties-common','docker', 'docker-compose']

  package { $packages:
    require => Exec['repository-key','apt-update'],
    ensure => installed
  }

  service { 'docker':
    ensure => running
  }

}