# Purpose
The primary purpose of this directory is documentation and setup files for hardware-level configuration.

## Sections
* Architecture
* Power
* Network
* Servers/nodes
* Storage
* Remote and local management
* Bootloader, OS and install

## Architecture
Below is a rack diagram depicting the location and overal design of the system:
![Rack diagram](images/rack_architecture.drawio.svg)

## Power
All devices are connected to the UPS at the bottom of the rack. Devices with multiple power supplies are (currently) only connected via the power supply labeled 1/A/primary/etc. The UPS is connected to a 120V 20A outlet.

UPS monitoring is not yet setup and the management interface is not connected to any host.

### Hardware:  
* UPS:  
  &emsp;Model: Liebert PS1500RT3-120W  
  &emsp;Power output: 1500 VA, 1350 W  
  &emsp;Batteries: 3x 12V 9AH, total capacity 324 W hours  
  &emsp;Ideal runtime under full real power load: 14m 24s

## Network
All servers are connected to the top of rack switch via a 10 Gbps link. These links use various 1-2 port SFP+ NICs in each server. Traffic is segregated into VLANs depending on purpose. All physical hosts and some virtual host's internal IP addresses fall under the 10.0.0.0/8 private IP range. The gateway is always the first valid IP in the VLANs range. Some internal services that manage networks (i.e. Kubernetes CNI) may use other private IP ranges.

The vm-host-01.echozulu.local server runs a VM called router-01.echozulu.local which acts as a OPNsense apppliance for the network edge. The Google Fiber fiber jack (not shown in diagram) is connected to the primary SPF+ port on the PCIe NIC via a 1000BASE-T SFP+ module. The card is passed through to the VM via SR-IOV.

The switch switch-01.echozulu.local has routing and ACL capabilities and handles routing for all 10 Gbps traffic.

### VLANs:
* Name: Management  
  Description: Out of band management (i.e. iDRAC, iLO)  
  ID: 100  
  IP range: 10.0.0.0/16  
  Gateway: 10.0.0.1 (switch)
* Name: Hosts  
  Description: Default host traffic (i.e. SSH sessions, updates)  
  ID: 200  
  IP range: 10.1.0.0/16  
  Gateway: 10.1.0.1 (switch)
* Name: Kubernetes  
  Description: Traffic between Kubernetes pods  
  ID: 300  
  IP range: 10.2.0.0/16  
  Gateway: 10.2.0.1 (switch)
* Name: Devices  
  Description: End user devices (i.e. desktops)  
  IP range: 10.3.0.0/16  
  Gateway: 10.3.0.1 (switch)  
  ID: 400
* Name: Guests  
  Description: Guest devices, less privileged  
  ID: 500  
  IP range: 10.4.0.0/16  
  Gateway: 10.4.0.1 (switch)

### Hardware:  
* Switch:  
  &emsp;Model: Brocade ICX6610  
  &emsp;Ports:
  * 2x QSFP+ at 40 Gbps
  * 2x QSFP+ requiring breakout to 4x 10 Gbps links
  * 10x SFP+ at 10 Gbps
  * 48x RJ-45 at 1 Gbps with PoE+ (30W delivered)
* Trancievers:  
  &emsp;10 Gbps traffic:
  * Model: Brocade 10G-SFPP-SR
  * Connector: LC duplex
  * Max distance: 300m with OM3

  &emsp;1 Gbps traffic:
  * Model: Avago ABCU-5700RZ 1000Base-T
  * Connector: RJ-45
* Fiber optic cables:  
  &emsp;Type: Patch  
  &emsp;Connector: LC UPC to LC UPC (duplex)  
  &emsp;Mode: OM3  
  &emsp;Length: 3m

## Servers/nodes
All nodes are connected to the KVM switch, which is connected to a monitor, keyboard, and mouse. The setup currently contains four nodes:

### vm-host-01.echozulu.local
Used for running VMs, including OPNsense which acts as an edge firewall.

