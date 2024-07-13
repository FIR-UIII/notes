Маршрутизация между VLAN через L3 switch

Настройка
```
Switch#conf t
Switch(config)#int f0/1
Switch(config-if)#sw mode access 
Switch(config-if)#sw access vlan 2
% Access VLAN does not exist. Creating vlan 2
Switch(config-if)#exit
Switch(config)#int f0/2
Switch(config-if)#sw mode access 
Switch(config-if)#sw access vlan 3
% Access VLAN does not exist. Creating vlan 3

Назначаем vlan IP адрес (как шлюзу)
Switch(config)#int vlan 2
Switch(config-if)#ip address 192.168.1.1 255.255.255.0
Switch(config-if)#exit
Switch(config)#int vlan 3
Switch(config-if)#ip address 192.168.2.1 255.255.255.0

Включаем ip адресацию
Switch(config)#ip routing
```

Для схемы с L2+L3
Сначала настраиваем коммутаторы с конечными узлами 
```
===Switch L2===
Switch#conf t
Switch(config)#int f0/1
Switch(config-if)#sw mode access 
Switch(config-if)#sw access vlan 2
% Access VLAN does not exist. Creating vlan 2
Switch(config)#int f0/2
Switch(config-if)#sw mode access 
Switch(config-if)#sw access vlan 3
% Access VLAN does not exist. Creating vlan 3

Деламем транк порт для соединения с L3 Switch
Switch(config)#int g0/1
Switch(config-if)#sw mode trunk 
Switch(config-if)#sw trunk allowed vlan 2,3

===Switch L3===
Switch#conf t
Switch(config)#vlan 2
Switch(config-vlan)#name vlan2
Switch(config-vlan)#exit
Switch(config)#vlan 3
Switch(config-vlan)#name vlan3
Switch(config-vlan)#exit

настраиваем транк порты
Switch(config)#int g0/1
Switch(config-if)#sw trunk encapsulation dot1q 
Switch(config-if)#sw trunk allowed vlan 2,3
Switch(config-if)#exit
Switch(config)#int g0/2
Switch(config-if)#sw trunk encapsulation dot1q 
Switch(config-if)#sw trunk allowed vlan 2,3
Switch(config-if)#exit

Switch(config)#ip routing > включаем маршрутизацию на L3. Т.к. по умолчанию L3 Sw работает как обычный Sw
Switch(config)#int vlan 2
Switch(config-if)#ip address 2.2.2.1 255.255.255.0
Switch(config-if)#exit
Switch(config)#int vlan 3
Switch(config-if)#ip address 3.3.3.1 255.255.255.0
Switch#sh ip route
```

### SVI
перевести интерфейс в режим L3 (известный как «маршрутизируемый порт») и заставляет его работать больше как интерфейс маршрутизатора, а не как порт коммутатора
```
SwitchL3(config-if)#no switchport это тоже самое что и ip routing
```