Фильтрация на уровне L3 и L4

### ПРАВИЛА
Если пакет совпал с условием, дальше он не обрабатывается. 
Если первое условие не совпало, идет обработка второго условия и так до конца списка ACL
Если никакое из условий не совпадает, пакет просто уничтожается. Т.к. в каждом конце списка стоит неявный deny any.
Если использовать ACE `deny` > **ОБЯЗАТЕЛЬНО** добавить `permit ip any any` в конце ACL
ACL не действует на трафик, сгенерированный самим маршрутизатором
Интерфейс может иметь только 1 ACL IPv4 IN, 1 ACL IPv4 OUT, 1 ACL IPv6 IN, 1 ACL IPv6 OUT
Применяется в 2 этапа: создание ACL и применение его к интерфейсу
Для хостов лучше использовать host 172.31.1.102

|ACL|Стандартные (Standard)|Расширенные (Extended)|
|---------------|----------------------|----------------------|
|Номер списка|от 1 до 99|от 100 до 199|
|Описание|могут проверять только IP адреса источников|могут проверять IP адреса, а также адреса получателей, в случае IP ещё тип протокола и TCP/UDP порты|
|Характеристики|работают быстрее|работают они медленнее, так как придется заглядывать внутрь пакета|
|Где ставить|как можно ближе к месту назначения|как можно ближе к источнику фильтруемого трафика|
#### Стандартный ACL