### Hardware:
* Server:  
  &emsp;Model: HPE DL385 G7  
  &emsp;CPU:  
  &emsp;&emsp;Model: Opteron 6276  
  &emsp;&emsp;Clock frequency: 2.3 GHz  
  &emsp;&emsp;Core/thread count: 16/16  
  &emsp;&emsp;Socket: G34  
  &emsp;&emsp;Count: ~~2~~ 1 while the mismatched processor issue is fixed  
  &emsp;&emsp;TDP: 130W
  &emsp;RAM:  
  &emsp;&emsp; Type: DDR3 ECC Registered  
  &emsp;&emsp; Total size: 48 GB  
  &emsp;&emsp; Clock rate: 1333 MHz  
  &emsp;&emsp; Total DIMM slots: 24  
  &emsp;Storage:
  * Type: SSD  
  Capacity: 240 GB  
  Model: WD easystore  
  Interface: SATA  
  Location: Internal, optical SATA port  
  Count: 1

  &emsp;NIC:  
  &emsp;&emsp;Model: HPE NC522SFP  
  &emsp;&emsp;Ports: 2x SFP+  
  &emsp;&emsp;Max MTU: 9000 bytes  
  &emsp;&emsp;Offload suppport: TCO, LSO  
  &emsp;&emsp;Interface: 8x PCIe 2  
  &emsp;Drive controllers:  
  * Model: HPE P410

  &emsp;Power supply:  
  &emsp;&emsp;Max power out: 750 W  
  &emsp;&emsp;Count: 2  
  &emsp;&emsp;Hot swapable: Yes  
  &emsp;Out of band management:  
  &emsp;&emsp;Model: iLO 3  
  &emsp;&emsp;License: Advanced  
  &emsp;&emsp;Default username on reset: Administrator

### k8s-host-01.echozulu.local
Used for providing Kubernetes compute and storage.

### Hardware:
* Server:  
  &emsp;Model: Whitebox  
  &emsp;Motherboard:  
  &emsp;&emsp;Model: ASUS PRIME Z590-V  
  &emsp;CPU:  
  &emsp;&emsp;Model: i7-10700  
  &emsp;&emsp;Clock frequency: 2.9 GHz  
  &emsp;&emsp;Core/thread count: 8/16  
  &emsp;&emsp;Count: 1  
  &emsp;&emsp;Socket: LGA 2011
  &emsp;&emsp;TDP: 65W
  &emsp;RAM:  
  &emsp;&emsp; Type: DDR4  
  &emsp;&emsp; Total size: 16GB  
  &emsp;&emsp; Clock rate: 3200 MHz (XMP)  
  &emsp;&emsp; Total DIMM slots: 4  
  &emsp;Storage:
  * Type: SSD  
  Capacity: 512 GB  
  Model: Inland Premium  
  Interface: NVMe  
  Location: Internal, M.2 slot 2  
  Count: 1
  * Type: HDD  
  Capacity: 512 GB  
  Model: Seagate
  Interface: SATA-III  
  Rotational speed: 7200 RPM  
  Location: Internal, SATA ports 1-4  
  Count: 4

  &emsp;NIC:  
  &emsp;&emsp;Model: Solarflare S6102  
  &emsp;&emsp;Ports: 2x SFP+  
  &emsp;&emsp;Max MTU: 9000 bytes  
  &emsp;&emsp;Offload suppport: OpenOnload, TCO, LSO, LRO, GSO, RSS  
  &emsp;&emsp;Interface: 8x PCIe 2  
  &emsp;Graphics card:  
  &emsp;&emsp;Model: XFX R9 280X  
  &emsp;&emsp;VRAM: 3GB 384 bit GDDR5 @ 6000 MHz  
  &emsp;&emsp;Processors: 2048  
  &emsp;&emsp;Core clock: 850 MHz  
  &emsp;&emsp;Interface: 16x PCIe 3  
  &emsp;&emsp;TDP: 250W  
  &emsp;Power supply:  
  &emsp;&emsp;Max power out: 600 W  
  &emsp;&emsp;Count: 1  
  &emsp;&emsp;Hot swapable: No  
### k8s-host-02.echozulu.local
Used for providing Kubernetes compute and storage.

