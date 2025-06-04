инструмент командной строки для создания виртуальных машин и управления ими.
Конфигурирование проводится на основе \ файла - Vagrantfile
Vagrant работает с виртуальными машинами, а значит для виртуализации ему необходим какой-либо "провайдер" - VirtualBox, Hyper-V, Docker, VMware и др.
Коробка — это, по сути, просто образ уже установленной и настроенной операционной системы. Аналог Docker Hub только для образов ОС (коробок) - является Vagrant Cloud: https://app.vagrantup.com/boxes/search.

### Установка
https://developer.hashicorp.com/vagrant/install
После перезагрузки компьютера обязательно необходимо добавить переменную vagrant в системные переменные
```
set PATH=%PATH%;путь_до_папки_с_vagrant\Vagrant\bin
vagrant -v # проверяем
```

### Создание виртуальной машины в Vagrant
На примере создания ВМ с nginx 

1. создадим отдельную папку
```
mkdir VagrantVM
cd VagrantVM
```
2. Создайте в папке VagrantVM проекта файл 
```
<?php
phpinfo();
```
1. Настраиваем vagrant init -m bento/ubuntu-20.04 # создает файл Vagrantfile в текущей директории
```
# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
    # Образ виртуальной машины с Vagrant Cloud
    config.vm.box = "bento/ubuntu-20.04"
        # Настройки виртуальной машины и выбор провайдера
        config.vm.provider "virtualbox" do |vb|
        vb.name = "VagrantVM"
        # Отключаем интерфейс, он не понадобится
        vb.gui = false
        # 2 Гб оперативной памяти
        vb.memory = "2048"
        # Одноядерный процессор
        vb.cpus = 1
    end
    
    # имя хоста
    config.vm.hostname = "VagrantVM" 
    
    # синхронизация папок
    config.vm.synced_folder ".", "/home/vagrant/code",
        owner: "www-data", group: "www-data"
    # Переброс портов
    config.vm.network "forwarded_port", guest: 80, host: 8000
    config.vm.network "forwarded_port", guest: 3306, host: 33060
    # Команда для настройки сети
    config.vm.network "private_network", ip: "192.168.10.100"
    # Команда, которая выполнится после создания машины
    config.vm.provision "shell", path: "provision.sh"
end
```

### Для нескольких виртуальных машин
```
# -*- mode: ruby -*-
# vi: set ft=ruby :
hosts = {
    "conor" => "192.168.88.10",
    "mcgregor" => "192.168.88.11"
}

Vagrant.configure("2") do |config|
    config.vm.box = "bento/ubuntu-20.04"
    hosts.each do |name, ip|
        config.vm.define name do |machine|
            machine.vm.network :private_network, ip: ip
            machine.vm.provider "virtualbox" do |v|
                v.name = name
                v.gui = false
                v.memory = "1024"
                v.cpus = 1
            end
        end
        config.vm.provision "shell", path: "provision.sh"
        config.vm.network "forwarded_port", guest: 80, host: 8000
    end
end
```

provision.sh
```
apt-get update
apt-get -y upgrade
apt-add-repository ppa:ondrej/php -y
apt-get update
apt-get install -y software-properties-common curl zip
apt-get install -y php7.2-cli php7.2-fpm \
php7.2-pgsql php7.2-sqlite3 php7.2-gd \
php7.2-curl php7.2-memcached \
php7.2-imap php7.2-mysql php7.2-mbstring \
php7.2-xml php7.2-json php7.2-zip php7.2-bcmath php7.2-soap \
php7.2-intl php7.2-readline php7.2-ldap
apt-get install -y nginx
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
cat > /etc/nginx/sites-available/vagrantvm <<EOF
server {
    listen 80;
    server_name .vagrantvm.loc;
    root "/home/vagrant/code";
    index index.html index.htm index.php;
    charset utf-8;
    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }
    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt { access_log off; log_not_found off; }
    access_log off;
    error_log /var/log/nginx/vagrantvm-error.log error;
    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }
}
EOF

ln -s /etc/nginx/sites-available/vagrantvm /etc/nginx/sites-enabled/vagrantvm
service nginx restart
```

### Управление, создание ВМ
```
vagrant up - запустить или создать виртуальную машину
vagrant reload - перезагрузка виртуальной машины
vagrant halt  - останавливает виртуальную машину
vagrant destroy  - удаляет виртуальную машину
vagrant suspend  - "замораживает" виртуальную машину
vagrant global-status  - выводит список всех ранее созданных виртуальных
машин в хост-системе
vagrant status - посмотреть статус виртуальной машины
Отображение созданной виртуальной машины в VirtualBox
Vagrant 14
vagrant ssh  - подключается к виртуальной машине по SSH
vagrant - список всех доступных команд
exit - вернуться в нормальный режим командной строки
```
Изолированное окружение готово! Откройте браузер и введите: `http://localhost:8000/`

#Ansible
ПО для управления вирутальными машинами, настройкой, установкой и удаления на них ПО и т.д.
