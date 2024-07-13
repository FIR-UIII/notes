[[#Настройка стенда]]
RSAT - инструмент для удаленного администрирования DC (как оснастка)
WMI - подсистема PS для удаленного управления компьютера домена
# Роли 

### AD Sites and Services
Репликация между офисами разных городов
![[Pasted image 20231026154248.png]]

### NTDS
База данных, где храниться информация о всех объектах на Контроллера Домена (ntds.dit). 
Как выгрузить:
```
C:\Users\Administrator>ntdsutil
ntdsutil: activate instance ntds
	Active instance set to "ntds".
ntdsutil: ifm
ifm: create full C:\temp
Creating snapshot...
Snapshot set {e519f6c9-78ff-4868-bc7e-04535a638f73} generated successfully.
Snapshot {07e5dd02-5ad7-4fab-9634-a3dda1d3d605} mounted as C:\$SNAP_202310311105_VOLUMEC$\
Snapshot {07e5dd02-5ad7-4fab-9634-a3dda1d3d605} is already mounted.
Initiating DEFRAGMENTATION mode...
     Source Database: C:\$SNAP_202310311105_VOLUMEC$\Windows\NTDS\ntds.dit
     Target Database: C:\temp\Active Directory\ntds.dit

                  Defragmentation  Status (% complete)

          0    10   20   30   40   50   60   70   80   90  100
          |----|----|----|----|----|----|----|----|----|----|
          ...................................................

Copying registry files...
Copying C:\temp\registry\SYSTEM
Copying C:\temp\registry\SECURITY
Snapshot {07e5dd02-5ad7-4fab-9634-a3dda1d3d605} unmounted.
IFM media created successfully in C:\temp
```
### DNS
Server Manager > Tools > DNS >
![[Pasted image 20231028150925.png]]
Добавить reverse lookup zone > ПКМ > New Zone > Primary zone {store in AD} > 192.168.10 > Name:	10.168.192.in-addr.arpa > Finish > Проверить наличие PTR записей
```
PS C:\Users\Administrator> nslookup dc2                      
Server:  localhost                                           
Address:  127.0.0.1                                                                     
Name:    dc2.lab.local                                       
Address:  192.168.10.201                                                                

PS C:\Users\Administrator> nslookup 192.168.10.50
Server:  localhost     
Address:  127.0.0.1
*** localhost can't find 192.168.10.50: Non-existent domain > не настроена reverse lookup zone
```

Как храниться DNS записи
1. Локально в кеше ПК C:\windows\system32\drivers\etc\hosts
2. Если нет запрос к DNS серверу
3. Если DNS сервер нет знает, он отправляет запрос к Root - Серверу, который сообщит ему TLD адрес сервера и далее по цепочке

Типы запросов:
    - forward lookup. Какой IP у этого DN
    - reverse lookup. Какой DN у IP
Зоны:
    - primary zone. Хранятся все записи DN
    - secondary zone. Резервирование
    - stub zone. Содержит адрес куда обратиться если хотим найти адрес в конкретном домене.
Записи:
    SOA - базовая информация о домене. владелец, TTL,
    A/AAAA - связывает имя DN с IPv4, IPv6
    MX - указывает куда слать почту
    PTR - обратная DNS запись
    CNAME - alias, псевдоним чтобы 1 устройство имело несколько доменных имен
    NS - указывает DNS сервер этого домена
    SRV - Указывает на серверы для сервисов, например LDAP, Kerberos, IIS и т.п.
### DHCP
раздача IP адресов, маска сети, адрес gateway, время аренды IP и др.
Server Manager > Tools > DHCP > IPv4 > ПКМ > New Scope > Name as u want > IP range > Exclusion IP > Duration (365 days) > Options > Gateway (Router IP) > WINS (пропустить) > Activate Scope (yes) > Finish
### Active Directory
	Протокол LDAP
	Время - протокол NTP
### GPO
GPO хранятся и передаются по сети \\lab.local\SYSVOL
Локальная групповая политика
Применяется к конкретному ПК / gpedet.msc
Доменная групповая политика
    Default Domain Policy - базовые параметры для всех пользователей и ПК
    Default Domain Controller Policy - базовые параметры для всех DC домена.
Все политики применяются по триггеру. Для ПК - это перезагрузка, Для пользователя - вход/выход. Автоматическое обновление - 90 минут.
```
Gpresult /r /z # проверить GPO текущего пользователя и ПК
gpresult /r /scope:computer # проверить GPO текущего пользователя и ПК
gpupdate # обновление политик
```
##### GPO для SIEM
[[OS_Windows_PT-Start - Google Chrome 2023-10-28 16-19-18.mp4]]
Настройка Server Manager > Tools > Group Policy Management > default domain controller policy > ПКМ > Edit > Computer Config / Windows Setttings / Security Settings / Advanced Audit Policy /Audit Policies > Object Access
Аудит командной строки
Аудит PowerShell
Аудит служб аутентификации
Журналирование LDAP
Журналирование неудачных попыток выгрузки членов доменных групп
расширенные политики аудита
### Компоненты
	Users
	Computers
	Groups
	Organization Unit
Все объекты имеют свойства и атрибуты. Самый главный это objectSID. Дескриптор объекта.
![[Pasted image 20231026154857.png]]

Группы по умолчанию
	Администраторы предприятия Enterprise Admins - весь лес
	Администраторы Схемы Schema Admins - конкретная схема домена
	Администраторы Домена Domain Admins - конкретный домен
	Операторы сервера Server Operators - права на тех.обслуживание
	Операторы архива Backup Operators - права на резер.копирование

Схема домена
- определяет атрибуты и классы для всех объектов домена

Переменные окружения, хранятся в реестре
	%APPDATA% - путь до папки в которой хранятся настройки программ текущего пользователя
	%WINDIR% - каталог где установлена Windows
	%USERNAME% - имя текущего пользователя

### Настройка стенда
VirtualBox
Сеть - внутренняя сеть

##### Win2016 Server Standart (Desktop) #1
1. Выборочная установка > Разметка диска > Установить
2. Server Manager > Local Server > 
Ethernet > IPv4 set 192.168.10.200/24 gateway 192.168.10.254/24 (Router)
Time zone > Set current time zome and time
Comp name > dc1 > reboot
3. Server Manager > Add Roles and Features
	> ADDS
	> DNS
	> DHCP
4. Post-deployment >Promote server to DC
	> Add new forest - lab.local
![[Pasted image 20231026162208.png]]
5. DHCP - ничего не меняем, все оставляем как предлагает wizard
6. Добавляем скриптом пользователей и группы [[PTnewadusergroups.ps1]]
##### Win2016 Server Standart (Desktop) #2
1. Ethernet > IPv4 set 192.168.10.200/24 gateway 192.168.10.254/24 (Router), DNS - 192.168.10.200
2. Time zone > Set current time zome and time
3. Comp name > dc2 > reboot
4. Server Manager > Add Roles and Features
	> ADDS
	> DNS
	> DHCP
5. Post-deployment >Promote server to DC
Add to existing domain - lab.local
![[Pasted image 20231026173634.png]]
Данные указать в полном виде через @ ![[Pasted image 20231026173542.png]]
Для репликации выбрать dc1 или можно указать любой домен контроллер
![[Pasted image 20231026173834.png]]
Итоговые конфигурации выглядят как:
```
#
# Windows PowerShell script for AD DS Deployment
#
Import-Module ADDSDeployment
Install-ADDSDomainController `
-NoGlobalCatalog:$false `
-CreateDnsDelegation:$false `
-Credential (Get-Credential) `
-CriticalReplicationOnly:$false `
-DatabasePath "C:\Windows\NTDS" `
-DomainName "lab.local" `
-InstallDns:$true `
-LogPath "C:\Windows\NTDS" `
-NoRebootOnCompletion:$false `
-SiteName "Default-First-Site-Name" `
-SysvolPath "C:\Windows\SYSVOL" `
-Force:$true
```
##### Win10pro
Выборочная установка > Разметка диска > Установить
Первичная настройка > Сеть: У меня нет Интернета > Продолжить ограниченную установку
Network > IPv4 192.168.10.50/24, Gateway (router) 192.16810.254, DNS - 192.168.10.200
Отключаем обновления
Пропишем название машины - pc1
Добавляем pc1 в домен lab.local
##### Роутер (микротик)
IP eth1 10.0.2.15/24 (NAT) >>> Host
IP eth2 192.168.10.254/24 (Internal Network) >>> AD Win10, DC1
NAT output interface - eth1