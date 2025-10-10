### Big O
```rego
# O(1): Константная сложность. Время выполнения алгоритма не зависит от размера входных данных. Например, доступ к элементу массива по индексу
input.x == "foo"
input.x.y == "bar"
input.x == ["foo", i]

# O(n): Линейная сложность. Время выполнения алгоритма пропорционально размеру входных данных. Например, просмотр всех элементов в массиве
roles[input.user][_] == "admin"
x := input[_]
input.x[i] == "foo"
input.x[input.y] == "foo"

# O(log n): Логарифмическая сложность. Время выполнения алгоритма растет медленно с увеличением размера входных данных. Например, бинарный поиск в отсортированном массиве.# O(n log n): Линейно-логарифмическая сложность. Время выполнения алгоритма растет быстрее, чем линейно, но медленнее, чем квадратично. Например, сортировка слиянием (merge sort)

# O(n^2): Квадратичная сложность. Время выполнения алгоритма зависит от квадрата размера входных данных. Например, сортировка пузырьком (bubble sort) или цикл внутри цикла
func(x, y)  {
	foo := x[_]
	bar := y[_]
    foo == bar
}

# O(n^3): Кубическая сложность. Время выполнения алгоритма зависит от размера входных данных в кубе. Например, алгоритмы, которые имеют три вложенных цикла, такие как некоторые методы многомерной обработки данных

# O(n!): Факториальная сложность. Это самая высокая степень роста времени выполнения алгоритма. Время выполнения алгоритма растет факториально от размера входных данных. Этот тип сложности встречается, например, при переборе всех возможных комбинаций элементов, что делает его чрезвычайно неэффективным для больших значений n
```

### Call stack
Получить можно через regal debugger или  `opa eval -d .\task_8.rego --profile --format=pretty 'data.task_8.allow' --var-values --explain=full`
```
#  regal debugger
#14: 2 | Eval foo = data.c.objectDict.AbsenceLimitsDictionary_ALL.Copy (c:\Users\Admin\Desktop\Project\opa\task_8\task_8.rego:15) # Вот это хорошо. Так как идет обращение к конкретному объекту data без создания локальной переменной
#13: 2 Enter data.task_8.allow (c:\Users\Admin\Desktop\Project\opa\task_8\task_8.rego:14) # вход в функцию
Можно также ориентироваться по номеру #X: 1
#9: 1 | Eval __local10__ = data.c (c:\Users\Admin\Desktop\Project\opa\task_8\task_8.rego:10) # Вот это плохо. Что происходит создается локальная переменная __local10__ куда присваивается значение всего data.c. Что по сути дублиует data.json
#7: 1 | Eval all = true (c:\Users\Admin\Desktop\Project\opa\task_8\task_8.rego:11) # проверка условия в {...}
#6: 1 Enter data.task_8.allow (c:\Users\Admin\Desktop\Project\opa\task_8\task_8.rego:10) # вход в функцию

# eval
$  opa eval -d .\task_8.rego 'data.task_8.allow' --var-values --explain=full > call_stack.txt # важно без профилирования делать --profile
query:1              Enter data.task_8.p = _                                {}
query:1              | Eval data.task_8.p = _                               {}
query:1              | Index data.task_8.p (matched 1 rule, early exit)     {}
.\task_8.rego:19     | Enter data.task_8.p                                  {}
.\task_8.rego:20     | | Eval a = 1                                         {}
.\task_8.rego:21     | | Eval b = 2                                         {}
.\task_8.rego:22     | | Eval c = 3                                         {}
.\task_8.rego:23     | | Eval mul(b, c, __local8__)                         {b: 2, c: 3}
.\task_8.rego:23     | | Eval plus(a, __local8__, __local9__)               {__local8__: 6, a: 1}
.\task_8.rego:23     | | Eval x = __local9__                                {__local9__: 7}
.\task_8.rego:19     | | Exit data.task_8.p early                           {}
query:1              | Exit data.task_8.p = _                               {_: true, data.task_8.p: true}
query:1              Redo data.task_8.p = _                                 {_: true, data.task_8.p: true}
query:1              | Redo data.task_8.p = _                               {_: true, data.task_8.p: true}
.\task_8.rego:19     | Redo data.task_8.p                                   {}
.\task_8.rego:23     | | Redo x = __local9__                                {__local9__: 7, x: 7}
.\task_8.rego:23     | | Redo plus(a, __local8__, __local9__)               {__local8__: 6, __local9__: 7, a: 1}
.\task_8.rego:23     | | Redo mul(b, c, __local8__)                         {__local8__: 6, b: 2, c: 3}
.\task_8.rego:22     | | Redo c = 3                                         {c: 3}
.\task_8.rego:21     | | Redo b = 2                                         {b: 2}
.\task_8.rego:20     | | Redo a = 1                                         {a: 1}
```

### Eval
```rego
opa eval --data rbac.rego --profile --format=pretty 'data.rbac.allow'

# rego
package test

p if {
	a := 1
	b := 2
	c := 3
	x = a + (b * c)
}
```

### Парадигмы составления политик
```rego
# RBAC. Использование some и contains
default allow := false

allow if {
	some role_name
	user_has_role[role_name]
	role_has_permission[role_name]
}

role_has_permission contains role_name if {
	role := roles[_]
	role_name := role.name
	perm := role.permissions[_]
	perm.resource == inp.resource
	perm.action == inp.action
}
```

```rego
# RBAC. Использование some и contains
default allow := false

allow if {
	some role_name
	user_has_role[role_name]
	role_has_permission[role_name]
}

role_has_permission contains role_name if {
	role := roles[_]
	role_name := role.name
	perm := role.permissions[_]
	perm.resource == inp.resource
	perm.action == inp.action
}
```

```rego
# RBAC. Использование some и contains
default decision := "deny"

decision := "allow" {
    token_verify.valid
    not wrong_client
    token_decode := io.jwt.decode(input.user_token)[1]
    token_roles := token_decode.resource_access[client_config.client].roles[_]
    input.claims == rbac_policy[token_roles][input.endpoint][input.method]
}
```
