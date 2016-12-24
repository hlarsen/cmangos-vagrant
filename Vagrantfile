# -*- mode: ruby -*-
# vi: set ft=ruby :

# A Vagrant box for cmangos/mangos-tbc project
Vagrant.configure(2) do |config|
  config.vm.box = "bento/ubuntu-16.04"

  # config.vm.network "public_network"
  # forward ports so our client can connect to the normal ports on the host machine
  config.vm.network "forwarded_port", guest: 3724, host: 3724 # auth server port
  config.vm.network "forwarded_port", guest: 8085, host: 8085 # world server port
  config.vm.network "forwarded_port", guest: 3306, host: 3306 # mysql database

  config.vm.provision "shell", inline: <<-SHELL
    sudo chmod +x /vagrant/provision-scripts/setup.sh
    sudo /vagrant/provision-scripts/setup.sh
  SHELL

  config.vm.provider "virtualbox" do |v|
    v.name = "cmangos-vagrant"
    v.cpus = 2
    v.memory = 2048
  end
end
