Основывается на таблице NAT
    Inside local - Это адрес источника, видимый из внутренней сети. Откого
    Inside global - Это адрес источника, видимый из внешней сети. Обычно это глобально маршрутизируемый IPv4 адрес. Откого
    Outside local - Это адрес назначения, видимый из внешней сети. Кому
    Outside global - Это адрес назначения, видимый из внутренней сети. Кому

Ограничения
Усложняет работу с туннельными протоколами, такими как IPsec, поскольку преобразование NAT изменяет значения в заголовках
Усложняет работу с FTP 

### Статическое преобразование NAT
Применяется для серверов, где нужен статичный адрес обращение
Статический NAT использует сопоставление локальных и глобальных адресов по схеме «один в один». Эти соответствия задаются администратором сети и остаются неизменными.
```
# Шаг 1. Создание статической таблицы NAT ip nat inside source static <ip_address_local> <ip_address_global>
R2(config)# ip nat inside source static 192.168.10.254 209.165.201.5

Шаг 2. Назначение внешних и внутренних интерфейсов 
R2(config)# interface serial 0/1/0 # смотрит во внутренюю сеть и является шлюзом для хостов
R2(config-if)# ip address 192.168.1.2 255.255.255.252
R2(config-if)# ip nat inside
R2(config-if)# exit
R2(config)# interface serial 0/1/1 # смотрит во внешнюю сеть
R2(config-if)# ip address 209.165.200.1 255.255.255.252
R2(config-if)# ip nat outside

# Проверка
R2# show ip nat translations
Pro  Inside global       Inside local       Outside local     Outside global
---  209.165.201.5       192.168.10.254     ---               ---
Total number of translations: 1

# Поиск ошибок
R2# debug ip nat

# Cтатистика
R2# show ip nat statistics
R2# clear ip nat statistics / очистить статистику всех предыдущих преобразований

# Изменить / отключить NAT
R2#clear ip nat translation *
R2#conf t
R2(config)#no ip nat inside source static 192.168.10.254 209.165.201.5
```

### Динамическое преобразование NAT
При динамическом преобразовании NAT используется пул публичных адресов, которые назначаются в порядке очереди («первым пришел — первым обслужили»). 
```
# определите пул адресов, которые будут использоваться для преобразования
R2(config)# ip nat pool NAT-POOL1 209.165.200.226 209.165.200.240 netmask 255.255.255.224

# Настройте стандартный ACL
R2(config)#ip access-list standard R2NAT
R2(config-std-nacl)# permit 192.168.0.0 0.0.255.255

# Привяжите ACL к пулу, чтобы опр-ть, какие устройства из list получат адреса из pool
R2(config-if)# ip nat inside source list 1 pool NAT-POOL1

# Определите интерфейсы, являющиеся внутренними по отношению к NAT
R2(config)# interface serial 0/1/0
R2(config-if)# ip nat inside
R2(config-if)# interface serial 0/2/0
R2(config-if)# ip nat inside

# Определите интерфейсы, являющиеся внешними по отношению к NAT
R2(config)# interface serial 0/1/1
R2(config-if)# ip nat outside

# Проверка
R2# show ip nat translations [verbose]
R2# show ip nat statistics
R2# show running-config
R2# debug ip nat

# Изменить / отключить NAT
R2#clear ip nat translation *
R2#conf t
R2(config)#no ip nat inside source list R2NAT pool NAT-POOL1 overload
```
### Преобразование адресов портов (PAT)
Часто используется для вывода хостов в сеть Интернет. Преобразование адреса и номера порта (PAT), также называемое NAT с перегрузкой. Один внутренний глобальный адрес может быть сопоставлен со многими внутренними локальными адресами. Использует IPv4 адреса и номера портов источника TCP или UDP в процессе преобразования.
```
============== PAT для использования одного адреса ==================
# s0/1/1 смотрит во внешнюю сеть
R2(config)# access-list 1 permit 192.168.0.0 0.0.255.255 
R2(config)# ip nat inside source list 1 interface s0/1/1 overload 
R2(config)# interface serial0/1/0 # для всех инт-ов внутри кому нужен NAT
R2(config-if)# ip nat inside 
R2(config-if)# exit 
R2(config)# interface Serial0/1/1 
R2(config-if)# ip nat outside
R2(config-if)# ip address 209.165.202.130 255.255.255.252 # внешний IP

============== PAT для использования пула адресов ==================
# s0/1/1 смотрит во внешнюю сеть
# Настроить ACL
R2(config)#ip access-list standard R2NAT
R2(config-std-nacl)# permit 192.168.0.0 0.0.255.255

# Подготовить POOL внешних адресов
R2(config)# ip nat pool NAT-POOL1 209.165.200.226 209.165.200.240 netmask 255.255.255.224

# Настроить инт-сы для всех внутри кому нужен NAT
R2(config)# interface serial0/1/0 
R2(config-if)# ip nat inside 
R2(config-if)# exit 
R2(config)# interface serial0/1/1 
R2(config-if)# ip nat outside

# Включить PAT
R2(config)# ip nat inside source list R2NAT pool NAT-POOL1 overload 

# Проверка
R2# show ip nat translations [verbose]
R2# show ip nat statistics
R2# show running-config
R2# debug ip nat

# Изменить / отключить NAT
R2#clear ip nat translation *
R2#conf t
R2(config)#no ip nat inside source list R2NAT pool NAT-POOL1 overload
R2(config)#no ip nat pool NAT-POOL1 209.165.200.226 209.165.200.240 netmask 255.255.255.224
```