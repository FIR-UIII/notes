EtherChannel - более правильная версия STP. Агреггирование канала
    LACP - динамическое
    PAGP - динамическое

Требование, это - порты должны иметь одинаковые
    скорость
    режим дуплекса
    native VLAN / диапазон
    trunkink status
    тип интерфейса

Ether channel аггрегация
2 коммутатора - соединенных через 2 интерфейса, f0/1 и f0/2
```
Switch>en
Switch#conf t
Switch(config)#int range f0/1 - 2
Switch(config-if-range)#channel-group 1 mode on
Creating a port-channel interface Port-channel 1
```
Аналогично на втором коммутаторе. Важный момент - данные команды создают отдельный логический интерефейс "Port-channel" (как f0/1, vlan1). И далее чтобы настроить trunk port нужно в выборе интерфейса указавать именно "Port-channel n"

LACP
Один коммутатор в активном режиме, второй в пассивном
```
====SW1====
Switch#conf t
Switch(config)#int range f0/1-2
Switch(config-if-range)#channel-protocol lacp
Switch(config-if-range)#channel-group 1 mode active 
Creating a port-channel interface Port-channel 1
Switch#show etherchannel summary 
====SW2====
Switch#conf t
Switch(config)#int range f0/1-2
Switch(config-if-range)#channel-protocol lacp 
Switch(config-if-range)#channel-group 1 mode passive 
Creating a port-channel interface Port-channel 1
Switch#show etherchannel summary 
```
Важный момент - данные команды создают отдельный логический интерефейс "Port-channel" (как f0/1, vlan1). И далее чтобы настроить trunk port нужно в выборе интерфейса указывать именно "Port-channel n"