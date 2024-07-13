```
/etc/apache2/apache2.conf - основные настройки
/etc/apache2/conf-available - доп.настройки
/etc/apache2/mods-available - найстройик модулей
/etc/apache2/sites-available - настройки виртуальных хостов (веб сайт)
    /etc/apache2/sites-available/000-default.conf - дефолтная конфигурация
/etc/apache2/ports.conf - порты на которых работает apache
```

/etc/apache2/sites-available/000-default.conf
```
<VirtualHost *:80> #адрес и порт хоста
ServerAdmin webmaster@localhost #Информаиця для связи
DocumentRoot /var/www/html #Корневой каталог
ErrorLog ${APACHE_LOG_DIR}/error.log #Файлы логов
CustomLog ${APACHE_LOG_DIR}/access.log combined #Файлы логов
```
Активация виртуального хоста
```
a2ensite > создает символьную ссылку в каталоге /etc/apache2/sites-enable
```