### Hardware:
* Server:  
  &emsp;Model: Dell R720  
  &emsp;CPU:  
  &emsp;&emsp;Model: Xeon E5-2690  
  &emsp;&emsp;Clock frequency: 2.9 GHz  
  &emsp;&emsp;Core/thread count: 8/16  
  &emsp;&emsp;Socket: LGA 2011  
  &emsp;&emsp;Count: 2  
  &emsp;&emsp;TDP: 135W
  &emsp;RAM:  
  &emsp;&emsp; Type: DDR3 ECC Registered  
  &emsp;&emsp; Total size: 128 GB  
  &emsp;&emsp; Clock rate: 1600 MHz  
  &emsp;&emsp; Total DIMM slots: 24  
  &emsp;Storage:
  * Type: USB
  Capacity: 16 GB
  Model: Microcenter generic
  Interface: USB 2.0
  Location: Internal USB 2
  Count: 1
  * Type: SSD  
  Capacity: 512 GB  
  Model: Inland Premium  
  Interface: NVMe  
  Location: Internal, PCIe to M.2 NVMe card  
  Count: 1
  * Type: SSD  
  Capacity: 512 GB  
  Model: Intel Series 750  
  Interface: U.2  
  Location: Internal, PCIe to U.2 card  
  Count: 1
  * Type: HDD  
  Capacity: 900 GB  
  Model: Seagate  
  Interface: SAS-II  
  Rotational speed: 10k RPM  
  Location: External, first four bays to LSI SAS 9207-8i  
  Count: 4
  * Type: HDD  
  Capacity: 146 GB  
  Model: HP  
  Interface: SAS-II  
  Rotational speed: 10k RPM  
  Location: External, second 4 bays to LSI SAS 9207-8i  
  Count: 4

  &emsp;NIC:  
  &emsp;&emsp;Model: Dell C63DV  
  &emsp;&emsp;Ports: 2x SFP+, 2x 1Gbps RJ-45  
  &emsp;&emsp;Max MTU: 9000 bytes  
  &emsp;&emsp;Offload suppport: TCO, LSO  
  &emsp;&emsp;Interface: Network mezzanine  
  &emsp;Drive controllers:  
  * Model: LSI SAS 9207-8i  
  Interface: 8x PCIe 3
  * Model: LSI SAS 9207-8e  
  Interface: 8x PCIe 3

  &emsp;Power supply:  
  &emsp;&emsp;Max power out: 900 W  
  &emsp;&emsp;Count: 2  
  &emsp;&emsp;Hot swapable: Yes  
  &emsp;Out of band management:  
  &emsp;&emsp;Model: iDRAC
  &emsp;&emsp;License: Enterprise  
  &emsp;&emsp;Default username on reset: root

### k8s-host-03.echozulu.local
Used for providing Kubernetes compute and storage.

### Hardware:
* Server:  
  &emsp;Model: HPE DL380 G7  
  &emsp;CPU:  
  &emsp;&emsp;Model: Xeon X5680  
  &emsp;&emsp;Clock frequency: 3.3 GHz  
  &emsp;&emsp;Core/thread count: 6/12  
  &emsp;&emsp;Socket: LGA 1366  
  &emsp;&emsp;Count: 2  
  &emsp;&emsp;TDP: 130W  
  &emsp;RAM:  
  &emsp;&emsp; Type: DDR3 ECC Registered  
  &emsp;&emsp; Total size: 72 GB  
  &emsp;&emsp; Clock rate: 1333 MHz  
  &emsp;&emsp; Total DIMM slots: 24  
  &emsp;Storage:
  * Type: USB
  Capacity: 16 GB
  Model: Microcenter generic
  Interface: USB 2.0
  Location: Internal USB 2
  Count: 1
  * Type: SSD  
  Capacity: 512 GB  
  Model: Inland Premium  
  Interface: NVMe  
  Location: Internal, PCIe to M.2 NVMe card  
  Count: 1
  * Type: SSD  
  Capacity: 512 GB  
  Model: Intel Series 750  
  Interface: U.2  
  Location: Internal, PCIe to U.2 card  
  Count: 1
  * Type: HDD  
  Capacity: 900 GB  
  Model: Seagate  
  Interface: SAS-II  
  Rotational speed: 10k RPM  
  Location: External, first four bays to LSI SAS 9207-8i  
  Count: 4
  * Type: HDD  
  Capacity: 146 GB  
  Model: HP  
  Interface: SAS-II  
  Rotational speed: 10k RPM  
  Location: External, second 4 bays to LSI SAS 9207-8i  
  Count: 4

  &emsp;NIC:  
  &emsp;&emsp;Model: HPE NC522SFP  
  &emsp;&emsp;Ports: 2x SFP+  
  &emsp;&emsp;Max MTU: 9000 bytes  
  &emsp;&emsp;Offload suppport: TCO, LSO  
  &emsp;&emsp;Interface: 8x PCIe 2  
  &emsp;Drive controllers:  
  * Model: HPE P410  
  Interface: 4x PCIe 2  
  Write cache: 512MB battery-backed  

  &emsp;Power supply:  
  &emsp;&emsp;Max power out: 750 W  
  &emsp;&emsp;Count: 2  
  &emsp;&emsp;Hot swapable: Yes  
  &emsp;Out of band management:  
  &emsp;&emsp;Model: iLO 3  
  &emsp;&emsp;License: Advanced  
  &emsp;&emsp;Default username on reset: Administrator

