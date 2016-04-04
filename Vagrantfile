# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	config.vm.box = "ubuntu/trusty64"
  config.vm.box_url = "https://vagrantcloud.com/ubuntu/trusty64"
  config.vm.provision :shell, :path => "provision.sh"

	config.vm.provider :virtualbox do |vb, override|
    ## Forward ports

    # IPython Notebook
    override.vm.network :forwarded_port, host: 8888, guest: 8888

    # Shiny server
    override.vm.network :forwarded_port, host: 3838, guest: 3838

	end
  
  config.vm.provider "virtualbox" do |vb|
  	#vb.customize ["modifyvm", :id, "--vram", "100"]
    vb.customize ["modifyvm", :id, "--memory", "4000"]
    vb.customize ["modifyvm", :id, "--cpus", "2"]
  end
end
