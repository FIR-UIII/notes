### Паттерны хороших политик
Базово правила оптизимированных политик приведены в документации разработчика: https://www.openpolicyagent.org/docs/policy-performance
Ниже описаны кейсы из личной практики.

##### 1. Датасет data.json строиться на словарях (object) вместо массивов (array). И позволяет быстро найти искомое значение
```rego
# Плохой вариант
d := [{"id": "a123", "first": "alice", "last": "smith"},
      {"id": "a456", "first": "bob", "last": "jones"},
      {"id": "a789", "first": "clarice", "last": "johnson"}
      ]

# Чтобы проверить атрибут first у пользователя alice в некой группе a123:
allow := true {
	d[0].id == "a123"
	d[0].first
}

# Оптимизированный вариант, позволяющий быстрее найти по ключу нужное значение
d := {"a123": {"first": "alice", "last": "smith"},
      "a456": {"first": "bob", "last": "jones"},
      "a789": {"first": "clarice", "last": "johnson"}
     }

# Чтобы проверить атрибут first у пользователя alice в некой группе a123:
allow := true {
	d["a123"].first
}

# ----
# Плохой вариант
d := {"groups": ["admin", "foo", "bar"]}

# В таком случае, чтобы найти принадлежность к админам нужно сделать
is_admin := true {
    input_group := input.groups[_]
    input_group == "admin"
}

# И если admin будет в конце списка {"groups": ["foo", "bar", "admin"]}, то это вызовет как минимум 3 лишних перебора
opa eval -d .\task_8.rego -d .\data.json -i .\input.json --profile --format=pretty 'data.test.allow'
+---------+----------+----------+--------------+------------------+
|  TIME   | NUM EVAL | NUM REDO | NUM GEN EXPR |     LOCATION     |
+---------+----------+----------+--------------+------------------+
| 256.4µs | 1        | 1        | 1            | data.test.allow  |
| 13.7µs  | 1        | 3        | 1            | .\task_8.rego:9  |
| 0s      | 3        | 1        | 1            | .\task_8.rego:10 |
+---------+----------+----------+--------------+------------------+

# Оптимизированный вариант, позволяющий быстрее найти по ключу нужное значение
d := {"admin": true, "groups": ["admin", "foo", "bar"]} 

allow := true {
    rbac.admin == true
}
```

##### 2. Упрощение функций и сложности правил
Это комплектное правило, что подразумевает
- использование индексируемых операторов
<img width="624" height="272" alt="image" src="https://github.com/user-attachments/assets/46f33906-1e89-4043-9d1c-5723d02e0f14" />
<img width="624" height="167" alt="image" src="https://github.com/user-attachments/assets/7170eacc-d3a1-40af-acb6-950a64979d92" />

- использовать ранний выход в правилах политик
 <img width="624" height="332" alt="image" src="https://github.com/user-attachments/assets/b733816d-67ed-4036-a68d-d225b9353bc0" />
 
- минимизация новых переменных или дублирования кода
<img width="624" height="262" alt="image" src="https://github.com/user-attachments/assets/985f45c0-f1e6-4ef7-8ff7-60696adbaa95" />

- минимизация кол-во итераций поиска
<img width="624" height="239" alt="image" src="https://github.com/user-attachments/assets/edb0eab1-cd96-42a6-8fb3-b883c4e16676" />

- минимизация кол-ва правил внутри одной политики
<img width="396" height="222" alt="image" src="https://github.com/user-attachments/assets/ab185de1-52f1-4eba-ae6e-b8bc1ee8f7e7" />

