https://selectel.ru/blog/ospf/
### Основные термины
Оценивает стоимость пропускной способности (FastEth,Gig,Serial,Eth), состояние порта. Расчет идет от эталонной пропускной способности
	Что используется для создания таблицы соседних устройств протокола OSPF - БД смежности
	Что идентично для всех маршрутизаторов OSPF в пределах одной области - БД состояния каналов

Роли
	**Designated Router (DR)**  корневой выделенный маршрутизатор управляет рассылкой LSA. Отправка сообщений LSA от каждого устройства к каждому обязательно забьет каналы. Чтобы этого не произошло, отправкой сообщений заведует DR
	**Backup Designated Router (BDR)** — резервный выделенный маршрутизатор
	**Backbone Router** - магистральный центральный маршрутизатор
	**ABR** - пограничный маршрутизатор на стыке зон
	**ASBR** - маршрутизатор на стыке зон внешней и внутренней

**LSA** - пакеты содержащие информацию о состоянии интерфейсов других роутеров. Маршрутизаторы синхронизируют общую базу LSDB, где хранят LSA.
###### Зоны (области)
**Магистральная** Area 0, Backbone-area, зона 0.0.0.0. - это ядро сети OSPF. Все остальные зоны подключаются к ней. Все пакеты от любой ненулевой зоны в другую ненулевую проходят через магистральную. Магистральный маршрутизатор — **Backbone Router**
**Стандартная** - Это область без определенной цели.
**Транзитная** - Зона, которая используется для передачи сетевого трафика из одной смежной области в другую
**NSSA (Not-so-stubby area)** - область, которая может инжектировать внешние маршруты сообщений в систему с помощью специального типа LSA и отправлять их в другие области. Но зона не может получать внешние маршруты из других областей. Для передачи данных в этой зоне используется маршрутизатор **ASBR**
**Тупикова зона (stub area)**. Эта зоне не принимает информацию о внешних маршрутах для автономной системы, но принимает маршруты из других зон. В тупиковой зоне не может находиться ASBR

### Типы пакетов OSPF и как работает
Транспорт - IP пакет.

|Название пакета| Что включаем в себя|
|-------------------|----------------|
|Пакет приветствия (hello)|Установление и поддержание смежности с другими маршрутизаторами. Содержит в себе: Authorization/password, RouterID, AreaID, Hello and Dead interval, DR, BDR, list of Neighbors|
|DBD пакет описания базы данных|содержит сокращённый список базы данных состояний каналов отправляющего маршрутизатора. Используется принимающими маршрутизаторами для сверки с локальной базой данных о состоянии канала.|
|LSR (request) запрос доп. информации|принимающие маршрутизаторы могут запросить дополнительные данные о любой записи в пакете описания базы данных (DBD), отправив пакет запроса состояния канала (LSR)|
|LSU (update) пакет обновления состояния канала|Содержат пакеты LSA. используется для отправки отклика на пакеты запроса состояния канала (LSR) и объявления новых данных.|
|LSAck пакет подтверждения состояния канала (аналог TCP)|Подтверждает успешный прием сообщения|

Как работает технология:
- установить отношения смежности с соседними узлами;
- осуществить обмен данными маршрутизации;
- рассчитать оптимальные маршруты;
- достичь состояния сходимости.

R1 ------------ R2 
Состояние Down
Hello------------> # привет, я R1 кто нибудь работает по OSPFv2. Переход в состояние Init
<------------Hello # привет я R2, работаю по OSPFv2. Переход в состояние Two-Way, где выбирается DR и BDR.
Переход в состояние ExStart - два маршрутизатора определяют, какой маршрутизатор будет инициировать обмен пакетами DBD по наибольшему Router ID
DBD-------------> # отлично вот что у меня есть вкратце в БД. Состояние Exchange
<------------LSAck # спасибо получил
<-------------DBD # а вот что у меня есть в БД
LSAck-----------> # спасибо получил
LSR--------------> # мне нужно больше информации. Состояние Loading
<--------------LSU  # вот держи
LSAck----------->  # спасибо, получил!
Состояние Full, маршрутизаторы имеют конвергентные базы данных и далее могут обмениваться обновлениями маршрутизации
### Проектирование OSPF

1. Определит кол-во областей
2. Определить Router ID, Hello and Dead timing, auto-cost ref
3. Определить DR, BDR
	1. DR - маршрутизатор с самым высоким Router ID
	2. BDR - маршрутизатор со 2-м высоким Router ID
##### Суммирование сетей для настройки OSPF
Если на роутере есть несколько интерфейсов с ip:
	10.1.12.0 / 29
	10.1.13.0 / 29
	10.1.2.0 / 24
То вместо прописывания network 10.1.12.0 0.0.0.255 area 0 для каждой из 3 сетей, можно объединить (суммировать) в одну команду с адресом 10.1.0.0 / 16 и обратной маской 0.0.255.255
#### Стоимость маршрута
Расчет 
```
# Способ 1 через назначение пропускной способности bandwidth
R2(config)#router ospf 1
R2(config-router)#auto-cost ref 1000
% OSPF: Reference bandwidth is changed.
Please ensure reference bandwidth is consistent across all routers.

# Способ 2 через назначение стоимости вручную (более удобный)
R2(config)#int f0/0
R2(config-if)#ip ospf cost <VALUE>

БЫЛО
R2(config-router)#do sh ip route ospf
10.0.0.0/8 is variably subnetted, 10 subnets, 3 masks
O 10.1.1.0 [110/65] via 10.1.12.1, 00:00:09, Serial0/0/0
O 10.1.13.0 [110/128] via 10.1.12.1, 00:00:09, Serial0/0/0

СТАЛО
R2(config-router)#do sh ip route ospf
10.0.0.0/8 is variably subnetted, 10 subnets, 3 masks
O 10.1.1.0 [110/648] via 10.1.12.1, 00:00:48, Serial0/0/0
O 10.1.13.0 [110/711] via 10.1.12.1, 00:00:48, Serial0/0/0
```
### Базовая настройка OSPFv2 для одной области

