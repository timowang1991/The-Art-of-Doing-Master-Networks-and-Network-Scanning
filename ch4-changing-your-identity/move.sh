#!/bin/bash

# Randomize your mac and ip address for a given subnet with a netmask of 255.255.255.0 or /24
# Changing a MAC is not supported on eth0 in virtualbox, use wifi adapter only for mac changing

device=$1

# Change MAC Address only if not eth0
if [ "$device" != eth0 ]; then
    sudo ip link set "$device" down
    sudo macchanger -a "$device"
    sudo ip link set "$device" up
fi

# Get current IP information
old_ip=$(ip addr show "$device" | grep "inet" -w -m 1 | awk -F" " '{ print $2 }')
gateway_ip=$(echo "$old_ip" | awk -F"." '{ print $1"."$2"."$3".1" }')
network_id=$(echo "$gateway_ip" | awk -F"." '{ print $1"."$2"."$3"." }')
octet=$(( ($RANDOM % 252) + 2 ))
new_ip="$network_id$octet"'/24'

echo $old_ip
echo $gateway_ip
echo $network_id
echo $octet
echo $new_ip

# change ip address
sudo ip addr del "$old_ip" dev "$device"
sudo ip addr add "$new_ip" dev "$device"
sudo ip route add default via "$gateway_ip"

echo "New MAC: $(ip link show $device | grep link | awk -F" " ' { print $2 } ')"
echo "New IP: $(ip addr show $device | grep inet -w -m 1 | awk -F" " '{ print $2}')"