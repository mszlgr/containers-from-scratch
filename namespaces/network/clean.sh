#!/bin/bash -e

. ./env.sh

TS=$(date +%s)

iptables --flush
iptables --flush -t nat

ip netns list > /tmp/netns_list_before_$TS
ip link list > /tmp/link_list_before_$TS

sudo ip netns del $NS_1
sudo ip netns del $NS_2
sudo ip link del $BRNAME

ip netns list > /tmp/netns_list_after_$TS
ip link list > /tmp/link_list_after_$TS

diff /tmp/netns_list_before_$TS /tmp/netns_list_after_$TS || true
diff /tmp/link_list_before_$TS /tmp/link_list_after_$TS || true