## Storage
All nodes use a solid state drive for the OS.

### vm-host-01.echozulu.local 
This host only contains one drive, a SATA-III SSD, for boot. SAS expander and RAID cache have been removed to reduce power consumption and failure points.

### k8s-host-01.echozulu.local
This host boots off the NVMe drive in M.2 slot 2. The additional HDDs are passed through to the OS for < TODO purpose >

### k8s-host-02.echozulu.local
Because the host does not support boot fron NVMe, this host boots off the USB flash drive, which in turn loads the OS from the NVMe drive.

The enterprise-grade PCIe SSD is used by Ceph for read/write acceleration. The additional drives are manged by the host for storage shared over the network.

Attached to the host for additional storage is a NetApp DS4246 diskshelf. The shelf is attached via DAC cables to a HBA.

### k8s-host-03.echozulu.local
Because the host does not support boot fron NVMe, this host boots off the USB flash drive, which in turn loads the OS from the NVMe drive.

The enterprise-grade PCIe SSD is used by Ceph for read/write acceleration. The additional drives are manged by the host for storage shared over the network. The additional drives are passed through to the OS via single drive RAID groups.

### Hardware
* Disk shelf:  
  &emsp;Model: NetApp DS4246 disk shelf  
  &emsp;Controllers: 2x IOM 6  
  &emsp;Cables: SFF-8436 to SFF-8088  
  &emsp;Storage:
  * Type: HDD  
  Capacity: 3 TB  
  Model: HGST  
  Interface: SAS-II  
  Rotational speed: 7200 RPM  
  Location: External, first eight bays  
  Count: 8

## Remote and local management
All hosts except for k8s-host-01.echozulu.local have out of band management capabilities.

