#!/bin/bash

apt-get install make bzip2 sshpass -y

echo "
*************************************************************************************************************************************************
Remaining tasks and next steps:
1. Setup remote hosts - see ../../hardware/README.md for details
2. Modify the ansible inventory file in the ../remote directory, adding each host to the \"hosts\" group along with any required connection options
3. Populate the ../remote/vault_password file
4. Create or import your personal GPG key
5. Optionally import a Flux GPG key (this will be made automatically if it doesn't exist already)
6. Run the makefile
"
