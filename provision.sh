#!/usr/bin/env bash

### Provisioning the virtual machine

# Update
sudo apt-get update

# Install anaconda
anaconda=Anaconda2-2.5.0-Linux-x86_64.sh
cd /vagrant

# If not exists, create folder downloads
if [ ! -d "downloads" ]; then
	mkdir data
	mkdir downloads
fi

cd downloads

if [ ! -f $anaconda ]; then
	echo "Downloading anaconda installer..."
    wget -q -o /dev/null - http://repo.continuum.io/archive/Anaconda2-2.5.0-Linux-x86_64.sh
    chmod +x $anaconda
fi

echo "Installing Anaconda..."
sudo ./$anaconda -b -p /opt/anaconda

# Back to vagrant home
cd /home/vagrant

# Install base packages
echo "Installing base requirements..."
sudo apt-get install -y zlib1g-dev
sudo apt-get install -y git 
sudo apt-get install -y g++ 
sudo apt-get install -y postgresql-client

sudo apt-get install -y zip
sudo apt-get install -y unzip
sudo apt-get install -y libxml2-dev 
sudo apt-get install -y libxslt1-dev

sudo apt-get -y install libcurl4-openssl-dev  
sudo apt-get -y install libssl0.9.8
sudo apt-get -y install libcairo2-dev
sudo apt-get install -y libpq-dev

echo "Installing htop..."
sudo apt-get install -y htop

# Update
sudo apt-get update 

echo "Installing R-base..."
# Add cran to list of sources (to get the last version of R)
echo "deb http://cran.rstudio.com/bin/linux/ubuntu trusty/" | sudo tee -a /etc/apt/sources.list
# Add public keys
gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9
gpg -a --export E084DAB9 | sudo apt-key add -
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get install -y r-base r-base-dev

echo "Installing and configuring shiny server..."
sudo apt-get install -y libjpeg62 
sudo apt-get install -y libpq-dev
sudo apt-get install -y gdebi-core 
sudo apt-get install -y libapparmor1 

shiny=shiny-server-1.4.2.786-amd64.deb
cd /vagrant/downloads

if [ ! -f $shiny ]; then
	echo "Downloading shiny installer..."
    wget wget https://download3.rstudio.org/ubuntu-12.04/x86_64/shiny-server-1.4.2.786-amd64.deb
    chmod +x $shiny
fi

echo "Installing shiny server..."
sudo gdebi $shiny
sudo dpkg -i $shiny

# Back to vagrant home
cd /home/vagrant
# Link dashboard
sudo ln -s /vagrant/shiny_dashboard /srv/shiny-server
# Auth
sudo usermod -a -G vagrant shiny
# Symlink python scripts
sudo ln -s /vagrant/python /home/vagrant

echo "Updating..."
sudo apt-get update

echo "Installing R packages..."
sudo R CMD BATCH /vagrant/InstallRpackages.R

echo "Installing rJava..."
sudo apt-get install -y r-cran-rjava

# Echo path to profile
echo "source /vagrant/export.sh" | /usr/bin/tee -a /home/vagrant/.bashrc
