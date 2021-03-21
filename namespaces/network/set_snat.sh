#!/bin/bash -e

. ./env.sh

echo 1 > /proc/sys/net/ipv4/ip_forward
echo "/proc/sys/net/ipv4/ip_forward:" $(cat /proc/sys/net/ipv4/ip_forward)

iptables -A FORWARD -i $BRNAME -o $HOSTIFNAME -s 172.56.0.0/24 -j ACCEPT
iptables -A FORWARD -i $HOSTIFNAME  -o $BRNAME -d 172.56.0.0/24 -j ACCEPT
iptables -t nat -A POSTROUTING -o $HOSTIFNAME -s 172.56.0.0/24 -j SNAT --to-source $HOST_IP

echo "ping $EXTERNAL_IP from $NS_1:"
ip netns exec $NS_1 ping -c 1 -W 1 $EXTERNAL_IP
echo "ping $EXTERNAL_IP from $NS_2:"
ip netns exec $NS_2 ping -c 1 -W 1 $EXTERNAL_IP

