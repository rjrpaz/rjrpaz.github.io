---
layout: post
title: "Using netaddr library to manage ip addresses in python3"
date: 2021-12-23 00:00:00 -0000
categories: python netaddr
---
Using netaddr library to manage ip addresses in python3

*netaddr* is a very handy lib to do ip address manipulation in python. Home for this project here: [https://pypi.org/project/netaddr/](https://pypi.org/project/netaddr/)

A sample scenario to use this library is to use it as a very basic IP calculator.

For example, you can provide an IP address in CIDR format and you can get all related IP entities.

```python3
#!/usr/bin/env python3
import sys
import re
from netaddr import IPNetwork, IPAddress
import socket
import struct

'''
This sample code uses netaddr lib to do very basic ip calculation starting from an IP address.

This code assumes the gateway address is the first valid IP address from the network.
'''

if len(sys.argv) != 2:
    print("Usage:\n\t%s cidr\n\nEx:\n\t%s 192.168.1.112/24" % (sys.argv[0], sys.argv[0]))
    exit(0)

address = str(sys.argv[1])

p = re.compile('^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+\/([0-9]+)$')

result = p.search(address)
netmask = result.group(1)

if int(netmask) > 32:
    print("Netmask %s is not valid" % netmask)
    exit(1)

ip = IPNetwork(address)

print ("IP address: %s" % ip.ip)
print ("Netmask:    %s" % ip.netmask)
print ("Network:    %s" % ip.network)
print ("Broadcast:  %s" % ip.broadcast)
gateway = IPAddress(int(ip.network) + 1)
print ("Gateway:    %s" % gateway)

exit(0)
```

Sample runs:

```console
roberto@notebook:~$./netInfo.py 192.168.1.140/25
IP address: 192.168.1.140
Netmask:    255.255.255.128
Network:    192.168.1.128
Broadcast:  192.168.1.255
Gateway:    192.168.1.129
roberto@notebook:~$
```

```console
roberto@notebook:~$./netInfo.py 10.0.2.7/8
IP address: 10.0.2.7
Netmask:    255.0.0.0
Network:    10.0.0.0
Broadcast:  10.255.255.255
Gateway:    10.0.0.1
roberto@notebook:~$
```
