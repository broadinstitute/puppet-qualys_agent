# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  # config.vm.box = "centos/7"
  config.vm.box = "vineetmadan/centos7.6"
  # config.vm.box_check_update = false
  # config.vm.network "forwarded_port", guest: 80, host: 8080
  # config.vm.network "private_network", ip: "192.168.33.10"
  # config.vm.network "public_network"

  config.vm.network "private_network", type: "dhcp",
    virtualbox__intnet: "vboxnet1"

  config.vm.hostname = "puppet-qualys-agent.example.com"

  config.vm.provider "virtualbox" do |vb|
   vb.gui = false
   vb.memory = "1024"
   vb.name = "puppet-qualys-agent"
   automount = true
  end

  config.vm.provision "file", source: "Gemfile", destination: "/tmp/Gemfile"
  config.vm.provision "file", source: "vagrant_files/hiera.yaml", destination: "/tmp/hiera.yaml"
  config.vm.provision "file", source: "vagrant_files/global.yaml", destination: "/tmp/global.yaml"
  config.vm.provision "file", source: "vagrant_files/pdk.sh", destination: "/tmp/pdk.sh"
  config.vm.provision "shell", path: "vagrant_files/centos7-p5.sh"

  config.vm.synced_folder ".", "/etc/puppetlabs/code/modules/qualys_agent"

  config.ssh.insert_key = false
end
