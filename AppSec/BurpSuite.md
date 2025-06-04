Install
```sh
# Java installation
root@lab:~# sudo apt install default-jre
root@lab:~# sudo apt install default-jdk
root@lab:~# java --version
openjdk 17.0.13 2024-10-15
OpenJDK Runtime Environment (build 17.0.13+11-Debian-2deb12u1)
OpenJDK 64-Bit Server VM (build 17.0.13+11-Debian-2deb12u1, mixed mode, sharing)

root@lab:/tmp# unzip burpsuite_pro_v2023.10.1.zip 
lab@lab:~$ burp.sh 
lab@lab:~$ cat /usr/local/bin/burp.sh 
#! /bin/sh
java -jar /usr/local/bin/burploader.jar
```