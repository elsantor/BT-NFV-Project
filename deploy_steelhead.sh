#!/bin/bash
# Christian Lafferty, BT Future Business Technology Research
# Helen Santorinaiou
# deploy_steelhead.sh 13/10/2015
# An script to illustrate how to deploy a virtual Riverbed SteelHead
# into a CloudStack Service Chain.

cm=cloudmonkey

echo "- Targeting Alpha Platform -"
#$cm set profile beta
zone='zone1'
netnat='DefaultIsolatedNetworkOfferingWithSourceNatService'
netnot='IsolatedNetworkOfferingWithNoServices'
template='Steelhead VCX'
vmoff='SteelheadV250L'
disko='SteelheadV250L'
ipip='10.1.1.100'
ipgw='10.1.1.1'

$cm set display default

zoneid=`$cm list zones name=$zone | grep ^id | awk '{print $3}'`
echo "Zone ID" $zoneid

# The default isolated network service offering
netServ=`$cm list networkofferings name=$netnat | grep ^id | awk '{print $3}'`
echo "Default isolated network offerings" $netServ

# This network service offering suppresses the virtual router
netNoServ=`$cm list networkofferings name=$netnot | grep ^id | awk '{print $3}'`
echo "No services isolated network offering" $netNoServ

#templateid=`$cm list templates templatefilter=executable name=$template filter=id | grep ^id | awk '{print $3}'`
templateid='8447cda2-264f-4160-b088-ecf0c5810571'
echo "Template ID" $templateid

compute=`$cm list serviceofferings name=$vmoff filter=id | grep ^id | awk '{print $3}'`
echo "Service offering ID" $compute

disk=`$cm list diskofferings name=$disko filter=id  | grep ^id | awk '{print $3}'`
echo "Data disk offering ID" $disk

#    *** NETWORKING ***
# --- Create a management network ---
netMgmt=`$cm list networks filter=name,id keyword=MGMT| grep ^id | awk '{print $3}'`
if [ -z $netMgmt ]; then
  echo "Creating management network:"
  netMgmt=`$cm create network \
    zoneid=$zoneid \
    name=MGMT displaytext=Management \
    networkofferingid=$netServ \
    gateway=192.168.0.1 netmask=255.255.255.0 \
	| grep ^id | awk '{print $3}'`
fi
echo "Management network ID" $netMgmt    

# --- Create an auxiliary network ---
# This is a holding network for an unused interface
netAux=`$cm list networks filter=name,id keyword=AUX | grep ^id | awk '{print $3}'`
if [ -z $netAux ]; then
  echo "Creating auxiliary network:"
  netAux=`$cm create network \
	zoneid=$zoneid \
  	name=AUX displaytext=Auxiliary \
  	networkofferingid=$netNoServ \
  	gateway=192.168.1.1 netmask=255.255.255.0 \
	  	| grep ^id | awk '{print $3}'`
fi
echo "Auxiliary network ID" $netAux        

# --- Create a LAN network ---
netLan=`$cm list networks filter=name,id keyword=LAN | grep ^id | awk '{print $3}'`
if [ -z $netLan ]; then
  echo "Creating LAN network:"
  netLan=`$cm create network \
    zoneid=$zoneid \
    name=LAN displaytext=LAN \
    networkofferingid=$netNoServ \
    gateway=10.1.1.1 netmask=255.255.255.0 \
      | grep ^id | awk '{print $3}'`
fi    
echo "LAN network ID" $netLan   

# --- Create a WAN network ---
netWan=`$cm list networks filter=name,id keyword=WAN | grep ^id | awk '{print $3}'`
if [ -z $netWan ]; then
  echo "Creating WAN network:"
  netWan=`$cm create network \
    zoneid=$zoneid \
    name=WAN displaytext=WAN \
    networkofferingid=$netServ \
    gateway=$ipgw netmask=255.255.255.0 \
      | grep ^id | awk '{print $3}'`
fi
echo "WAN network ID" $netWan

#    *** END OF NETWORKING ***

# Create virtual Steelhead
# The interface order is important; 0=Pri, 1=Sec, 2=LAN, 3=WAN

echo
echo "Deploying Riverbed SteelHead-V"
ret=`$cm deploy virtualmachine \
  name=SteelheadTest displayname=Virtual\ SteelheadV2 \
  zoneid=$zoneid \
  templateid=$templateid \
  serviceofferingid=$compute \
  diskofferingid=$disk \
  iptonetworklist[0].networkid=$netMgmt \
  iptonetworklist[1].networkid=$netAux iptonetworklist[1].ip=192.168.1.100 \
  iptonetworklist[2].networkid=$netLan iptonetworklist[2].ip=$ipip \
  iptonetworklist[3].networkid=$netWan`

vmid=`$cm list virtualmachines name=Steelhead filter=id | grep ^id | awk '{print $3}'`

echo  
if [[ -n $vmid ]]; then
  echo "SteelHead-V deployed successfully"
  echo "VM ID =" $vmid
else
  echo "SteelHead-V failed to deploy"
  echo $ret
fi
