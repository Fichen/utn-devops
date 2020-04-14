class docker_install {

  exec { 'apt-update':
    command => '/usr/bin/apt-get update',
    unless => '/usr/bin/test -x $(command -v docker)',
  }

  file { 'docker-repository':
    path => '/etc/apt/sources.list.d/docker.list',
    content => 'deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable',
    ensure => present,
    mode    => '0644',
    owner   => root,
    group   => root
  }

  $packages = ['apt-transport-https', 'ca-certificates', 'curl', 'software-properties-common', 'docker-ce']

  exec { 'repository-key':
    command => '/usr/bin/curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -',
    require => File['docker-repository'],
    unless => '/usr/bin/test -x $(command -v docker)',
  }

  package { $packages:
    require => Exec['repository-key','apt-update'],
    ensure => installed,
  }

$composeVersion ="1.25.4"
  exec { 'install-docker-compose':
    command => "/usr/bin/sudo curl -L \"https://github.com/docker/compose/releases/download/${composeVersion}/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose",
    onlyif => '/usr/bin/test ! -x $(command -v docker-compose)',
  } ->
  exec { 'permission-docker-compose':
    command => 'sudo chmod +x /usr/local/bin/docker-compose',
    path => ['/usr/bin'],
    onlyif => 'test -f /usr/local/bin/docker-compose',
  }

  #conflict with docker login credentials
  package { 'golang-docker-credential-helpers':
    ensure => absent
  }

  service { 'docker':
    ensure => running,
    enable  => true,
  }

}