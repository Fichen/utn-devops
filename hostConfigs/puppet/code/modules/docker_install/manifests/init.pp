class docker_install($variables) {
  $composeVersion = $variables['compose_version']

  $packages = ['apt-transport-https', 'ca-certificates', 'curl', 'software-properties-common', 'docker-ce']

  file { 'docker-repository':
    path => '/etc/apt/sources.list.d/docker.list',
    content => 'deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable',
    ensure => present,
    mode    => '0644',
    owner   => root,
    group   => root
  }

  exec { 'repository-key':
    command => '/usr/bin/curl -fsSL https://download.docker.com/linux/ubuntu/gpg | /usr/bin/sudo apt-key add -',
    require => File['docker-repository'],
    unless => '/usr/bin/test ! -x $(command -v docker)',
  }

  exec { 'apt-update':
    command => '/usr/bin/apt-get update',
    require => [
      Exec['repository-key'],
      File['docker-repository']
    ],
  } ->
  exec {'apt-policy':
    command => '/usr/bin/apt-cache policy docker-ce'
  }

  package { $packages:
    ensure => installed,
    require => Exec['apt-update'],
  }

  exec { 'install-docker-compose':
    command => "/usr/bin/sudo curl -L \"https://github.com/docker/compose/releases/download/${composeVersion}/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose",
    onlyif => '/usr/bin/test ! -x /usr/local/bin/docker-compose',
  } ->
  exec { 'permission-docker-compose':
    command => 'sudo chmod +x /usr/local/bin/docker-compose',
    path => ['/usr/bin'],
  }

  #conflict with docker login credentials
  package { 'golang-docker-credential-helpers':
    ensure => absent
  }

  service { 'docker':
    ensure => running,
    enable => true,
  }

}