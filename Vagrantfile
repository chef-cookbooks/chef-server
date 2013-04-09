# -*- mode: ruby -*-
# vi: set ft=ruby :

# We'll mount the Chef::Config[:file_cache_path] so it persists between
# Vagrant VMs
host_cache_path = File.expand_path("../.cache", __FILE__)
guest_cache_path = "/tmp/vagrant-cache"

Vagrant.configure("2") do |config|

  config.vm.hostname = "chef-server"

  config.vm.box = "canonical-ubuntu-12.04"
  config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box"
  # config.vm.box = "opscode-ubuntu-10.04"
  # config.vm.box_url = "http://opscode-vm.s3.amazonaws.com/vagrant/opscode_ubuntu-10.04_chef-11.2.0.box"
  # config.vm.box = "opscode-centos-6.3"
  # config.vm.box_url = "http://opscode-vm.s3.amazonaws.com/vagrant/opscode_centos-6.3_chef-11.2.0.box"

  # Ensure Chef is installed for provisioning
  config.omnibus.chef_version = :latest

  config.vm.network :private_network, :ip => "33.33.33.50"

  config.vm.provider :virtualbox do |vb|
    # Give enough horsepower to build without taking all day.
    vb.customize [
      "modifyvm", :id,
      "--memory", "1024",
      "--cpus", "2",
    ]
  end

  config.ssh.max_tries = 40
  config.ssh.timeout   = 120
  # Enable SSH agent forwarding for git clones
  config.ssh.forward_agent = true

  # The path to the Berksfile to use with Vagrant Berkshelf
  config.berkshelf.berksfile_path = "./Berksfile"

  config.vm.synced_folder host_cache_path, guest_cache_path

  config.vm.provision :chef_solo do |chef|
    chef.provisioning_path = guest_cache_path
    chef.json = {
      "chef-server" => {
        "version" => :latest
      }
    }

    chef.run_list = [
      "recipe[chef-server::default]"
    ]
  end
end
