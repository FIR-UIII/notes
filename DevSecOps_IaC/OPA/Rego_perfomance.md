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