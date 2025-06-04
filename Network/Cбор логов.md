Уровни логирования
0 - Emergencies. События связанные с неработоспособностью системы.
1 - Alets. Сообщения о необходимости немедленного вмешательства.
2 - Critical. Критические события.
3 - Errors. Сообщения об ошибках.
4 - Warnings. Сообщения содержащие предупреждения.
5 - Notifications. Важные уведомления.
6 - Informational. Информационные сообщения.
7 - Debugging. Отладочные сообщения.
Данные уровни обладают наследственностью, т.е. выбрав уровень 7, вы будете
получать сообщения всех уровней (от 0 до 7), а выбрав уровень 3 - только от 0 до 3.
### Console Logging 
Вывод сообщений в консоль. Данный способ работает по умолчанию и выводит логи прямо в консоль устройства.
```
Router(config)#logging console 7 >>> ВКЛЮЧЕНИЕ
или
Router(config)#logging console debugging

R1(config)#no logging console <<< ОТКЛЮЧЕНИЕ
```
### Buffered Logging
Сохранение логов в буфер устройства, т.е. RAM память.
```
Router(config)# logging on
Router(config)# logging buffered 32768 # 32 Кбайта
Router(config)# logging buffered informational
Router#show log
```
### Terminal Logging
Вывод логов в терминал, т.е. для Telnet или SSH сессий.
```
Router(config)#logging monitor informational
Router(config)#exit
Router#terminal monitor

Router#terminal no monitor <<< ОТКЛЮЧЕНИЕ 
```
### Syslog сервер
Централизованный сбор логов по протоколу Syslog.
```
Router(config)#logging host 192.168.1.100 \адрес Syslog-сервера
Router(config)#logging trap informational \6-ой уровень логирования
Router(config)#logging rate-limit all 50 \ограничили отправку syslog до 50 сообщений в секунду
```
### SNMP Traps 
Централизованный сбор логов по протоколу SNMP.
### AAA
Главная цель использования данной технологии - логирование команд
## Логирование команд
```
Router(config)#archive
Router(config-archive)#log config
Router(config-archive-log-cfg)#logging enable /включаем логирование команд
Router(config-archive-log-cfg)#logging size 200 /задаем количество строк
Router(config-archive-log-cfg)#hidekeys /”прячем” пароли
Router(config-archive-log-cfg)#notify syslog /отправляем на syslog-сервер
Router#show archive log config all
```