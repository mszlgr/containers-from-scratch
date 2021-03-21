#!/bin/bash

# namespaces names
NS_1='con1'
NS_2='con2'
# bridge interface name
BRNAME='br0'
# host interface name
HOSTIFNAME='enp0s3'


# namespaces IPs
INIP_1='172.56.0.1'
INIP_2='172.56.0.2'
# bridge interface address
BR0_IP='172.56.0.100'

# host IP to test ping from namespaces
HOST_IP='192.168.0.81'

# external IP to test ping after adding SNAT
EXTERNAL_IP='8.8.8.8'
