```
$ sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
$ sudo mkdir -p /samba/public
$ cd /samba                                     
$ sudo chmod -R 0755 public 
$ ls -l  
drwxr-xr-x 2 root root 4096 Nov  2 04:05 public
$ sudo mkdir /samba/private  
$ sudo groupadd smbgroup
$ sudo adduser smbuser                       
	passwd: password updated successfully
	info: Adding new user `smbuser' to supplemental / extra groups `users' ...
	info: Adding user `smbuser' to group `users' ...
$ sudo chgrp smbgroup /samba/private
$ sudo smbpasswd -a smbuser
	New SMB password:
	Retype new SMB password:
	Added user smbuser.
$ sudo nano /etc/samba/smb.conf >>> см. Базовый модуль OS Linux команды для практик
$ testparm -s
$ service smbd restart 
$ service smbd status  
● smbd.service - Samba SMB Daemon
     Loaded: loaded (/lib/systemd/system/smbd.service; disabled; preset: disabled)
     Active: active (running) since Thu 2023-11-02 04:27:50 EDT; 24s ago
```