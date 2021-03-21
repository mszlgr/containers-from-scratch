#!/bin/bash
# network ns - separate list of interfaces, iptable rules, routes

. ./env.sh

ip netns add $NS_1
ip netns add $NS_2
echo "1 Created netns:" $(ip netns show)

ip link add veth1h type veth peer name veth1c # create veth peer pair, 'ip link list' to get them
ip link add veth2h type veth peer name veth2c # create veth peer pair, 'ip link list' to get them
echo -e "\n2 Created veth links:" $(ip link list | tr ":" "\n" | grep veth..@)

ip link set veth1c netns $NS_1 # set veth2 into namespace con1
ip link set veth2c netns $NS_2 # set veth4 into namespace con2
echo -e "\n3 Moved vethX to namespace. Host:" $(ip link list | tr ":" "\n" | grep veth..@) \
 ", namespace 1:" $(ip netns exec $NS_1 ip link list | tr ":" "\n" | grep veth..@ ) \
 ", namespace 2:" $(ip netns exec $NS_2 ip link list | tr ":" "\n" | grep veth..@ )

ip netns exec $NS_1 ip addr add $INIP_1/24 dev veth1c
ip netns exec $NS_1 ip link set dev veth1c up
ip netns exec $NS_1 ip link set dev lo up
echo -e "\nIP for link in namespace 1 set:" $(ip netns exec $NS_1 ip -4 a | grep inet)
ip netns exec $NS_2 ip addr add $INIP_2/24 dev veth2c
ip netns exec $NS_2 ip link set dev veth2c up
ip netns exec $NS_2 ip link set dev lo up
echo -e "\nIP for link in namespace set:" $(ip netns exec $NS_2 ip -4 a | grep inet)

echo -e "\nCreating bridge"
ip link add name $BRNAME type bridge
ip link set dev veth1h master $BRNAME
ip link set dev veth2h master $BRNAME
ip addr add $BR0_IP/24 dev $BRNAME
ip link set dev $BRNAME up

ip link set dev veth1h up
ip link set dev veth2h up

echo -e "Ping host from namespace 1:" $(ip netns exec $NS_1 ping -c 1 -W 1 $HOST_IP)
echo -e "Ping host from namespace 2:" $(ip netns exec $NS_2 ping -c 1 -W 1 $HOST_IP)
echo -e "Ping namespace 1 from host:" $(ping -c 1 -W 1 $INIP_1)
echo -e "Ping namespace 2 from host:" $(ping -c 1 -W 1 $INIP_2)
echo -e "Ping namespace 2 from namespace 1:" $(ip netns exec $NS_1 ping -c 1 -W 1 $INIP_2)
echo -e "Ping namespace 1 from namespace 2:" $(ip netns exec $NS_2 ping -c 1 -W 1 $INIP_1)

echo -e "\nSetting routes..."
# those are being added with IP/24 interfaces
#ip netns exec $NS_1 ip route add 172.56.0.0/24 via $INIP_1 dev veth1c
#ip netns exec $NS_2 ip route add 172.56.0.0/24 via $INIP_2 dev veth2c
ip netns exec $NS_1 ip route add default via $BR0_IP dev veth1c
ip netns exec $NS_2 ip route add default via $BR0_IP dev veth2c
