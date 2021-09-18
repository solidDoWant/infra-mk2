#!/bin/bash

apt-get install make bzip2 -y


echo "
*************************************************************************************************************************************************
Remaining tasks and next steps:
1. Setup remote hosts - see ../../hardware/README.md for details
1.a. Install Ubuntu 20.04 LTS
1.b. Setup networking (edit or create the netplan config file under /etc/netplan/* on the remote host)
1.c. Setup a SSH server (install openssh-server and configure any needed options in /etc/ssh/sshd_config and restart the service)
1.d. Optionally create a new user with sudo permissions
2. Create a new SSH key pair (i.e. ssh-keygen)
3. Add the public key to a remote user (i.e. root or user craeted in 1.d.) to ~/.ssh/authorized_keys on each remote host (i.e. ssh-copy-id <user>@<host>)
4. Add the private key to ~/.ssh/id_rsa locally (not needed if ssh-keygen was used)
5. Modify the ansible inventory file in the ../remote directory, adding each host to the \"hosts\" group along with any required connection options
6. Run the makefile
"

