# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box     = "bento/ubuntu-20.04"

  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--memory", "2048", "--ioapic", "on", "--cpus", "4"]
  end

  config.vm.synced_folder ".", "/vagrant"

  # install docker
  config.vm.provision "shell", inline: <<-SCRIPT
    if [[ ! `which docker > /dev/null 2>&1` ]]; then
      # add docker's gpg key
      apt-key adv \
        --keyserver hkp://keyserver.ubuntu.com \
        --recv-keys 7EA0A9C3F273FCD8

      # add the docker source to our apt sources
      echo \
        "deb https://download.docker.com/linux/ubuntu focal stable \n" \
          > /etc/apt/sources.list.d/docker.list

      # update the package index
      apt-get -y update

      # ensure the old repo is purged
      apt-get -y purge lxc-docker docker docker-engine docker.io containerd runc

      # install docker
      apt-get -y install docker-ce docker-ce-cli containerd.io

      # clean up packages that aren't needed
      apt-get -y autoremove

      # add the vagrant user to the docker group
      usermod -aG docker vagrant
    fi
  SCRIPT

  # start docker
  config.vm.provision "shell", inline: <<-SCRIPT
    if [[ ! `service docker status | grep "start/running"` ]]; then
      # start the docker daemon
      service docker start
    fi
  SCRIPT

  # wait for docker to be running
  config.vm.provision "shell", inline: <<-SCRIPT
    echo "Waiting for docker sock file"
    while [ ! -S /var/run/docker.sock ]; do
      sleep 1
    done
  SCRIPT

  # install dependencies
  config.vm.provision "shell", inline: <<-SCRIPT
    apt-get install -y build-essential awscli
  SCRIPT

  # build the docker images
  config.vm.provision "shell", inline: <<-SCRIPT
    echo "Building docker images..."
    cd /vagrant
    make linux-env
    make mac-env
    make windows-env
  SCRIPT

end
