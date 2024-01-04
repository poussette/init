#!/bin/bash

# Give short name to host
shorthostname="OVH-X"
sudo hostnamectl set-hostname $shorthostname

# is this host dedicated testnet or mainnet ?
hostpurpose="mainnet"

# user to run nodes
user="noderunner"


# Run this script under root , just after 1rst OS Install and boot
sudo apt-get update && sudo apt-get -y upgrade && sudo apt-get -y dist-upgrade
sudo apt -y autoremove && sudo apt-get -y autoclean

# needed for pip3 install
sudo apt install python3-pip <<< 'Y' 
# JSon query installe
sudo apt install jq <<< 'Y' 
# ifconfig, netstat etc...
sudo apt install net-tools <<< 'Y' 
# iftop
sudo apt install iftop <<< 'Y' 
# smem
sudo apt install smem <<< 'Y' 
# bmon
sudo apt install bmon <<< 'Y' 

# Net data install

# add a nonroot user
sudo useradd -s /bin/bash -d /home/$user -m -G sudo $user && echo "user $user added with sudo"

# Change prompt to not be confused on login
#(echo ; echo PS1=\"\\\u@$hostpurpose"_"$shorthostname:\\\w\\\$ \") >> /home/$user/.bashrc
# Copy nodes script and install to ~/noderunner/install


# make nonroot user to sudo without upasswd
sudo bash -c "echo \"$user ALL=(ALL) NOPASSWD:ALL\" >>/etc/sudoers.d/myOverrides"
sudo chmod 440 /etc/sudoers.d/myOverrides

# change ssh port in sshd_config
sshport=65203
[ -f /etc/ssh/sshd_config.orig ] || sudo cp /etc/ssh/{sshd_config,sshd_config.orig}
sudo sed -i 's/^#*[Pp]ort *.*/Port '${sshport}'/; s/^Include/#Include/; s/^#*PermitRootLogin .*/PermitRootLogin prohibit-password/; s/^#*MaxAuthTries .*/MaxAuthTries 4/; s/^#*MaxSessions .*/MaxSessions 2/; s/^#*PubkeyAuthentication .*/PubkeyAuthentication yes/; s/^#*AuthorizedKeysFile .*/AuthorizedKeysFile .ssh\/authorized_keys/; s/^#*PasswordAuthentication .*/PasswordAuthentication no/; s/^#*PermitEmptyPasswords .*/PermitEmptyPasswords no/; s/^#*ChallengeResponseAuthentication .*/ChallengeResponseAuthentication no/; s/^#*UsePAM .*/UsePAM no/; s/^#*X11Forwarding no/X11Forwarding no/' /etc/ssh/sshd_config
sudo systemctl restart ssh

# get IP address
myip=$(ip -f inet -o addr show | grep -v ' lo ' | cut -d\  -f 7 | cut -d/ -f 1)

elrond_node_ports="37373:38383/tcp"

# configure firewall ufw rules
sudo ufw reset
sudo ufw allow $elrond_node_ports
sudo ufw limit $sshport
sudo ufw enable
sudo ufw status
sudo ufw deny proto tcp to 10.0.0.0/8
sudo ufw deny proto tcp to 172.16.0.0/12
sudo ufw deny proto tcp to 192.168.0.0/16


# Set Default Editor
sudo bash -c "(echo; echo 'export EDITOR=vim') >>/etc/profile"

