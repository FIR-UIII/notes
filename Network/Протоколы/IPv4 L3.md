```
SW1#conf t
SW1(config)#int vlan 100
SW1(config-if)#name TELNET
SW1(config-if)#ip address 192.168.0.1 255.255.255.0
SW1(config-if)#no shut
%LINK-5-CHANGED: Interface Vlan100, changed state to up
```