```
R1#conf t
R1(config)#router ospf 1 # process-id не обязательно должно совпадать со значением на других маршрутизаторах OSPF. Используется для CPU маршрутизатора
R2(config-router)#router-id 1.1.1.1 # назначаем ID
R2(config-router)#passive-interface g0/0 # защита от router poisoning см. ниже
R1(config-router)#network 10.1.1.0 0.0.0.255 area 0

R2#conf t
R1(config)#router ospf 1
R2(config-router)#router-id 2.2.2.2
R2(config-router)#passive-interface g0/0
R2(config-router)#network 10.1.0.0 0.0.255.255 area 0
01:07:54: %OSPF-5-ADJCHG: Process 1, Nbr 1.1.1.1 on Serial0/0/0 from LOADING to FULL, Loading Done > означает что ospf работает и роутер обнаружил соседа 1.1.1.1

ПРОВЕРКА
R2(config-router)#do sh ip ospf neighbor
	Neighbor ID Pri State Dead Time Address Interface
	1.1.1.1  0  FULL/ - 00:00:33 10.1.12.1 Serial0/0/0

R2(config-router)#do sh ip route
	10.0.0.0/8 is variably subnetted, 10 subnets, 3 masks
	O 10.1.1.0/24 [110/65] via 10.1.12.1, 00:04:57, Serial0/0/0
	O 10.1.13.0/29 [110/128] via 10.1.12.1, 00:04:57, Serial0/0/0

R2(config-router)#do show ip ospf database
```

### Базовая настройка для нескольких областей

### Проверка работы OSPF
Должны быть обеспечены условия для штатной работы на роутерах:
1. Уникальный Router ID
2. Одинаковый тип аутентификации (`0` - без пароля, `1` - с паролем в отрытом виде, `2` - с паролем в закрытом хеш-виде)
3. Данные аутентификации (если есть пароль - то они должны совпадать)
4. Сеть и маска правильно указаны с `sh ip int br`
5. Номер области area одинаковый
6. Одинаковый тип области (Backbone, Normal, Stub, Totally Stub, NSSA, Totally NSSA)
7. Одинаковый тип сети (Broadcast, Mutliaccess, P2P)
8. Одинаковые таймеры dead и hello
9. Одинаковая эталонная пропускная способность

https://www.ccexpert.us/autonomous-system/the-show-ip-protocols-command.html
https://www.cisco.com/E-Learning/bulk/public/tac/cim/cib/using_cisco_ios_software/cmdrefs/show_ip_protocols.htm

```
R1(config-router)#do sh ip proto
	Routing Protocol is "ospf 1"
	Outgoing update filter list for all interfaces is not set
	Incoming update filter list for all interfaces is not set
	Router ID 10.1.13.1
	Number of areas in this router is 1. 1 normal 0 stub 0 nssa
	Maximum path: 4
	Routing for Networks:
	10.1.1.0 0.0.0.255 area 0
	10.1.12.0 0.0.0.7 area 0
	10.1.13.0 0.0.0.7 area 0
	Routing Information Sources:
	Gateway Distance Last Update
	10.1.13.1 110 00:00:25
	Distance: (default is 110)

R1(config-router)#do sh ip ospf int
  GigabitEthernet0/0 is up, line protocol is up
	Internet address is 10.1.1.1/24, Area 0
	Process ID 1, Router ID 1.1.1.1, Network Type BROADCAST, Cost: 1
	Transmit Delay is 1 sec, State WAITING, Priority 1
	No designated router on this network
	No backup designated router on this network
	Timer intervals configured, Hello 10, Dead 40, Wait 40, Retransmit 5
	No Hellos (Passive interface)
	Index 1/1, flood queue length 0
	Next 0x0(0)/0x0(0)
	Last flood scan length is 1, maximum is 1
	Last flood scan time is 0 msec, maximum is 0 msec
	Neighbor Count is 0, Adjacent neighbor count is 0
	Suppress hello for 0 neighbor(s)
```

#### Смена router ID
```
R1(config-router)#router-id 1.1.1.1
R1(config-router)#Reload or use "clear ip ospf process" command, for this to take effect
R1(config-router)#do clear ip ospf process > перезапуск процесс. Настройки не сбрасываются. Но применяются ранее введенные команды, которые не были запущены.
Reset ALL OSPF processes? [no]: yes
R1(config-router)#do sh ip proto
	...
	Router ID 1.1.1.1
```
### Route poisoning
OSPF - закрыть пакеты Hello в конечные узлы, где нет роутеров. Разведка и компрометация (MITM) сети, перестройка траффика. Данный интерфейс нужно делать пассивными.
```
R1(config-router)#passive-interface g0/0
R1(config-router)#do sh ip proto
	...
	Passive Interface(s): > новые строки
	GigabitEthernet0/0
```

### Базовая настройка для нескольких областей