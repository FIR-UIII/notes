![[Pasted image 20231010135832.png]]
#### LLA - link local address
Устройство назначает себе само при включении, для общения в локальной сети
DAD - механизм обнаружения дулей LLA через запрос ICMPv6
ND (Neighbor Discovery) - механизм обнаружения соседей через запрос ICMPv6 (замена ARP)

#### GUA global unicast address
- Через гос.провайдера: /48 (2^80 адресов)
- От частного провайдера: зависит от цены
![[Pasted image 20231010140021.png]]
#### SLAAC (замена DHCP)
Способ получения адреса от маршрутизатора. При этом узлы не отправляют обратно информацию о том, какой адрес они себе назначили, а только проводят расчет GUA по высланной информации от маршрутизатора.

```
Netword address - 2001:db8:acad:1
===========ROUTER==========
R1#conf t
R1(config)#int f0/0
R1(config-if)#ipv6 address fe80::1 link-local # LLA
R1(config-if)#ipv6 address 2001:db8:acad:1::1/64 # GUA
R1(config-if)#exit
R1(config)#ipv6 unicast-routing # включаем адресацию ipv6 (RA-RS)

===========SWITCH==========
SW1#conf t
SW1(config)#int f0/0
SW1(config-if)#ipv6 enable # включаем IPv6
SW1(config-if)#no shut # назначится LLA
SW1(config-if)#do show ipv6 int f0/0 # проверим
SW1(config-if)#ipv6 address autoconfig default # отправляем Router Solicitation запрос ICMPv6 и получаем от R1 адрес GUA

```

Router Solicitation -
	когда -  при включении в сеть
	кто - любой хост
	куда - на групповой мультикаст ff02::2 (все маршрутизаторы)
	зачем - получить адрес ipv6 (gua) от маршрутизатора

Router Advertisement -
	когда -  1 раз в 200 сек
	кто - маршрутизатор
	куда - на групповой мультикаст ff02::1 (все узлы)
	зачем - сообщить всем узлам в сети, как им следует получить глобальный одноадресный IPv6-адрес и о инфу локальном маршрутизаторе и его способности быть шлюзом по умолчанию.