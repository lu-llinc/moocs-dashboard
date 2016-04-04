## README

This repository contains a vagrant machine that sets up and configures a virtual environment containing the necessary software to run a dashboard displaying Coursera MOOC data from your local browser.

Below, you will find instructions to boot the VM. For more detailed instructions, please visit [this document](https://jasperginn_leiden.gitbooks.io/a-shiny-dashboard-for-coursera-mooc-data/content/).

## Setting up the vagrantbox

1. Install [virtualbox](https://www.virtualbox.org/wiki/Downloads)
2. Install [vagrant](https://www.vagrantup.com/docs/installation/)

See https://docs.vagrantup.com/v2/ for documentation on vagrant.

The vagrant repository contains several files:

1. **Vagrantfile** --> The vagrant configuration (amount of ram, cpus to use etc.)
2. **provision.sh** --> Bash file with all programs to install
3. **R_requirements.txt** --> contains a list of R packages to be installed
4. **InstallRpackages.R** --> Code to install R packages
5. **export.sh** --> Bash file that exports environment/PATH variables. Due to the nature of vagrant VMs, it is called every time the VM starts up

Navigate to the folder where you downloaded the box via terminal and run 'vagrant up' to start up the machine. When it is fully provisioned / booted (this could take some time if the box is starting up for the first time), you can enter the environment by entering "vagrant ssh". 

### BASIC COMMANDS

vagrant up 
	- Sets up the Virtual Machine (VM)

vagrant ssh
	- Boots into the VM (need to vagrant up first)

vagrant suspend
	- VM is temporarily suspended. Machine state is written to hard drive.

vagrant halt
	- VM is shut down.

vagrant destroy
	- Destroys VM

## PostgreSQL 

To find the IP adress on your local computer, run "netstat -rn | grep "^0.0.0.0 " | cut -d " " -f10" in the vagrant box



