![[Pasted image 20231212142818.png]]

**Контейнер Docker** – это изолированное на уровне ядра ОС, запускаемое программное приложение или сервис, которое имеет свое пространство имен и cgroup (контрольные группы). Контейнер создается из образа dockerfile.
	Пространство имен - это набор ресурсов, которые может использовать процесс. `ls /proc/<PID>/ns` Контейнер имеет свое пространство имен
	Контрольная группа - управляет ресурсами CPU, RAM, HDD `cat /proc/<PID>/cgroup` ИЛИ на примере RAM `cat /sys/fs/cgroups/memory/docker/<Container_ID>/[OPTIONS]
	При запуске открывается API на локальном сокете /var/run/docker.sock (\pipe\docker_engine). Передача данных по gRPC
	
	
	Docker Engine 
	/usr/bin/dockerd - daemon публикует API
	/usr/bin/containerd - управление контейнерами и дает команды runc
	/usr/bin/containerd-shim-runc-v2
	/usr/bin/runc - низкоуровневый компонент выполняет команды и общается с ОС

##### Контрольные группы (control group, cgroup)
Всякий процесс Linux является членом одной контрольной группы для каждого типа ресурсов. Любой создаваемый процесс наследует контрольные группы своего родительского процесса.
```

# проверить список cgroup
ls /sys/fs/cgroup

# создание контрольных групп.
root@vagrant:/sys/fs/cgroup$ mkdir memory/liz
root@vagrant:/sys/fs/cgroup$ ls memory/liz/

После создания ядро автоматически заполнит его основными группами

# приписываем процесс PID #29903 к контрольной группе
root@vagrant:/sys/fs/cgroup/memory/liz$ echo 100000 > memory.limit_in_bytes
root@vagrant:/sys/fs/cgroup/memory/liz$ cat memory.limit_in_bytes
98304
root@vagrant:/sys/fs/cgroup/memory/liz$ echo 29903 > cgroup.procs
root@vagrant:/sys/fs/cgroup/memory/liz$ cat cgroup.procs
29903
root@vagrant:/sys/fs/cgroup/memory/liz$ cat /proc/29903/cgroup | grep memory 8:memory:/liz
```
Управлять контрольной группой можно с помощью записи в одни из этих файлов. Например, файл memory.limit_in_bytes содержит перезаписываемое значение, задающее объем памяти, доступной процессам группы
Атака #Fork-бомба  — это программа, создающая процессы, которые, в свою очередь, тоже создают процессы, что приводит к экспоненциальному росту объема используемых ресурсов и  в  итоге выводит машину из строя.
##### Пространство имен
Chroot() - системный вызов позволяющий изменить корневой каталог. Программе, запущенной с изменённым корневым каталогом, будут доступны только файлы, находящиеся в этом каталоге.
Пространство имён (англ. namespace) — это механизм ядра Linux, обеспечивающий изоляцию процессов друг от друга. Какая изоляция реализована:
[https://selectel.ru/blog/mexanizmy-kontejnerizacii-namespaces/](https://selectel.ru/blog/mexanizmy-kontejnerizacii-namespaces/)

Пространство имён   / Что изолирует
            PID / PID процессов (дерево процессов от PID init 1). Реализуется через сисвызов `clone()`
            NETWORK / Сетевые устройства, стеки, порты и т.п. `ip netns add netns1` Реализуется через сисвызов `unshare()`
            USER    / ID пользователей и групп
            MOUNT   / Точки монтирования. Реализуется через сисвызов `clone()`
            IPC     / SystemV IPC, коммуникация между процессами
            UTS     / Имя хоста и доменное имя NIS

# Команды
```
в ядре имеется специальный системный вызов — setns(). С его помощью можно поместить вызывающий процесс или тред в нужное пространство имён.
```

https://www.redhat.com/sysadmin/container-namespaces-nsenter
**Слой образа/контейнера** - логическое пространство содержащее данные. см. [[#Создание образа Dockerfile]]
**Образ Docker** – это шаблон, загруженный в контейнер для его запуска, например набор инструкций. Неизменяемый
**Реестр Docker** - репозиторий образов https://hub.docker.com/
### Основные команды
```
docker info ........................# system info
docker version .....................# version
docker login .......................# login to your account
docker images ......................# list images
docker build........................# Собрать образ Docker
docker commit.......................# Сохранить контейнер Docker в качестве образа
docker tag..........................# Присвоить тег образу Docker

### Запуск
docker pull [Image_name] ...........# pull an image from from a registry
docker run [Image_name] ............# запустить образ Docker в качестве контейнера
		-d [Image_name] ............# run the container in the background
		--rm [Image_name] ..........# remove container after stopping
		--name [Image_name].........# give a name to the image
docker start [Cont_name/ID] ........# start stopped conteiner

### Статистика и информация
docker ps ..........................# list running containers
docker ps -a .......................# list running all containers (running and stopped)
docker inspect [Cont_name/ID].......# show details about the container
docker image inspect [Image_name] ..# get image info
netstat -tulpen ....................# show netstat
docker logs [Cont_name/ID] .........# recieve last 10 logs
docker logs -f [Cont_name/ID] ......# live logs, like `tail`

### Подключиться к контейнеру
docker exec -it [Cont_name/ID] /bin/bash
	exit > выход
docker exec -it MySQL mysql -uroot -p

### Остановить и удалить
docker stop [Cont_name/ID] .........# stop the container SIGTERM (secure way 2 stop)
			-t 60 ..................# wait 60 sec
