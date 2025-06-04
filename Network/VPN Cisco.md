![[Pasted image 20240211150940.png]]
IPsec site-2-site - подключение сетей межу собой
```
/// Все действия нужно посторить на обоих роутерах ///
### Шаг 1. Создаем политику VPN на роутере
R(config)#crypto isakmp policy 1
R(config-isakmp)#encr 3des # Выбираем алгоритм шифрования (конфиденциальность)
R(config-isakmp)#hash md5  # Тип хеширования (целостность)
R(config-isakmp)#authentication pre-share # Тип аутентификации PSK
R(config-isakmp)#group 2
R(config)#crypto isakmp key cisco address 210.210.2.2 # указываем адрес роутера с кем строим туннель (peer)

### Шаг 2. Настройка ключа аутентификации и пира
R(config)#crypto ipsec transform-set <VPNname> esp-3des esp-md5-hmac

# Определяем какой трафик шифровать
R(config)#ip access-list extended <ACLVPN>
R(config-ext-nacl)#permit ip 192.168.1.0 0.0.0.255 192.168.2.0 0.0.0.255

# Создание криптокарты
R(config)#crypto map <CryptoMap_name> 10 ipsec-isakmp
R(config-crypto-map)#set peer 210.210.2.2
R(config-crypto-map)#set transform-set <VPNname>
R(config-crypto-map)#match address <ACLVPN>

# Привязка к интерфейсу
R(config)#interface FastEthernet0/0
R(config-if)#crypto map <CryptoMap_name>

### ПРОВЕРКА
ping
sh crypto isakmp sa
sh crypto ipsec sa
```

Возможные проблемы
> Destination unreacheble - 
	проверить NAT (sh ip nat tr), если там появляюсь icmp пакеты то трафик заворачивается в NAT но не идет в IPsec, нужно поправить ACL для NAT
	проверить ACL на отсутствие дублирования IPsec сетей в др. технологиях
	таблицу маршрутизации роутера - возможно нет маршрута

IPsec remote access - подключение удаленного пользователя к сети
```
TEXT
```

Типовые настройки МЭ
```
Настройка первой фазы
crypto ikev1 enable outside
crypto ikev1 policy 1
encr 3des
hash md5
authentication pre-share
group 2
lifetime 43200
Настройка ключа аутентификации и пира
tunnel-group 210.210.2.2 type ipsec-l2l
tunnel-group 210.210.2.2 ipsec-attributes
ikev1 pre-shared-key cisco
Вторая фаза
crypto ipsec ikev1 transform-set TS esp-3des esp-md5-hmac
Определяем какой трафик шифровать
access-list FOR-VPN extended permit icmp 192.168.1.0
255.255.255.0 192.168.2.0 255.255.255.0
Создание криптокарты
crypto map To-Site2 1 match address FOR-VPN
crypto map To-Site2 1 set peer 210.210.2.2
crypto map To-Site2 1 set security-association lifetime seconds
86400
crypto map To-Site2 1 set ikev1 transform-set TS
Привязка к интерфейсу
crypto map To-Site2 interface outside
```