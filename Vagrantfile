# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.

  config.vm.box = "vagrant-rails-bootstrap"
  config.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-6.6_chef-provisionerless.box"

  config.vm.network "private_network", ip: "192.168.33.10"

  config.vm.network :forwarded_port, guest: 3000, host: 13000

  config.vm.provision :shell, path: 'bootstrap.sh', keep_color: true, privileged: false

  case RUBY_PLATFORM
  when /darwin/
    config.vm.synced_folder "./shared-data", "/var/www", type: "rsync", rsync__exclude: [".git/", "tmp/"]
  when /mswin/
    config.vm.synced_folder "./shared-data", "/var/www"
  end

  config.ssh.forward_agent = true

  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
    v.cpus = 2
  end
end