```
Router(config)#access-list <номер списка от 1 до 99> {permit|deny|remark <text>} {source ip-address | any | host} [source-wildcard] [log]

# Именной
R1(config)#ip access-list standard MY_ACL
R1(config-std-nacl)#deny host 192.168.0.1
R1(config)#int <f0/0>
R1(config-if)# ip access-group {access-list-number | access-list-name} {in | out}

# Нумерованный
R1(config)#access-list 20 deny host 192.168.10.10
R1(config)#access-list 20 permit 192.168.10.0 0.0.0.255
R1(config)#int <f0/0>
R1(config-if)# ip access-group {access-list-number | access-list-name} {in | out}
```
#### Расширенный
После ключевых слов permit или deny в расширенном списке доступа IPv4 обычно используются четыре ключевых слова: ip, tcp, udp и icmp . Если применяется ключевое слово ip , оно влияет на весь пакет протоколов TCP/IP (все протоколы TCP/IP
```
Router(config)#access-list <номер списка от 100 до 199> {permit|deny|remark <text>} {source:ip|tcp|udp|icmp} {source:any|host|ip} [source-wildcard] {destination:ip|tcp|udp|icmp} [destination-wildcard] [It(меньше чем)|gt(больше чем)|eq(равно)|neq(не равно)|диапазон(включая диапазон)] [port] [tcp:established] [log]

tcp > eq|gt|lt|neq|dscp ...
udp > eq|gt|lt|neq|dscp ...
ip > dscp ...
icmp > echo|echo-reply|host-unreachable ...

# Именной
R1(config)# ip access-list extended MY_ACL
R1(config-ext-nacl)# remark Permits inside HTTP and HTTPS traffic
R1(config-ext-nacl)# permit tcp 192.168.10.0 0.0.0.255 any eq 80
R1(config-ext-nacl)# permit tcp 192.168.10.0 0.0.0.255 any eq 443
R1(config)# ip access-list extended BROWSING
R1(config-ext-nacl)# remark Only permit returning HTTP and HTTPS traffic
R1(config-ext-nacl)# permit tcp any 192.168.10.0 0.0.0.255 established
R1(config)# interface g0/0/0
R1(config-if)# ip access-group SURFING in
R1(config-if)# ip access-group BROWSING out

# Нумерованный
R1(config)# access-list 100 permit tcp any any eq 22
R1(config)# access-list 100 permit tcp any any eq 443
R1(config)# access-list 100 permit tcp any any eq www {80}
R1(config)#int <f0/0>
R1(config-if)# ip access-group 100 {in | out}
```
#### Управление / изменение ACL
```
# Проверить наличие ACL
R1#show access-lists
Standard IP access list 10
	10 deny 192.168.10.10 (20 matches) 
	20 permit 192.168.10.0, wildcard bits 0.0.0.255 (64 matches)

# Очистка статистики ACL
R1# clear access-list counters NO-ACCESS

# Просмотр списка ACL в текущей конфигурации
R1# show run | section access-list 
    access-list 10 remark INTERNET
    access-list 10 permit 192.168.10.10
    access-list 10 permit 192.168.20.0 0.0.0.255

# проверить, применяется ли к интерфейсу ACL
R1# show ip int Serial 0/1/0 | i access list 
    Outgoing Common access list is not set
    Outgoing access list is 10
    Inbound Common access list is not set
    Inbound  access list is not set

# Снять с интерфейса ACL
R1(config)#int <f0/0>
R1(config-if)#no ip access-group {access-list-number | access-list-name} {in | out}

# Удалить ACL из БД Роутера
no ip access-list standard <ACL-name>

# Редактирования списка по номеру ACE
R1(config)#ip access-list standard {access-list-number | access-list-name}
R1(config-std-nacl)# no 10 # удаляем строку №10
R1(config-std-nacl)# 10 deny host 192.168.10.10 # вставляем строку №10
```

#### Защита портов VTY
```
# telnet
R1(config)# username ADMIN secret P@s$W0rD
R1(config)# ip access-list standard ADMIN-HOST
R1(config-std-nacl)# remark This ACL secures incoming vty lines
R1(config-std-nacl)# permit host 192.168.10.10 
R1(config-std-nacl)# deny any
R1(config)#line vty 0 4
R1(config-line)#login local
R1(config-line)#transport input telnet
R1(config-line)#access-class ADMIN-HOST in

# SSH
R1(config)#ip access-list standard SSH-ACCESS /создание списка доступа с понятным названием 
R1(config-std-nacl)#permit host 192.168.2.2 /определяем хосты имеющие доступ по SSH R1(config-std-nacl)#permit host 192.168.2.3 /определяем хосты имеющие доступ по SSH 
R1(config-std-nacl)# deny any
R1(config)#line vty 0 4 /заходим в режим конфигурации vty 
R1(config)# line vty 0 4
R1(config-line)# login local
R1(config-line)# transport input ssh
R1(config-line)# access-class SSH-ACCESS in
```

### Примеры
1. Нумерованный стандартный ACL. Доступ в Интернет разрешен только с 192.168.10.10 и все 254 узла из 20 подсети
```
R1(config)# access-list 10 remark INTERNET
R1(config)# access-list 10 permit host 192.168.10.10
R1(config)# access-list 10 permit 192.168.20.0 0.0.0.255
R1(config)# interface Serial 0/1/0
R1(config-if)# ip access-group 10 out
R1(config-if)# end
```

2. Именованный стандартный ACL. Доступ в Интернет разрешен только с 192.168.10.10 и все 254 узла из 20 подсети
```
R1(config)# ip access-list standard PERMIT-ACCESS
R1(config-std-nacl)# remark ACE permits host 192.168.10.10
R1(config-std-nacl)# permit host 192.168.10.10
R1(config-std-nacl)# remark ACE permits host 192.168.10.10
R1(config-std-nacl)# permit host 192.168.10.10
R1(config-std-nacl)# remark ACE permits all hosts in LAN 2
R1(config-std-nacl)# permit 192.168.20.0 0.0.0.255
R1(config-std-nacl)# exit
R1(config)# interface Serial 0/1/0
R1(config-if)# ip access-group PERMIT-ACCESS out
R1(config-if)# end
R1# show access-lists
Standard IP access list PERMIT-ACCESS
    10 permit 192.168.10.10
    20 permit 192.168.20.0, wildcard bits 0.0.0.255
R1# show run | section ip access-list
ip access-list standard PERMIT-ACCESS
    remark ACE permits host 192.168.10.10
    permit 192.168.10.10
    remark ACE permits all hosts in LAN 2
    permit 192.168.20.0 0.0.0.255
R1# show ip int Serial 0/1/0 | include access list
    Outgoing Common access list is not set
    Outgoing access list is PERMIT-ACCESS
    Inbound Common access list is not set
    Inbound  access list is not set
```

3. Ограничение доступа к маршрутизатору. ACL разрешает подключаться к маршрутизатору только с адреса 4.4.4.4:
```
router(config)# access-list 10 permit 4.4.4.4
router(config)# line vty 0 4
router(config-line)# access-class 10 in
```

