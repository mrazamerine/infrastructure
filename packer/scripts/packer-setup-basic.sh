#!/bin/bash

#  packer-setup-basic.sh
#
#
#  Created by Jacob F. Grant
#
#  Written: 06/06/18
#  Updated: 06/08/18
#


# SSH Public keys
maadmin_pub_key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOAHrD9y0ADqM7Xx8BzH4TvzITHLplC7NL2EVnUBSy42 Mraz Amerine ssh key"
ansible_pub_key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDxJ3q0pkPSY3S+3uamTBgAnQpkHFzjGlaWeUdCZnWGi ansible ssh key"



# Wait for cloud-init to complete
while [[ `ps aux | grep cloud-init | grep -v grep | wc -l` -gt 0 ]]
do
    echo "Waiting for cloud-init to complete..."
    sleep 10
done


# Apply updates
echo "Updating..."
sudo apt-get update
apt-get dist-upgrade -y


# Install packages
echo "Installing packages..."
apt-get install aptitude \
                python \
                python-pip \
                python3 \
                python3-pip \
                -y


# Remove unneeded packages
echo "Removing unneeded packages..."
apt-get autoremove -y


# Create MA Admin user
if ! getent passwd "maadmin" > /dev/null 2>&1
then
    echo "Creating MA Admin user..."
    adduser \
        --gecos 'Mraz Amerine Admin' \
        --home /home/maadmin \
        --shell /bin/bash \
        --disabled-password \
        maadmin
else
    echo "MA Admin user already exists..."
fi

sudo -u maadmin bash -c "mkdir -p /home/maadmin/.ssh/"

sudo -u maadmin bash -c 'echo '"$maadmin_pub_key"' > /home/maadmin/.ssh/authorized_keys'


# Create Ansible user
if ! getent passwd "ansible" > /dev/null 2>&1
then
    echo "Createing Ansible user..."
    adduser \
        --gecos 'Ansible User' \
        --home /home/ansible \
        --shell /bin/bash \
        --disabled-password \
        ansible
else
    echo "Ansible user already exists..."
fi

sudo -u ansible bash -c "mkdir -p /home/ansible/.ssh/"

sudo -u ansible bash -c 'echo '"$ansible_pub_key"' > /home/ansible/.ssh/authorized_keys'


# Add Ansible user to sudo
echo '' | EDITOR='tee -a' visudo

echo 'maadmin  ALL=(ALL:ALL) NOPASSWD:ALL' | EDITOR='tee -a' visudo


# Add MA Admin user to sudo
echo '' | EDITOR='tee -a' visudo

echo 'ansible  ALL=(ALL:ALL) NOPASSWD:ALL' | EDITOR='tee -a' visudo


# Disable password ssh login
sed -i 's/^PasswordAuthentication .*$/PasswordAuthentication no/g' /etc/ssh/sshd_config
