```
Router(config)#int f0/0
Router(config-if)#no shut
Router(config-if)#ip address 192.168.1.1 255.255.255.0
Router(config-if)#exit

Router(config)#ip dhcp pool DHCP_NAME #создаем конфигурацию
Router(dhcp-config)#network 192.168.1.0 255.255.255.0 #для диапазона из какой сети будут выдаваться адреса
Router(dhcp-config)#default-router 192.168.1.1 #адрес шлюза по умолчанию для хостов
Router(dhcp-config)#dns-server 8.8.8.8 #адрес dns сервера
Router(dhcp-config)#exit

Router(config)#ip dhcp excluded-address 192.168.1.100 # исклюение из выдачи адресов. например этот ip будет выдан в ручную для сервера
Router(config)#ip dhcp excluded-address 192.168.1.1 # исключаем свой адрес
Router(config)#exit

ПРОВЕРЯЕМ КАКИЕ IP АДРЕСА БЫЛИ НАЗНАЧЕНЫ (НА ХОСТАХ НУЖНО ВКЛЮЧИТЬ DHCP)
Router#sh ip dhcp binding
Hardware address
192.168.1.2 0060.5CA5.A3E5 -- Automatic
192.168.1.3 0004.9AAC.2869 -- Automatic
192.168.1.4 0001.435B.4736 -- Automatic
```

Для сети
![[Pasted image 20231021172557.png]]

На роутере
```
R1(config)#int g0/1
R1(config-if)#no shut
R1(config)#int g0/1.2
R1(config-subif)#encapsulation dot1Q 2
R1(config-subif)#ip address 192.168.2.1 255.255.255.0
R1(config-subif)#ip helper-address 192.168.4.2 >>> указываем на DHCP сервер
R1(config-subif)#no shut
R1(config-subif)#exit
R1(config)#int g0/1.3
R1(config-subif)#encapsulation dot1Q 3
R1(config-subif)#ip address 192.168.3.1 255.255.255.0
R1(config-subif)#ip helper-address 192.168.4.2 >>> указываем на DHCP сервер
R1(config-subif)#no shut
R1(config-subif)#exit
R1(config)#int g0/1.4
R1(config-subif)#encapsulation dot1Q 4
R1(config-subif)#ip address 192.168.4.1 255.255.255.0
R1(config-subif)#no shut
R1(config-subif)#end
```
На выделенном сервере DHCP из отдельного vlan_4
![[Pasted image 20231021171729.png]]