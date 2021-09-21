# HPE NC522SFP Firmware Update to 4.0.593

If you plan to use the HPE NC522SFP dual port 10GbE NIC in a server running most modern operating systems, including Ubuntu 20.04 LTS and up (and probably quite a few versions earlier), the firmware for the NIC must be update to at least 4.0.505. This is a very painful process that requires several old pieces of software to work properly.

## How to tell if you're below the firmware cutoff
If you have the NIC installed in the box, are running Ubuntu 20.04 LTS or newer, and the NIC is listed under `ip a`, you're above the cutoff. 

If you don't see the NIC, run `lspci | grep NetXen`. The device should be listed. If not, then the card's firmware may be out of date but there are also other issues outside of the scope of this document.

Run `dmesg | grep 'ID' | grep 'min fw'` where `ID` is the first few characters of the `lspci | grep NetXen` output, i.e. `08:00.0`. It shouldn't matter which entry used as they should both produce similar outputs. If you see a line similar to this:  
`netxen_nic 0000:ID: Flash fw[SOME_FW_VERSION] is < min fw supported[4.0.505]. Please update firmware on flash`  
Then your firmware is out of date and you must update it.

## How to update the card's firmware
This is an extremely tedious task with stringent requirements. The below instructions must be followed exactly:
1. Obtain a server/computer for updating the card. Systems with hardware that is too new may have trouble installing/booting the OS. This guide was tested on a DL380 G7. It may be possible to install the card in a new machine with PCIe passthrough support, install a hypervisor, and setup a VM to handle these tasks, but that's untested. Please note that you will need a storage medium (HDD, flash drive) to install RHEL on. Obviously the card must also be installed in this server.
2. [Get a (free) personal RHEL developer subscription](https://developers.redhat.com/register). Note that most free temporary email sites don't work for this, so the account may need to be created with a Yahoo/Gmail/similar email address.
3. Download RHEL 6.10 by going [here](https://access.redhat.com/downloads) and clicking on "Red Hat Enterprise Linux Versions 7 and below". You may need to sign in again if prompted. Click on the version dropdown at the top of the page and select "6.10". Download the "Red Hat Enterprise Linux 6.10 Binary DVD" file which should have a SHA-256 checksum of `1e15f9202d2cdd4b2bdf9d6503a8543347f0cb8cc06ba9a0dfd2df4fdef5c727`. Do NOT download the "Boot ISO" as it is only the installer and does not include the packages required for installation. 
4. Create a boot device with the downloaded ISO. A DVD is highly recommended, but a USB boot disk is possible with extra work. For USB install, See [these](https://forums.centos.org/viewtopic.php?t=1001) [links](https://access.redhat.com/discussions/1532773) for help with potential issues.
5. Insert the boot device into the server, boot to it, and install the OS.
6. Reboot to the OS.
7. Download the latest [HP QLogic P2/P3 Online Firmware Upgrade Utility for Linux x86_64 from here](https://support.hpe.com/hpesc/public/swd/detail?swItemId=MTX_7a571987b7be47358118ef15ba). I would recommend downloading this on a Windows machine to make the next steps a bit easier.
8. Decompress the file. SCEXE files are shell scripts with binary data appended to them. Gzip will complain and/or fail due to some problems with the data. 7-zip should be able to handle it without issue.
9. Extract the decompressed file. This is actually a tar file. Again, 7-zip should be able to handle it without issue.
10. Copy the extracted files to the server (if not already there).
11. As root, change to the directory of the extracted files.
12. Execute the `nxflash` file.
13. Press `2`, `return` to update the firmware. Press `q` to exit after waiting a bit for the update to complete.
14. Verify that there are two new devices listed under `ip a`. The MAC addresses should start with `18:`.
15. Update complete. The card can now be moved to another machine if needed, and RHEL can be removed/replaced.