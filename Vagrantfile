# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "boxcutter/ubuntu1404"
  config.vm.provision "shell", inline: <<-SHELL
    sudo -i
    # Install Docker
    curl -s https://get.docker.com/ | bash -s
    # Install Ruby via RVM
    gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
    curl -sSL https://get.rvm.io | bash -s stable
    /usr/local/rvm/bin/rvm install 2.4.1
  SHELL
end
