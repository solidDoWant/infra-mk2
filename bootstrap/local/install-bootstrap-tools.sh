#!/bin/bash

apt-get install make bzip2 sshpass -y

echo "
*************************************************************************************************************************************************
Remaining tasks and next steps:
1. Setup remote hosts - see ../../hardware/README.md for details
2. Modify the ansible inventory file in the ../remote directory, adding each host to the \"hosts\" group along with any required connection options
3. Run the makefile
"

