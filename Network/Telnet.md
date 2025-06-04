
```
Подключение
Switch#telnet 192.168.1.1

Чтобы приостановить Telnet сеанс, следует нажать комбинацию клавиш <Ctrl>+<Shift>+6 и потом клавишу <x>.\
Вернуться - нажать <Enter> или Switch#resume

Чтобы закончить Telnet сеанс, нужно присотановить сеанс <Ctrl>+<Shift>+6 и потом клавишу <x>
Switch#sh sessions 
Conn Host                Address             Byte  Idle Conn Name
*  1 192.168.1.1         192.168.1.1            0     0 192.168.1.1
Switch#disconnect 1
```