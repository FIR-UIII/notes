[[#Устранение ошибок с VLAN]]

![[Pasted image 20231109131433.png]]
Работает на L2 уровне. 
VLAN - виртуальная логическая сеть
1 VLAN = 1 IP Subnet подсеть (192.168.|2|.1). Важно сохранять при сегментировании
1 VLAN - это 1 широковещательный домен

native VLAN > VLAN в котором нет тегированных кадров
default VLAN 1 > стандартный из которого нужно убрать все порты в мусорный
Parking Lot/Trash VLAN > перевести в него все порты
Management VLAN > для управления с отдельной подсетью
Data VLAN > подсеть с тегированным номером VLAN
Voice VLAN > для ip телефонии тегированный но для IP телефонии
### Access port - подключение конечных устройств в одном vlan
У других производителей может называться untagged. Т.к. устройства в одной сети и не знают что есть другие сегменты
```
Switch#conf t
Switch(config)#vlan 2
Switch(config-vlan)#name buh
Switch(config-vlan)#exit
# назначаем интерфейсы во vlan 2
Switch(config)#int range f0/2, f0/4
Switch(config-if-range)#sw mode access # определяем режим на интерфесы
Switch(config-if-range)#sw access vlan 2 # назначаем

ПРОВЕРИТЬ
Switch#show vlan br
VLAN Name Status Ports
   2 buh  active Fa0/2, Fa0/4
Switch#sh int <interface-ID> switchport
```
### Trunk port 
Соединение 2+ коммутаторов/роутеров между собой
У других производителей может называться  tagged. Т.к. в пакет добавляется тег с обозначением от какого сегмента этот пакет.
```
SW1#conf t
SW1(config)#int g0/1
SW1(config-if)#sw mode trunk #порт в тракт режим - тегированный
SW1(config-if)#sw trunk allowed vlan 2,3 # разрешаем пропускать трафик между устр-вами из vlan 2,3

SW2#conf t
SW2(config)#int g0/1
SW2(config-if)#sw mode trunk
SW2(config-if)#sw trunk allowed vlan 2,3 # должно быть аналогично SW1

ПРОВЕРИТЬ
Switch#sh int trunk
Switch#show interfaces g0/1 switchport
	Switchport: Enabled 
	Administrative Mode: trunk #заданное админом состояние порта
	Operational Mode: trunk #фактическое состояние порта
	Administrative Trunking Encapsulation: dot1q 
	Operational Trunking Encapsulation: dot1q 
	Negotiation of Trunking: On 
	Trunking VLANs Enabled: 2,3 # разрешенные VLAN
```

### native VLAN
Установите в качестве VLAN с нетегированным трафиком сеть, отличную от VLAN 1.
это понятие в стандарте [802.1Q](http://xgu.ru/wiki/802.1Q "802.1Q"), которое обозначает [VLAN](http://xgu.ru/wiki/VLAN "VLAN") на коммутаторе, где все кадры идут без тэга. По умолчанию это VLAN 1. Если коммутатор получает нетегированные кадры на транковом порту, он автоматически причисляет их к Native VLAN. И точно так же кадры, генерируемые с не распределенных портов, при попадании в транк-порт причисляются к Native VLAN.

```
Switch(config-if)#switchport trunk native vlan <vlan-id>

ПРОВЕРИТЬ
Switch#show interfaces g0/1 switchport
	Trunking Native Mode VLAN: 99 (VLAN0099) > NATIVE VLAN

Если по Native VALN есть роутер - то
R1(config-subif)#int g0/0/1.1000
R1(config-subif)#encapsulation dot1Q 1000 native
```

### DTP
```
dymanic auto < passive
dymanic desirable < active
ЗАДАЕМ РЕЖИМ
SW1(config-if)#switchport nonegotiate > отключить DTP
SW1(config-if)#switchport mode dynamic auto > стантартный режим (по умолчанию)
SW1(config-if)#switchport mode dynamic desirable > активный режим - достучись до соседа и передай команду 

ПРОВЕРЯЕМ
show interfaces <f/0/0> switchport
```
	![[Pasted image 20231028110414.png]]
**Administrative Mode**. Эта строка показывает, в каком из 4-режимов работает данный порт на коммутаторе
**Operational Mode** показывает, в каком режиме работы фактически работает коммутатор
##### VLAN hopping 
Атака возможная на протокол DTP
### Extended VLANs
Для конфигурирования Vlan 1006-4096 необходимы выполнить команду
```
Sw1(config)#vtp mode transparent
Setting device to VTP TRANSPARENT mode.
ДАЛЕЕ как в п. Access port - подключение конечных устройств в одном vlan
```
### Parking Lot/Trash
Мусорный VLAN. Любой VLAN в котором ничего нет. 
### VTP
Устаревший. Магистральный протокол VTP упрощает администрирование VLAN в коммутируемой сети. Когда вы настраиваете новую VLAN на одном VTP-сервере, VLAN распределяется по всем коммутаторам домена. Это уменьшает необходимость настройки везде одной и той же VLAN. VTP — это собственный протокол Cisco, доступный в большинстве продуктов серии Cisco Catalyst.

## Quality of Service / QoS VLAN Priority
Определение качества (маркировки и важности) для разных данных передаваемых по VLAN для определения приоритетов при передачи данных через полосу пропускания канала
https://www.cisco.com/c/en/us/td/docs/switches/datacenter/nexus5000/sw/qos/521_n1_1/b_5k_QoS_Config_521N11/b_5k_QoS_Config_521N11_chapter_01000.pdf 

## Устранение ошибок с VLAN
1. Отсутствующие сети VLAN. На одном из коммутаторов нет / удален VLAN. 
```
S1# show vlan brief
S1(config)# do show interface fa0/6 switchport
	Access Mode VLAN: 10 (Inactive) > нужно исправить и переназначить
```

2. Проблемы магистрального порта коммутатора. Нужно делать резервирование магистральных каналов
```
Проверить, что порт fa0/1 подключаемый к роутеру настроен в качестве магистрального канала
S1#show interfaces trunk
	Port  Mode Encapsulation Status   Native vlan 
	Fa0/1 on   802.1q        trunking 1 > порт до роутера
	Fa0/5 on   802.1q        trunking 1 > порт до другого коммутатора
S1# show running-config | include interface fa0/5
	interface FastEthernet0/5 
	description Trunk link to R1 
	switchport mode trunk 
	shutdown > порт выключен
```

3. Неполадки в работе порта коммутатора
```
S1#show interface fa0/6 switchport
	Building configuration... 
	Current configuration : 87 bytes ! 
	interface FastEthernet0/6 
	description PC-A access port 
	switchport mode access >> если нет информации о VLAN значит нужно добавить
S1#show running-config interface fa0/6
	Name: Fa0/6 
	Switchport: Enabled 
	Administrative Mode: static access > Порт Fa0/6 настроен как порт доступа
	Operational Mode: static access > и фактически работает
	Administrative Trunking Encapsulation: dot1q 
	Operational Trunking Encapsulation: native 
	Negotiation of Trunking: Off 
	Access Mode VLAN: 10 (VLAN0010) > VLAN назначен верно
	Trunking Native Mode VLAN: 1 (default) 
	Administrative Native VLAN tagging: enabled
	Trunking VLANs Enabled: 10 > проверить какие разрешены VLAN к передаче
	Voice VLAN: none
```

4. Неполадки в настройках маршрутизатора
```
R1#show ip int brief > проверить адреса IPv4, и их статус up
R1#show int | include Gig|802.1Q > проверить какие VLAN включены. будут отображаться только строки, содержащие буквы «Gig» или «802.1Q»
	GigabitEthernet0/0/1.10 is up, line protocol is up 
	Encapsulation 802.1Q Virtual LAN, Vlan ID 100. > Обратите внимание, что интерфейс G0/0/1.10 неправильно назначен VLAN 100 вместо VLAN 10.
R1#show ip int <ID> sw > проверить состояние порта доступа
```

5. Проверить хосты
```
PC1#ipconfig > адрес, маска, шлюз по умолчанию, DNS
```