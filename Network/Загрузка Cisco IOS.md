Маршрутизатор в процессе загрузки ищет строки, которые содержат команду boot system в стартовом конфигурационном файле (startup config - c2600-js-l_121-3.bin). При загрузке она копируется в оперативную память RAM и становится running config.
Если нет то устройство смотрит есть ли записи в Flash-память, и далее сервер TFTP

### Варианты загрузки Cisco IOS
```
Router#conf t
Router(config)#boot system flash IOS_filename > Вариант 1. Из Flash-памяти (энергонезависима)
Router(config)#boot system tftp IOS_filename 172.16.13.111 > Вариант 2. Из TFTP сервер
Router(config)#boot system rom > Вариант 3. Урезанная IOS (дебаг) из постоянной памяти ROM
    <Ctrl>+<Z>
Router# copy running-config startup-config > сохранение
```

### Значения загрузочного поля конфигурационного регистра (Configuration register is 0x...)
`0x2101` - Устройство пытается загрузиться из памяти ROM
`0x2102` - `0x210F` - Устройство пытается загрузиться через посик команды boot system из NVRAM

# Устранение неполадок при загрузке операционной системы Cisco IOS
```
show version > проверить Configuration register
show running-config > найти команды boot system, провести анализ корректности
```
Образ операционной системы во Flash-памяти поврежден, если при загрузке:
    open: read error . . . requested 0x4 bytes, got 0x0 trouble reading device magic number
    boot: cannot open “flash: ”
    boot: cannot determine first file name on device “flash: ”

# Резервное копирование образа загрузки
Создание резервной копии файла начальной конфигурации на сервере TFTP https://www.youtube.com/watch?v=_d9NZEDi0O8
```
Cougar# copy running-config tftp
Address or name of remote host [] 192.168.119.20
Destination file name [Cougar-config]?
!!!!!!!!!!!!!!!!!!!!!!!!
```
Восстановление начальной конфигурации с TFTP-сервера
```
Cougar# copy tftp running-config
```

Создание резервной копии образа IOS Cisco на TFTP-сервере (перед переходом на новую версию Cisco IOS)
```
Cougar# copy tftp flash
```