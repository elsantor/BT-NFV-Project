# BT-NFV-Project

Initial Credentials 
Login: admin
Password: password

Use the wizard to configure
# everything inside the brackets is the default value
step 1: Hostname[amnesiac]
step 2: Use DHCP on pri interface? [yes] no
step 3: Primary IP address? 192.168.0.9 #this is the IP given to MGMT by CloudStack
step 4: Netmask? [0.0.0.0] 255.255.255.0
step 5: Default Gateway? 192.168.0.1
step 6: Primary DNS Server? 172.25.8.20 #one of the DNS servers in Cloudstack
step 7: Domain name? amnesiac.com
step 8: Admin password:amnesiac
step 9: SMTP server? []
step 10: Notification email address? 
step 11: set the primary interface speed? [auto]
step 12: set the primary interface duplex? [auto]
step 13: Would you like to activate the in-path configuration? [no] yes
step 14: in-path IP address: 10.1.1.138 #The IP address of WAN interface by Cloudstack
step 15: in-path default gateway: 10.1.1.1
step 16: set the LAN interface speed?
step 17: set the LAN interface duplex?
step 18: set the WAN interface speed?
step 19: set the WAN interface duplex?

# https://support.riverbed.com/bin/support/static/93kli6tqn0ba7e2jgml3kq1u18/html/lgt7cniu50bti6qdc3drn177ql/sh_9.1_dg_html/index.html#page/sh_9.1_dg%2Fphys_inpath_designs.11.04.html%23

# Connect to the SteelHead CLI and enter the following commands:
enable
configure terminal #(or conf t)
interface inpath0_0 ip address 10.1.1.138 #to change the IP address of inpath0_0
show interfaces #only PRI and inpath0_0 should have IP addr
ping -I inpath0_0 inpath0_0_gateway
ping -I PRI PRI_gateway #to verify SH is up
write memory  #to save all changes before restarting

# https://support.riverbed.com/bin/support/static/93kli6tqn0ba7e2jgml3kq1u18/html/lgt7cniu50bti6qdc3drn177ql/sh_9.1_dg_html/index.html#page/sh_9.1_dg%2Fnetwork_integration.04.5.html%23wwconnect_header 



login: admin
password: amnesiac

############################

# To verify the packets pass through the Steelhead we deploy a CentOSHost with LAN interface as its default interface. 

# Then we connect to its console to set the network up. 

# Configure eth0

vi /etc/sysconfig/network-scripts/ifcfg-eth0

DEVICE=eth0
NM_CONTROLLED=yes
ONBOOT=yes
HWADDR=xx:xx:xx:xx:xx
TYPE=Ethernet
BOOTPROTO:static
IPADDR=xx.xx.xx.xx 
NETMASK=255.255.255.0

# Configure the default gateway

vi /etc/sysconfig/network

NETWORKING=yes
HOSTNAME=localhost
GATEWAY=10.1.1.1

#Restart Network Interface

/etc/init.d/network restart

# Configure DNS Server

vi /etc/resolv.conf

nameserver=172.25.8.20

############################

# Ping the default gateway while the Steelhead is up, and while is down and see what happens.
