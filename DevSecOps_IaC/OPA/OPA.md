# Docs
https://www.openpolicyagent.org/docs/latest/policy-reference/#assignment-and-equality
https://play.openpolicyagent.org/
https://academy.styra.com/courses/take/opa-rego/
https://docs.styra.com/opa/rego-cheat-sheet 

# Architecture
```
+---+              +---------------+                    +----------+
| O | --request--> |   AS   [proxy]| --request input--> | OPA      | <----> data
|/|\|              |      [sidecar]| <--decision------- |          | <----> REGO policy / rules
|/ \|              |               |                    |          |
+---+              +---------------+                    +----------+
```

# Rules
Всегда проверять правила unit тестами
90% правил составляют IF условия

```Go
// Input 
{
  "user": {
    "role": "admin",
    "internal": true
  }
}

// Rule
default allow := false

allow if {
	input.user.role == "admin"
	input.user.internal
}
default request_quota := 100
request_quota := 1000 if input.user.internal
request_quota := 50 if input.user.plan.trial
```

# Syntax
```Go
// Работа с переменными
1. allow := false 
2. set := {"user", "admin", "auditor"}                         // set["user"] => true
3. dict_obj := {"role": "user", "actions": ["read", "write"]}  // dict_obj["role"] => user
    dict_obj["role"] := "auditor" // add {"role": "auditor"}
    dict_obj["user is unauthenticated"] = true { true } // add {"user is unauthenticated": true}
    dict_obj[x] = y {x := "abc"; y := "def" } // add {"abc": "def"}
    dict_obj[y] = "pqr" { y := "mno" } // add {"mno": "pqr"}
4. array := ["user", "admin", "auditor"]                       // array[1] => user
    deny["Unsafe image"] { 
      check_unsafe_image // если хелпер вернет true то в deny добавитсяW значение в [...]
      msg := sprintf("%v has unsafe image", [input.request.name]) // выводим сообщение в консоль
    } 
5. function("a_parameter") := "a_return_value" // присвоение вывода для функции
    function(param) := parts { image_version := split(param, ":"); path := split(image_version[0], "/") }

// присвоение с условием AND
allow := true { 
    // allow будет true, если input.request.method равен GET AND input.request.token равен admin
    input.request.method == "GET"
    input.request.token == "admin"}
allow { ... } // тоже самое что и выше только без := true

// присвоение с условием OR
is_read { input.request.method == "GET" } // is_read будет true если input.request.method равен GET OR input.request.method равен POST
is_read { input.request.method == "POST" }

// присвоение значения по умолчанию
default is_read = false

// присвоение переменной значения при предварительном условии 
code := 200 { allow } // code будет присвоено значение 200 если переменная allow равна true
code := 403 { not allow }

// Построение правил
// Option 1. action_is_read AND user_is_aithenticated OR action_is_read AND path_is_root
allow {
    action_is_read
    user_is_aithenticated
}
allow {
    action_is_read
    path_is_root
}

// Option 2. Через вызов функций помошников. action_is_read AND user_is_aithenticated OR path_is_root
allow {
    action_is_read
    function
}
function { user_is_aithenticated } // Helper 1
function { path_is_root } // Helper 2

// Циклы, итерации, проверки - декларативный синтаксис
1. input.user == admins[i] // способ 1 проверка наличия в input.user
2.  some i
      input.user == admins[i] // способ 2
    some index; value := arr[index]
    some key; value := obj[key]
    some value; set[value]

3. Проверка в Arrays [массив]
admins := ["alice", "bob"] // базовые данные
admins2 := [{"user":"alice", "level":1},{"user":"bob", "level":2}] // базовые данные 2

is_admin { // is_admin будет true, если
  some i // есть такое некое значение i ...
    admins[i] == user.input // где i из admins равно user.input
    admins2[i].level == 1 // и где i из admins2 равно 1
}

4. Проверка в Set {список}
admins := {"alice", "bob"} // базовые данные
is_admin { admins[user.input] } // true
is_admin { // is_admin будет true, если
  some name // есть такое некое значение name ...
    admins[name] // из set admins с ключом name
    lower(name) == lower(user.input) // где name равно user.input
}

5. Проверка в Objects {dict: словарь}
admins := {"alice": true, "bob": true} // базовые данные
admins2 := {"alice": {"level": 1}, "bob": {"level": 2}} // базовые данные 2

is_admin { admins[input.user] == true } // если input.user := alice
is_admin { // is_admin будет true, если
  some i // есть некий ключ i ...
    v := admins2[i] // и существует такое значение v, где у словаря admins2 есть ключ i
    lower(i) == lower(input.user) // и где значение ключа i равно input.user
}

6. Сложные проверки
// Есть два массива где нужно сравнить и найти общее значение
is_admin { // is_admin будет true,
  some i, j // где некие значения j И i 
    input.groups.[i] == admins[j] // имеют совпадение
}

// Nested iteration
check_groups {
  some i, j
    input.request.groups[i].volumes[j] == true
}

```

# Common Errors
```Go
// Присвоение одной переменной разных значений при одинаковых условиях rez => undefined
foo = true { true } // AND
foo = false { true }

// Итерации с рекурсией или бесконечным перебором (нет лимита) => ERROR: unsafe expression
foo[x] { some x; x > 1 } // больше 1 может быть любое кол-во
foo { some x; not in_array[x]} // не в списке может быть любое кол-во
```

# Policy
Организация набора правил в одну политику `package` 
https://www.openpolicyagent.org/docs/latest/policy-language/#modules 
```Go
package api.ruleset.dev // определяет что код ниже будет является пакетом для обращения
import api.ruleset.dev // dev становиться alias к которому можно обращаться

allow { dev.utils }
```