docker kill [Cont_name/ID] .........# kill the container SIGKILL (force way 2 stop)
docker rm $(docker ps -qa) .........# delete all
docker rmi [Image_name].............# delete the image
docker prune -a --volumes...........# delete image, volume !!!USE WITH CAUTION!!!
```
### Варианты запуска
```
# с пробросом портов 
docker run -d --publish [local_port]:[container_port] nginx
docker run -d -p 8080:80 --name webserver nginx

# с передачей аргументов при запуске и удалением образа (--rm)
docker run --rm --name My_cont ubuntu:20.04 echo "Hello_docker" 
```

Пример работы с образом nginx и созданным контейнером webserver
```
docker run -d -p 8080:80 --name webserver nginx # запустить контейнер
docker container exec -it webserver bash # подключиться по терминалу
docker stop webserver
docker ps
	в списке не будет этого контейнера
docker ps -a
	здесь он останется, т.к. записан в память
docker rm websever # удаляем из памяти
docker ps -a
	теперь в списке уже не будет этого контейнера
docker images
	появится список скачанных образов
docker rmi nginx # удаляем из локального хранилища выбранный образ
	Untagged: nginx:latest
	Deleted: sha256:a6bd71f48f6839d9faae1f29d3babef831e76bc213107682c5cc80f0cbb30866
	[...]
```

### Переменные окружения
Указываются после `-e` . Аналогичный ENV
```console
docker run --name mysql -e MYSQL_ROOT_PASSWORD=p@ssw0rd -d mysql
```

### Создание образа #Dockerfile
```
# создать образ из файла текущей директории
docker built -t [name:tag] .
# создать образ в другой директории
docker built -t [name:tag] -f [file_name]
# прикрепить тэг к существующему образу
docker tag [Image_name] [name:tag]
```

#Dockerfile 
```
FROM ubuntu:18.04 # Базовый образ на основе которого будет приняться инструкции

RUN apk update && apk upgrade && apk add bash # проведи обновление
RUN mkdir -p /usr/src/app # создай новую директорию
RUN pip install -r requirements.txt # запусти команду pip c чтением файла

WORKDIR /usr/src/app # перейди в эти директорию
COPY . /usr/src/app/ # скопируй локальные файлы в указанную директорию контейнера

EXPOSE 8080 # указать, что приложение будет использовать порт 8080

ENV TZ Europe/Moscow # добавляем переменную окружения

CMD ["python", "app.py"] # запусти в терминале python с параметром app.py
```
При запуске `docker run` , в который можно вносить изменения, добавляется поверх всех остальных слоёв. Новые изменения сохраняются в новом слое. Слои образа (неизменяемы), состоят из: базового слоя - как правило собирается ОС, файловая система, и далее накладываются слои в которых содержатся скрипты, переменные окружения, приложения. 

![[Pasted image 20231214153407.png]]
### Хранение данных в контейнере. Том. Volume
*Временное хранение*
По умолчанию файлы, создаваемые приложением, работающим в контейнере, сохраняются в слое контейнера, поддерживающем запись. Однако после того как контейнер перестанет существовать, исчезнут и данные.
Если вам не нужно, чтобы ваши данные хранились бы дольше, чем существует контейнер, вы можете подключить к контейнеру tmpfs — временное хранилище информации, которое использует оперативную память хоста. Но при перезагрузке хоста, потери питания - данные будут утеряны
*Постоянное хранение*
Том — это файловая система, которая расположена на хост-машине за пределами контейнеров. Они самостоятельны и отделены от контейнеров. Ими могут совместно пользоваться разные контейнеры. Для этого при создании образа #Dockerfile 
```
СПОСОБ 1
# монтирование хостовой папки /C:/tmp к папке в образе /usr/src/app
docker run --rm -v /C:/tmp:/usr/src/app

СПОСОБ 2
# создаем том "myvol" через инструкцию в Dockerfile
VOLUME /myvol
# или создание через CLI
docker volume create myvol

# монтирование хостовой папки /C:/tmp к тому myvol
docker run --rm -v myvol:/C:/tmp

### операции над томом (volume)
docker volume ls .................# просмотреть список томов
docker volume inspect my_volume ..# исследовать конкретный том
docker volume rm my_volume .......# удалить том 
docker volume prune ..............# удалить все тома, которые не используются контейнерами
```

Cписок часто используемых параметров для `--mount`, при запуске образа
```
docker run -d --name devtest -v myvol:/app nginx:latest, где
/app - новый каталог внутри контейнера
myvol - внешний каталог на хостовой машине

type=volume ......................# тип монтирования
source=volume_name ...............# источник монтирования
destination=/path/in/container ...# путь, к которому файл или папка монтируется в контейнере
readonly .........................# монтирует том только для чтения
```

### Сети
docker network ls > вывести список
docker network rm > удалить
Задача: Вы хотите разрешить связь между контейнерами. 
Метод 1. Мы создаем новую виртуальную сеть на вашем компьютере, которую можно использовать для управления взаимодействием между контейнерами. По умолчанию все контейнеры, которые вы подключаете к этой сети, смогут видеть друг друга по их именам. 
```
$ docker network create my_network
0c3386c9db...
$ docker run -it --network my_network ubuntu:16.04 bash
C указанием параметров сети 
$ docker network create --gateway 10.5.0.1 --subnet 10.5.0.0/16 my_network
```
Метод 2. Соединение контейнеров напрямую `--link`. Все системные вызовы будут идти через RPC
```
$ docker run --name wp-mysql \
-e MYSQL_ROOT_PASSWORD=yoursecretpassword -d mysql 
$ docker run --name wordpress \
--link wp-mysql:mysql -p 10003:80 -d wordpress
```
