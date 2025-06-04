### Базовая настройка маршрутизатора
```
Router#conf t
Router(config)#hostname R1
R1(config)#no ip domain-lookup #Запрещаем нежелательный поиск в DNS
R1(config)#banner motd #Unauthorized access to this device is prohibited!#

# Поднимаем нужные интерфейсы
R1(config)#int g0/0/0
R1(config-if)#ip address 172.16.1.1 255.255.255.0
R1(config-if)#no shut

# Назначаем default route шлюз по умолчанию (если это необходимо)
R1(config)# ip route 0.0.0.0 0.0.0.0 10.20.0.1

# Создаем пользователя для работы и подключения

R1(config)#username admin privilege 15 secret 123 # логин и пароль на пользователя
R1(config)#aaa new-model
R1(config)#aaa authentication login default local
R1(config)#enable secret 123 # пароль на вход в привилегированный режим
ДАЛЕЕ см. SSH
```
[[SSH - Router Switches]]


==============================================================
#### Устаревшие команды
```
==== Пароль на привилегированный режим EXEC (ENABLE) ==== 
R1#conf t
R1(config)#enable secret MyPassword # задаем шифрованный пароль
R1(config)#service password-encryption

==== Пароль на консоль ==== 
R1(config)#line console 0
R1(config-line)#login local
	---> или если с нуля (когда нет локальных пользователей)
	R1(config-line)#password MyPassword
	R1(config-line)#login > активация входа. Без этой команды не будет логина
	R1(config-line)#end

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
