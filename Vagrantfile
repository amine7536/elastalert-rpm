# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV["LC_ALL"] = "en_US.UTF-8"
BOX="boxcutter/centos73"
# BOX_URL="file:///Users/amine/Develop/github/pixboxes-centos/box/vmware/centos73-1.0.1.box"


Vagrant.configure("2") do |config|

  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true

  # Builder Server
  config.vm.define "builder" do |builder|
    builder.vm.box = BOX

    builder.vm.network "private_network", ip: "10.0.10.10"
    builder.hostmanager.aliases = "builder"

    builder.vm.provision "shell", inline: <<-SHELL
      # Disable ipv6
      sudo echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
      sudo echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
      sudo sysctl -p
      sudo systemctl restart network

    SHELL

  end
  
end
