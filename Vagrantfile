# -*- mode: ruby -*-
# vi: set ft=ruby :

# A Vagrant box for cmangos projects
Vagrant.configure(2) do |config|
  config.vm.box = "bento/ubuntu-16.04"

  # forward ports so our client can connect to the normal ports on the host machine (localhost)
  #config.vm.network "forwarded_port", guest: 3724, host: 3724 # auth server port
  #config.vm.network "forwarded_port", guest: 8085, host: 8085 # world server port

  # disable or change port if you're running a mysql server on your host machine and there is a conflict
  #config.vm.network "forwarded_port", guest: 3306, host: 3306 # mysql database

  # enable for another interface with an IP on your LAN
  # config.vm.network "public_network"

  # VM config (up CPU/RAM for faster compilation)
  config.vm.provider "virtualbox" do |v|
    v.cpus = 2
    v.memory = 2048
  end

  # classic
  config.vm.define "classic", autostart: false do |classic|
    config.vm.provider "virtualbox" do |v|
      v.name = "cmangos-classic"
    end

    classic.vm.provision "shell" do |s|
      s.path = "provision-scripts/setup.sh"
      s.args = "classic"
    end
  end

  # tbc
  config.vm.define "tbc", autostart: false do |tbc|
    config.vm.provider "virtualbox" do |v|
      v.name = "cmangos-tbc"
    end

    tbc.vm.provision "shell" do |s|
      s.path = "provision-scripts/setup.sh"
      s.args = "tbc"
    end
  end

  # wotlk
  config.vm.define "wotlk", autostart: false do |wotlk|
    config.vm.provider "virtualbox" do |v|
      v.name = "cmangos-wotlk"
    end

    wotlk.vm.provision "shell" do |s|
      s.path = "provision-scripts/setup.sh"
      s.args = "wotlk"
    end
  end
end