```rego
# O(1): Константная сложность. Время выполнения алгоритма не зависит от размера входных данных. Например, доступ к элементу массива по индексу
input.x == "foo"
input.x.y == "bar"
input.x[0] == "foo"
input.x == ["foo", i]

# O(n): Линейная сложность. Время выполнения алгоритма пропорционально размеру входных данных. Например, итерация или просмотр всех элементов в массиве
input.x == upper("foo")
input.x == data.y
roles[input.user][_] == "admin"
x := input[_]
input.x[i] == "foo"
input.x[_] == "foo"
input.x[input.y] == "foo"
func(data.rbac) # передача через функцию глобальной переменной, например всю ролевую модель. Внутри это создать новую локальную переменную

# O(n^2): Квадратичная сложность. Время выполнения алгоритма зависит от квадрата размера входных данных. Например, итерация двух массивов
func(x, y)  {
	foo := x[_]
	bar := y[_]
    foo == bar
}

# Аналогично плохой варинат с перебором 2-ой сложности
example_2 {
	A[_] == B[_]
}
```
Для наглядности сравнение индексируемых переменных и источников


##### 3. Не использовать затратные функции или обьемные датасеты
Затратные функции - это http.send, либо передача большого размера data

### Способы дебага
##### 1. Получить можно через regal debugger 
<img width="502" height="299" alt="image" src="https://github.com/user-attachments/assets/efd79f77-b7d3-44dd-b918-efa1d48fb152" />

```
#  Примеры плохих и хороших паттернов для оценки и сравнение с оптимизированным подходом

# Передача в переменную больших данных. На примере Создается локальная переменная `__local10__` куда присваивается значение всего data.rbac Что по сути дублиует data.json. Если таких операций несколько - увеличивает обьем CPU и RAM
#9: 1 | Eval __local10__ = data.rbac (c:\Users\Admin\Desktop\Project\opa\task_8\task_8.rego:10) 

# ОК. Исправленный вариант. Обращение к конкретному объекту data без создания локальной переменной
#9: 1 | Eval foo = data.rbac.objectDict.AbsenceLimitsDictionary_ALL.Copy (c:\Users\Admin\Desktop\Project\opa\task_8\task_8.rego:15)

# ОК. Использование раннего выхода, см. matched 1 rule, early exit
#5: 0 | Index data.test.is_admin (matched 1 rule, early exit) (Unknown Source:1)
```

##### 2. Eval
```
$  opa eval --data .\task_8.rego -i .\input.json -d .\data.json --profile --format=pretty 'data.test.allow' --var-values --explain=full # обязательно передать все файлы data и input для полного расчета
.\task_8.rego:23     | | Eval mul(b, c, __local8__)                         {b: 2, c: 3}
.\task_8.rego:23     | | Eval plus(a, __local8__, __local9__)               {__local8__: 6, a: 1}
.\task_8.rego:19     | | Exit data.task_8.p early                           {}
query:1              | Exit data.task_8.p = _                               {_: true, data.task_8.p: true}
query:1              Redo data.task_8.p = _                                 {_: true, data.task_8.p: true}
```

##### 3. Метрики в процессе исполнения
```
POST /opa?metrics=true
Content-Type: application/json

POST /opa?explain=debug
Content-Type: application/json

Чтобы понять что значат значения, см. https://www.openpolicyagent.org/docs/ir
Чтобы понять какие параметры еще можно запросить см. https://www.openpolicyagent.org/docs/rest-api#get-a-document-with-input
```

### Какой способ когда использовать
Квадратичная сложность - легче всего поймать через eval, ключевое при передаче массива ставить исковое верное значение - последним значением, так можно понять сколько итераций может быть<br>
Линейная сложность - лучше всего ищется через метрики в процессе исполнения, либо через regal debugger при выявлении локальных переменных `__local10__`

### Парадигмы составления политик
```rego
# RBAC. Использование some и contains
allow if {
	some role_name
	user_has_role[role_name]
	role_has_permission[role_name]
}

role_has_permission contains role_name if {
	input.permission := role.name
}
```

```rego
# Переиспользование метода декодирования токена. Сокращение кол-ва операций
# Файл utils
package tools
jwt_decoded := io.jwt.decode(input.jwt)

# Файл рабочий test
package test
import data.tools.jwt_decoded
token := jwt_decoded[1]
```
