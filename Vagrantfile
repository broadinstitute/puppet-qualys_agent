# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "broadinstitute/centos-7-puppet-5"
  config.vm.box_check_update = true

  config.vm.network "private_network", type: "dhcp",
    virtualbox__intnet: "vboxnet1"

  config.vm.hostname = "puppet-qualys-agent.example.com"

  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.memory = "1024"
    vb.name = "puppet-qualys-agent"
    automount = true
  end

  config.vm.provision "file", source: "vagrant_files/global.yaml", destination: "/tmp/global.yaml"
  config.vm.provision "shell", path: "vagrant_files/centos7-p5.sh"

  config.vm.synced_folder ".", "/etc/puppetlabs/code/modules/qualys_agent", type: "rsync",
    rsync__verbose: true, rsync__args: ["--verbose", "--archive", "-z", "--copy-links"],
    rsync__exclude: ["Gemfile.lock", ".git", "Vagrantfile", "vagrant_files"]

  config.ssh.insert_key = false
end
