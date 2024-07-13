Вывести информацию
```
R1#show cdp interface - статус работы cdp
R1#show cdp neighbors - показать инф-ия по обнаруженным устр-ам
R1#show cdp neighbors detail - дательная информация
R1#show cdp entry [имя устройства] - показать инф-ию по конкретному устр-ву
R1#clear cdp table - очистить таблицу cdp

Включение / отключение CDP на устройстве в целом
R1(config)#[no] cdp run

Включение / отключение CDP на интерфейсе
R1(config-if)#[no] cdp enable
```