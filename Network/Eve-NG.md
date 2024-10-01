1. Запустить ВМ
2. Зайти на веб http://<ip>/#/login
3. Выбрать подключение html-5 

### Подключение к интернету
1. Подключение к роутеру домашнему. Проверить что  EVE подключена через мост к физической машине + Репликация состояния. 
2. Добавить объект Network, type - Managenent (Cloud). Создает новый интерфейс на EVE

### Программный SWITCH
Cisco 3725 + NM-16ESW

### Установка образов
192.168.1.27 root:root
каталог - /opt/unetlab/addons/

### Ошибка 
![[Pasted image 20240101160024.png]]
Решение - отключить Hyper-V:
Включение или отключение компонентов Windows > Hyper-V > Отключить
CMD as admin
```
bcdedit /set hypervisorlaunchtype off
bcdedit /set hypervisorlaunchtype auto - включение если нужно сделать обратно
```
PS as admin
```
Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V –All - включение если нужно сделать обратно
```
