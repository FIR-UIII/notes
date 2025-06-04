 настройки ssh, с доп. параметрами:
	попыток на вход - 2
	60 секунд на автовыход при бездействии
```
R1(config)#ip domain-name artem.lab
R1(config)#crypto key generate rsa
The name for the keys will be: R1.artem.lab
Choose the size of the key modulus in the range of 360 to 2048 for your
General Purpose Keys. Choosing a key modulus greater than 512 may take
a few minutes.
How many bits in the modulus [512]: 1024
% Generating 1024 bit RSA keys, keys will be non-exportable...[OK]
*Mar 1 0:7:16.194: %SSH-5-ENABLED: SSH 1.99 has been enabled

R1(config)#ip ssh time-out 60
R1(config)#ip ssh authentication-retries 2

R1(config)#line vty 0 15
R1(config-line)#transport input ssh
R1(config-line)#password 123
R1(config-line)#end

R1#show ip ssh
SSH Enabled - version 1.99
Authentication timeout: 60 secs; Authentication retries: 2
```

Для подключения
```
R0#ssh -l artem 192.168.1.2
Password:

R1>
```

### SSH
```

```