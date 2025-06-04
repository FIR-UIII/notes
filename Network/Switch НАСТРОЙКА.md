### Полезные команды
```
show ip int br - показать талицу ip адресов и интерфейсов
show vlan br - показать талицу vlan
sh startup-conf -  просмотр стартовой конфигурации
sh r | i password - вывод из текущей конфигурации только тех строк, которые содержат комбинацию password
show ip int br | e down - вывод из краткой таблицы с информацией обо всех интерфейсах только тех строк, которые не содержат комбинацию down
int range fa0/1 - 23, g0/1 - 2 подрежим конфигурирования диапазона портов fa0/1 - fa0/23, g0/1 - g0/2
logging synchronous - включение синхронного вывода лог-сообщений для линии
```
### Базовая настройка коммутатора
```
Switch#conf t
Switch(config)#hostname S1
	#Запрещаем нежелательный поиск в DNS
S1(config)#no ip domain-lookup 
	# создание VLAN > см. [[L2 VLAN VTP DTP]]
S1(config)#vlan 100
S1(config-vlan)#name Management

	# Настраиваем шлюз по умолчанию и адрес для администрирования
S1(config)#ip default-gateway 192.168.0.100 # опционально для связи с другими
S1(config)#interface vlan 100
S1(config-if)#ip address 10.20.0.2 255.255.255.0
S1(config-if)#no shut

	# Настраиваем пользовательствие access VLAN
S1(config)#int f0/1
S1(config-if)#sw mode access
S1(config-if)#sw access vlan 10
S1(config-if)#no shut
S1#sh vlan br

	# Назначьте все неиспользуемые порты коммутатора во VLAN Parking Lot и закрыть
S1(config-if)#int range f0/2 - 4, f0/7 - 24, g0/1 - 2
S1(config-if-range)#sw mode access
S1(config-if-range)#sw access vlan 999
S1(config-if-range)#shut
S1#sh vlan br

	# Настраиваем магистральные trunk VLAN
S1(config)#int f0/1
S1(config-if)#sw mode trunk
S1(config-if)#sw trunk allowed vlan 20,30,40,1000
S1(config-if)#sw trunk native vlan 1000
S1#sh int trunk

S1(config)#username admin privilege 15 secret 123 # логин и пароль на пользователя
S1(config)#aaa new-model
S1(config)#aaa authentication login default local
S1(config)#enable secret 123 # пароль на вход в привилегированный режим
ДАЛЕЕ см. SSH
```
[[SSH - Router Switches]]
### Добавить служебного пользователя с низкими привилегиями
```
### Если зайти в систему под пользователем worker​, то вам будет доступно всего две команды: show running-config​и ping​.
Switch(config)#username worker privilege 2 secret cisco #создаем пользователя
Switch(config)#privilege exec level 2 show running-config #определяем доступные команды
Switch(config)#privilege exec level 2 ping
```

==============================================================
#### Устаревшие команды
```
==== Пароль на ENABLE ==== 
Switch#conf t
Switch(config)#enable secret MyPassword # задаем шифрованный пароль

==== Пароль на консоль ==== 
Switch(config)#line console 0
Switch(config-line)#login local

---> или если с нуля (когда нет локальных пользователей)
Router#configure terminal
Router(config)#line console 0
Router(config-line)#password MyPassword
Router(config-line)#login > активация входа. Без этой команды не будет логина
Router(config-line)#end

====  Пароль на Telnet и SSH ==== 
Router#conf t
Router(config)#line vty 0 4 # vty это вирт.терминал для подключения ssh telnet
Router(config-line)#password MyPassword
Router(config-line)#login
Router(config-line)#end
```

Включение Telnet через vty терминал
```
SW1#conf t
SW1(config)#line vty 0 4
SW1(config-line)#transport input telnet 
SW1(config-line)#login local

ИЛИ (когда нет локальных пользователей)
SW1#conf t
SW1(config)#line vty 0 4
SW1(config-line)#password MyPassword
SW1(config-line)#login
SW1(config-line)#end
```
