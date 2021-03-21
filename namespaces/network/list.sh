#!/bin/bash

ip netns list
ip link list

sudo iptables -L
sudo iptables -L -t nat
