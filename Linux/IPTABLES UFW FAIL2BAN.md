# Fail2Ban
ПО для защиты от брутфорса
```
apt-get install fail2ban

/etc/fail2ban/fail2ban.conf > запуск процесса fail2ban
/etc/fail2ban/jail.conf > настройки защиты
	ignoreip > список ip которые не подвержены блокировке
	bantime > время на которое хосту будет заблокирован
	findtime > промежуток времени на авторизацию
	maxretry > кол-во попыток ввода

# service fail2ban restart > перезапустить
# service fail2ban stop > остановить работу

# fail2ban-client status > проверить статус блокировок
	Status
	- Number of jail:	1
	- Jail list:	sshd > указывает какой сервис было заблокирован
# fail2ban-client status sshd > проверяем детали блокировки
	Status for the jail: sshd
	- Filter
	  - Currently failed:	1
	  - Total failed:	1
	  - File list:	/var/log/auth.log
	- Actions
	   - Currently banned:	1
	   - Total banned:	1
	   - Banned IP list:	192.168.56.102 > заблокированный адрес

# fail2ban-client unban 192.168.56.102 > разблокировать
```

Пример настройки ssh. Создаем файл /etc/fail2ban/jail.local где прописываем 
```
[sshd]
enable = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
ignoreip = 127.0.0.1
```
Пример настройки для nginx
```
[nginx-limit-req]
port = http, https
enabled = true
filter = nginx-limit-req
action = iptables-multiport[name=ReqLimit, port="http,https", protocol=tcp]
logpath = /var/log/nginx/*error.log
findtime = 600
bantime = 3600
maxretry = 4
```


