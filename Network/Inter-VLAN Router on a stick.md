## Роутер на палочке / Router on a stick
До 50 VLAN, используется 1 канал для нескольких VLANов > не отказоустойчивое решение, производительность от CPU роутера.
Создает возможность обмена данными между ПК из разных VLAN
```
Router#conf t
Router(config)#int f0/0
Router(config-if)#no shutdown
Router(config-if)#exit
Приземляем VLAN назначаем IP через саб интерфейс
Router(config)#int fastEthernet 0/0.2
%LINK-5-CHANGED: Interface FastEthernet0/0.2, changed state to up
%LINEPROTO-5-UPDOWN: Line protocol on Interface FastEthernet0/0.2, changed state to up
Router(config-subif)#encapsulation dot1Q 2
Router(config-subif)#ip address 192.168.2.1 255.255.255.0
Router(config-subif)#no shut
Router(config-subif)#exit
```
![[Pasted image 20231028120913.png]]
 
 
| Функция | Маршрутизатор | Коммутатор |
|---------|---------------|------------|
| Скорость|Медленнее      |Быстрее     |
|Способ обработки пакетов|CPU программный|ASIC аппаратный или FPGA|
| OSI     | Уровень 3     | Уровень 2  |
|Используемая адресация| IP |MAC|
|Широковещательные рассылки| Блокируются |Пропускаются|
|Безопасность |Выше| Ниже|
|Сегментация сетей |Сегментирует сеть на широковещательные домены| Сегментирует сеть на домены коллизий|
|Технологии|VPN, NAT, IDS|VLAN|

Используемые протоколы маршрутизации L3-L2 IP - ключевой протокол. 
Все протоколы делятся на

|Interior Gateway Protocol — IGP|Exterior Gateway Protocols — EGP|
|-------------------------------|--------------------------------|
|внутри одной Autonomous System — AS|Между AS|
|RIP, RIP V2, IGRP, EIGRP, OSPF, IS-IS|BGP|

    HDLC - протокол инкапсуляции
    Frame Relay -  Представляет собой промышленный стандарт коммутируемого протокола канального уровня, который управляет множеством виртуальных каналов
    Point-to-point protocol (PPP) - беспечивает соединения маршрутизатор-маршрутизатор и узел-сеть через синхронные и асинхронные линии. См. RFC 1661
    HDLC (бывш. SDLC) -  Протокол распределенных сетей канального уровня
    SLIP - межсетевой протокол для последовательного канала (аналог PPP)
    LAPB 
    LAPD
    LAPF 
    LAPB
