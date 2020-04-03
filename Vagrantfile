# -*- mode: ruby -*-
# vi: set ft=ruby :

BOX = "ubuntu/bionic64"
MASTER_PUPPET_IP = "10.0.0.10"
DEVELOP_IP = "10.0.0.11"
TEST_IP = "10.0.0.12"
CI_IP = "10.0.0.13"

Vagrant.configure("2") do |config|

  config.vm.define "puppet-master" do |subconfig|
    subconfig.vm.box = BOX

    # Ports and ip addresses
    subconfig.vm.network "forwarded_port", guest: 8140, host: 8140, guest_ip: MASTER_PUPPET_IP, auto_correct: true
    subconfig.vm.network :private_network, ip: MASTER_PUPPET_IP

    # VM settings
    subconfig.vm.hostname = "puppet-master"
    subconfig.vm.provider "virtualbox" do |v|
    v.name = "puppet-master.utn-devops.localhost"
    v.memory = "512"
    end

    #shared folder
    subconfig.vm.synced_folder "./hostConfigs/puppet/code", "/etc/puppet/code"

    #ToDo make it a puppet resource
    subconfig.vm.provision "file", source: "hostConfigs/etc_hosts.txt", destination: "/tmp/hosts"
    subconfig.vm.provision "file", source: "hostConfigs/puppet/puppet-master.conf", destination: "/tmp/puppet-master.conf"

    subconfig.vm.provision :shell, path: "Vagrant.bootstrap.master-puppet.sh"
    #
  end

  #develop
  config.vm.define "develop" do |subconfig|
    subconfig.vm.box = BOX

    # Ports and ip addresses
    subconfig.vm.network :private_network, ip: DEVELOP_IP
    subconfig.vm.network "forwarded_port", guest: 8081, host: 8081, guest_ip: DEVELOP_IP, auto_correct: true
    subconfig.vm.network "forwarded_port", guest: 4400, host: 4400, guest_ip: DEVELOP_IP, auto_correct: true
    subconfig.vm.network "forwarded_port", guest: 8140, host: 8140, guest_ip: DEVELOP_IP, auto_correct: true

    # VM settings
    subconfig.vm.hostname = "develop"
    subconfig.ssh.insert_key = false
    subconfig.vm.provider "virtualbox" do |v|
    v.name = "develop.utn-devops.localhost"
    v.memory = "1024"
    end

    # Files provisioning
    subconfig.vm.provision "file", source: "hostConfigs/puppet/puppet-agent.develop.conf", destination: "/tmp/puppet-agent.conf"
    subconfig.vm.provision "file", source: "hostConfigs/etc_hosts.txt", destination: "/tmp/hosts"
    #
  end

  #test
  config.vm.define "test" do |subconfig|
    subconfig.vm.box = BOX

    #Ports and ip addresses
    subconfig.vm.network "forwarded_port", guest: 8081, host: 8081, guest_ip: TEST_IP, auto_correct: true
    subconfig.vm.network "forwarded_port", guest: 4400, host: 4400, guest_ip: TEST_IP, auto_correct: true
    subconfig.vm.network "forwarded_port", guest: 8140, host: 8140, guest_ip: TEST_IP, auto_correct: true
    subconfig.vm.network :private_network, ip: TEST_IP

    #VM settings
    subconfig.vm.hostname = "test"
    subconfig.ssh.insert_key = false
    subconfig.vm.provider "virtualbox" do |v|
    v.name = "test.utn-devops.localhost"
    v.memory = "1024"
    end

    #File provisioning
    subconfig.vm.provision "file", source: "hostConfigs/puppet/puppet-agent.test.conf", destination: "/tmp/puppet-agent.conf"
    subconfig.vm.provision "file", source: "hostConfigs/etc_hosts.txt", destination: "/tmp/hosts"

    subconfig.vm.provision :shell, path: "Vagrant.bootstrap.develop.sh"
    #
  end

  #ci-server
  config.vm.define "ci-server" do |subconfig|
    subconfig.vm.box = BOX

    #Ports and ip addresses
    subconfig.vm.network "forwarded_port", guest: 8081, host: 8081, guest_ip: CI_IP, auto_correct: true
    subconfig.vm.network "forwarded_port", guest: 8082, host: 8082, guest_ip: CI_IP, auto_correct: true
    subconfig.vm.network "forwarded_port", guest: 4400, host: 4400, guest_ip: CI_IP, auto_correct: true
    subconfig.vm.network "forwarded_port", guest: 8140, host: 8140, guest_ip: CI_IP, auto_correct: true
    subconfig.vm.network :private_network, ip: CI_IP

    #VM Settings
    subconfig.vm.hostname = "ci-server"
    subconfig.ssh.insert_key = false
    subconfig.vm.provider "virtualbox" do |v|
    v.name = "ci-server.utn-devops.localhost"
    v.memory = "1024"
    end

    #File provisioning
    subconfig.vm.provision "file", source: "hostConfigs/puppet/puppet-agent.production.conf", destination: "/tmp/puppet-agent.conf"
    subconfig.vm.provision "file", source: "hostConfigs/etc_hosts.txt", destination: "/tmp/hosts"

    subconfig.vm.provision :shell, path: "Vagrant.bootstrap.ci-server.sh"
    #
  end

end