## Bootloader, OS, and install
Hosts that do not support booting from the OS drive due to physical interface initially load [Clover Bootloader](https://github.com/CloverHackyColor/CloverBootloader) which in turn launches the OS.

BIOS and firmware updates are installed as needed.

Setup host requirements: A relatively modern computer with Internet access and a free USB port. Tools listed are compatible with Windows but there are others available that are compatible with Linux, macOS, and other OSs.

### switch-01.echozulu.local
Initial network setup is important as to allow proper setup and access to oother hosts. There are several things that need to be completed to get the switch ready for the environment.

#### [Update software and reset to factory defaults](https://fohdeesha.com/docs/fcx/#updating-the-software):
1. Connect the setup host to the console port via a console cable.
2. Connect the management interface to the setup host's network.
3. Use [PuTTY](https://www.putty.org/) to connect to the switch via console cable. Baud rate is 9600. Eight data bits and one stop bit.
4. Setup a temporary [TFTP server](https://pjo2.github.io/tftpd64/) on the setup host.
5. Download and extract the latest switch firmware ([link, latest as of 9/9/21](https://fohdeesha.com/data/other/brocade/8030t.zip)). The firmware updates also contain extensive user manuals for the switch.
6. Create a new temporary folder on the setup hosts to serve files from. Then, copy the files from the "FCX - ICX6610\\{Boot,Images,PoE Firmware}" folders to the temporary directory.
7. Configure the TFTP server to serve files from the temporary directory.
8. Turn on or reboot the server. If the server has already been started, it can be restarted via software with the `enable` then `reload` command.
9. Press `b` quickly to enter the bootloader prompt.
10. Configure the management interface. Assign a static IP with the command `ip address <SWITCH_IP>/<CIDR>` (i.e. `ip address 10.2.1.12/16`). DHCP is not supported by the bootloader. If needed, the default gateway can be set with `ip default-gateway <GATEWAY_IP>`.
11. Copy the updated bootloader and OS with the following commands:  
```
copy tftp flash <SETUP_HOST_IP> grz10100.bin boot
copy tftp flash <SETUP_HOST_IP> FCXR08030t.bin primary
```
12. Reset the switch to factory defaults via `factory set-default`.
13. Reboot with `reset`.
14. After the switch comes back up, update the PoE firmware with the following commands:  
```
enable
configure terminal
interface management 1
ip address <SWITCH_IP>/<CIDR>
ip route 0.0.0.0 <GATEWAY_IP>
exit
exit
inline power install-firmware stack-unit 1 tftp <SETUP_HOST_IP> fcx_poeplus_02.1.0.b004.fw
! Wait a bit for the update to complete
write memory
```

#### Setup licenses
```
! run enable if not already in privileged mode
enable
license delete unit 1 all
```
Remaining steps are left as an exercise for the reader.

#### Set SFP+ port speed
```
configure terminal
interface ethernet 1/3/1 to 1/3/8
speed-duplex 10g-full
! if the switch pauses after this for a minute, it's normal
write memory
exit
```

#### Disable stack ports
This the rear stack ports to be used as normal ports.
```
stack unit 1
no stack-trunk 1/3/1 to 1/3/2
no stack-trunk 1/3/6 to 1/3/7
exit
write mem
```

#### VLAN configuration
```
! Management VLAN
vlan 100 name management by port
untagged ethernet 1/1/1 to 1/1/8
tagged ethernet 1/3/8
router-interface ve 100
interface ve100
port-name management
ip address 10.0.0.2/16
!
! Hosts VLAN
vlan 200 name hosts by port
tagged ethernet 1/3/1 to 1/3/4
tagged ethernet 1/1/9 to 1/1/16
tagged ethernet 1/3/8
router-interface ve 200
interface ethernet 1/3/1 to 1/3/4
dual-mode 200
interface ethernet 1/1/9 to 1/1/16
dual-mode 200
interface ethernet 1/3/8
dual-mode 200
interface ve200
port-name hosts
ip address 10.1.0.2/16
!
! Kubernetes VLAN
vlan 300 name kubernetes by port
tagged ethernet 1/3/1 to 1/3/4
tagged ethernet 1/1/9 to 1/1/16
tagged ethernet 1/3/8
router-interface ve 300
interface ve300
port-name kubernetes
ip address 10.2.0.2/16
!
! Devices VLAN
vlan 400 name devices by port
untagged ethernet 1/3/5 to 1/3/7
tagged ethernet 1/1/25 to 1/1/40
tagged ethernet 1/3/8
router-interface ve 400
interface ethernet 1/1/25 to 1/1/32
dual-mode 400
interface ve400
port-name devices
ip address 10.3.0.2/16
!
! Guests VLAN
vlan 500 name guests by port
tagged ethernet 1/1/33 to 1/1/40
tagged ethernet 1/3/8
router-interface ve 500
interface ethernet 1/1/33 to 1/1/40
dual-mode 500
interface ve500
port-name guests
ip address 10.4.0.2/16
```

#### Misc
```
! Set hostname
hostname switch-01
! Enable jumbo frames on all interfaces
jumbo
write memory
end
reload
```

Port map:  
![Port map](images/switch.drawio.svg)

Firewall rules/network ACLs will be completed via later steps.

### vm-host-01.echozulu.local
iLO is configured with the following settings:  
IP: 10.0.1.128/16  
Gateway from DHCP: Enabled  
DHCP Routes: Enabled  
DNS from DHCP: Enabled  
Domain Name: echozulu.local  
DNS name: vm-host-1  
Username: Administrator  
Password: set to known value  

The host iLO interface is then connected to port 1/1/5 of the switch.

The latest version of [Proxmox](http://download.proxmox.com/iso/) is installed on the host's SSD. Filesystem is set to zfs stripe, single drive.

The management interface is set to use the second port on the added NIC. It's network configuration is:  
IP: 10.1.1.128/16  
Gateway: 10.1.0.1  
DNS server: 1.1.1.1  
Hostname: vm-host-01.echozulu.local  
The network settings will be changed in a later step. The interface is also connected to port 1/3/8 of the switch.