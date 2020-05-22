# -*- mode: ruby -*-
# vi: set ft=ruby :

BOX       = "ubuntu/bionic64"
IP_MASTER = "10.0.1.10"
IP_AGENT  = "10.0.1.11"

Vagrant.configure("2") do |config|

  config.vm.define "master.demo-puppet.int" do | subconfig |
    subconfig.vm.box = BOX
    subconfig.vm.network "forwarded_port", guest: 8140, guest_ip: IP_MASTER, host: 8140, auto_correct: true
    subconfig.vm.network :private_network, ip: IP_MASTER

    subconfig.vm.hostname = "master.demo-puppet.int"
    subconfig.vm.provider "virtualbox" do |v|
      v.name = "master.demo-puppet.int"
      v.memory = "512"
      # symlinks error mitigation
      v.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
    end

    subconfig.vm.synced_folder "./puppet/code", "/etc/puppet/code"

    subconfig.vm.provision "file", source: "hostConfigs/ufw", destination: "/tmp/utw"
    subconfig.vm.provision "file", source: "hostConfigs/puppet-master.conf", destination: "/tmp/puppet.conf"
    subconfig.vm.provision :shell, path: "Vagrant.bootstrap.master.sh", run: "always"
    #
  end

  config.vm.define "agent.demo-puppet.int" do | subconfig |
    subconfig.vm.box = BOX

    subconfig.vm.network "forwarded_port", guest: 80, guest_ip: IP_AGENT, host: 8080, auto_correct: true
    subconfig.vm.network "forwarded_port", guest: 8140, guest_ip: IP_AGENT, host: 8140, auto_correct: true
    subconfig.vm.network :private_network, ip: IP_AGENT

    subconfig.vm.hostname = "agent.demo-puppet.int"
    subconfig.vm.provider "virtualbox" do |v|
      v.name = "agent.demo-puppet.int"
      v.memory = "1024"
      # symlinks error mitigation
      v.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
    end

    subconfig.vm.provision "file", source: "hostConfigs/ufw", destination: "/tmp/utw"
    subconfig.vm.provision "file", source: "hostConfigs/puppet-agent.conf", destination: "/tmp/puppet.conf"
    subconfig.vm.provision :shell, path: "Vagrant.bootstrap.agent.sh", run: "always"
    #
  end
end
