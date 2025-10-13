### Big O
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

example_2 {
	A[_] == B[_]
}

# O(log n): Логарифмическая сложность. Время выполнения алгоритма растет медленно с увеличением размера входных данных. Например, бинарный поиск в отсортированном массиве.# O(n log n): Линейно-логарифмическая сложность. Время выполнения алгоритма растет быстрее, чем линейно, но медленнее, чем квадратично. 
# O(n^3): Кубическая сложность. Время выполнения алгоритма зависит от размера входных данных в кубе. Например, алгоритмы, которые имеют три вложенных цикла, такие как некоторые методы многомерной обработки данных
# O(n!): Факториальная сложность. Это самая высокая степень роста времени выполнения алгоритма. Время выполнения алгоритма растет факториально от размера входных данных. Этот тип сложности встречается, например, при переборе всех возможных комбинаций элементов, что делает его чрезвычайно неэффективным для больших значений n
```

### Способы дебага
##### 1. Получить можно через regal debugger 
```
#  regal debugger
#14: 2 | Eval foo = data.c.objectDict.AbsenceLimitsDictionary_ALL.Copy (c:\Users\Admin\Desktop\Project\opa\task_8\task_8.rego:15) # Вот это хорошо. Так как идет обращение к конкретному объекту data без создания локальной переменной
#13: 2 Enter data.task_8.allow (c:\Users\Admin\Desktop\Project\opa\task_8\task_8.rego:14) # вход в функцию
Можно также ориентироваться по номеру #X: 1
#9: 1 | Eval __local10__ = data.c (c:\Users\Admin\Desktop\Project\opa\task_8\task_8.rego:10) # Вот это плохо. Что происходит создается локальная переменная `__local10__` куда присваивается значение всего data.c. Что по сути дублиует data.json
#7: 1 | Eval all = true (c:\Users\Admin\Desktop\Project\opa\task_8\task_8.rego:11) # проверка условия в {...}
#6: 1 Enter data.task_8.allow (c:\Users\Admin\Desktop\Project\opa\task_8\task_8.rego:10) # вход в функцию

#5: 0 | Index data.test.is_admin (matched 1 rule, early exit) (Unknown Source:1) # вот это отлично значит работает ранний выход и правило легко индексируется
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
POST /auth/realms/IAM/protocol/authz/atomid/skillaz/rbac?metrics=true
Content-Type: application/json
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
