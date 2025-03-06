### Установить OPA

**Shortcuts**
```
@command:opa.eval.package
{
  "key": "ctrl+e",
  "command": "opa.eval.package",
  "when": "editorLangId == 'rego'"
}
@command:opa.eval.selection
{
  "key": "ctrl+d",
  "command": "opa.eval.selection",
  "when": "editorLangId == 'rego'"
}
```

### Памятки и документация
https://www.openpolicyagent.org/docs/latest/

### Оптимизация правил
* `1-100 ms` средний показатель
* `>1 ms` высокий показатель, высоконагруженные системы
Рекомендации: https://academy.styra.com/courses/opa-performance
1. Не плодить лишних локальных переменных и повторы кода  - оптимизировать и обьединять.
2. Использовать индексацию правил для построения дерева инструкций
    `<ref> = scalar | array | var`
    `input.x` > хорошо
    `input.x[i]` > плохо 
    `input.x[input.y]`> плохо nested
3. Используй {dictionary:1} для поиска по ключу
4. Используй реже [Array] для поиска по индексу
5. Используй чаще {set} для поиска совпадений
6. Используй воронку условий Early Exit от общего к частному
7. Снижение кол-ва итерации 
    - (до 1000 знач.) > ок, больше лучше изменить список на obj/dict или set
        A := [1,2]; is_1 { A[1] == 1 } - две итерации
        A := {1,2}; is_1 { A[1] } - одна итерация
    - nested iteration > плохо нужно снизить сложность перебора
        some a in X
        some b in Y - если в X и Y будет по 3 значения = 9 итераций.
		Лучше заменить Y на set [ a | some number in input.B; a := abs(number) ]
    - ресурсозатраные функции например http.send убрать в отдельное правило

### Поиск ошибок
```bash
opa test . --var-values # визуализирует в терминале данные при обработке
opa check --strict --v1-compatible path/to/polices # проверка синтаксиса, типичных ошибок, неиспользуемых переменных и проч.
regal lint path/to/polices # проверка синтаксиса
opa fmt path/to/polices # приведение к одному формату
```

### Тесты и сбор метрик производительности
Название правил для теста должны начинаться `test_`. А название файла с тестами заканчиваться на `_test.rego`

```bash
### Unit тест
opa test . -v # запустить все тесты
opa test -v --bench {path_rule.rego} {path_test.rego} # конкретный тест с бенчмарком

### Профилирование. Выявление проблем в конкретной политике (профиле)
opa eval data.lab.test_rule -d .\task_4\task_4.rego -i input.json --profile --count=10 --format=pretty  # count определяет кол-во запусков теста

+------------------------------+---------+
|            METRIC            |  VALUE  |
+------------------------------+---------+ # все показатели в наносекундах https://www.unitconverters.net/time/nanosecond-to-second.htm
| timer_rego_data_parse_ns     | 0       | # время на парсинг файлов
| timer_rego_load_files_ns     | 4227800 | # время на загрузку файлов
| timer_rego_module_compile_ns | 1217900 | # время на компилирование файлов 
| timer_rego_module_parse_ns   | 0       | # время на парсинг политики .rego
| timer_rego_query_compile_ns  | 0       | # время на компилирование политик .rego
| timer_rego_query_eval_ns     | 0       | # время на исполнение правил в политике
| timer_rego_query_parse_ns    | 0       | # время на парсинг правил в политике
+------------------------------+---------+

# TIME - время на выполнение данной строки LOCATION. Внимание > 100
# NUM EVAL - кол-во вызовов этой строки в политике. Внимание > 1000
# NUM REDO - кол-во операций внутри этой строки зафиксировано. Внимание > 1000
# NUM GEN EXPR - кол-во выражений созданной этой строкой
+------+----------+----------+--------------+------------------------+
| TIME | NUM EVAL | NUM REDO | NUM GEN EXPR |        LOCATION        | 
+------+----------+----------+--------------+------------------------+
| 0s   | 1        | 1        | 1            | .\task_4\task_4.rego:8 | 
+------+----------+----------+--------------+------------------------+

### Полноценный тест (симулиция)
opa bench -d {path_rule.rego} -i input.json 'data.task_1.result' # тест правила
opa bench -b ./policy-bundle -i input.json 'data.task_1.result' # тест bundle и input 

+-------------------------------------------+------------+
| samples                                   |     134761 | # кол-во симуляций
| ns/op                                     |       9229 | # среднее время на выполнение
| B/op                                      |       6401 | # среднее кол-во byte RAM
| allocs/op                                 |        106 | #
| histogram_timer_rego_query_eval_ns_75%    |          0 | #
| histogram_timer_rego_query_eval_ns_90%    |          0 | #
| histogram_timer_rego_query_eval_ns_95%    |          0 | #
| histogram_timer_rego_query_eval_ns_99%    |     506842 | #
| histogram_timer_rego_query_eval_ns_99.9%  |     508880 | #
| histogram_timer_rego_query_eval_ns_99.99% |     508900 | #
| histogram_timer_rego_query_eval_ns_count  |     134761 | #
| histogram_timer_rego_query_eval_ns_max    |     508900 | #
| histogram_timer_rego_query_eval_ns_mean   |       8213 | #
| histogram_timer_rego_query_eval_ns_median |          0 | #
| histogram_timer_rego_query_eval_ns_min    |          0 | #
| histogram_timer_rego_query_eval_ns_stddev |      61427 | #
+-------------------------------------------+------------+

### HTTP запррос с метриками
POST /v1/data/example?metrics=true HTTP/1.1 # добавление в запрос ?metrics для получение информации
```

### Системные оптимизации (развертывание агента)
Localhost := Деплой на одной машине - как служба - процесс (общение через UNIX socket localhost)
Sidecar   := Деплой внутри одного пода (трафик внутри пода)
Proxy     := Деплой через проксирование (nginx, envoy)
Расчет нагрузки (примерно):
    100 правил -> 1Mb RAM
    10k правил -> 100Mb RAM
    100k правил -> 1Gb RAM

### Сборка без подписания
```bash
opa build -b .
opa build example.rego # создание бандла из одной политики
```

### Запустить сервер:
```bash
opa run bundle.tar.gz
> data # проверить что вошло в бандл

# Запуск с указанием условиев в конфигурационном файле
https://www.openpolicyagent.org/docs/latest/configuration/setting-configuration-via-cli-arguments
# Сами конфигурации - https://www.openpolicyagent.org/docs/latest/configuration/
opa run -s -c opa-conf.yaml --addr 127.0.0.1:8181

# Запуск с указанием условиев в терминале
opa run -s --log-level debug --addr 127.0.0.1:8181
    
tty1$ opa run -s \
    --set bundles.example.resource=bundle.tar.gz \
    --set services.example.url=http://localhost:8080
tty2$ python3 -m http.server 9000 --bind localhost

opa run -s .\task_1\task_1.rego .\data.json --log-level debug --addr 127.0.0.1:8181
opa run --verification-key secret --signing-alg HS256 --bundle bundle.tar.gz
```

### Обращение к серверу API
ВАЖНО! через web UI opa не отрабатывает корректно. Лучше обращаться через API
Docs: https://www.openpolicyagent.org/docs/latest/rest-api/

```sh
# POST http://127.0.0.1:8181/v1/data/<package_name>/<rule> --data-raw '{"input": {"name": "John","age": 25}}'

fetch("http://127.0.0.1:8181/v1/data/task_1/result", {
  "body": '{"input": {"name": "John","age": 25}}',
  "method": "POST"
});
ИЛИ
curl http://localhost:8181/v1/data/task_1/result -X POST --data "{\"input\": {\"name\": \"John\",\"age\": 25}}"

curl http://127.0.0.1:8181/v1/data # получить файл data.json
curl http://127.0.0.1:8181/v1/policies # получить политику rego в формате json
```

### Безопасность
##### Аутентификация и авторизация
Через CLI > https://www.openpolicyagent.org/docs/latest/security/#authentication-and-authorization
Через conf.yaml > https://www.openpolicyagent.org/docs/latest/configuration/#bearer-token 
```sh
$ opa run -c .\opa-conf.yaml -s .\task_1\task_1.rego .\data.json .\auth.rego --log-level debug --addr 127.0.0.1:8181 --authentication=token --authorization=basic

### auth.rego
package system.authz
default allow := false          # Reject requests by default.
allow {                         # Allow request if...
    input.identity == "secret"  # Identity is the secret root key.
}
### end
```

Запрос
```sh
curl http://localhost:8181/v1/data -H "Authorization: Bearer secret"
> OK 200
```

##### TLS
```sh
openssl genrsa -out https_private.key 2048
openssl req -new -x509 -sha256 -key https_private.key -out https_public.crt -days 365

opa run -s .\task_1\task_1.rego .\data.json --log-level debug --addr 127.0.0.1:8181 --tls-cert-file .\certs\https_public.crt --tls-private-key-file .\certs\https_private.key

### test
curl http://localhost:8181/v1/data 
  > Error Client sent an HTTP request to an HTTPS server.
curl -k https://localhost:8181/v1/data
  > 200 OK
```

##### Подписание образов bundle (см. выше)
Через conf.yaml > https://www.openpolicyagent.org/docs/latest/configuration/#bundles
https://www.openpolicyagent.org/docs/latest/management-bundles/#signing

```sh
# создание ключевой пары
openssl genpkey -algorithm RSA -out private_key.pem -pkeyopt rsa_keygen_bits:2048
openssl rsa -pubout -in private_key.pem -out public_key.pem
  > private_key.pem + public_key.pem

# создание подписи .signatures.json для бандла с политиками в каталоге task_1
opa sign --signing-key .\certs\private_key.pem --bundle .\task_1\
  > .signatures.json
mv .signatures.json .\task_1\

# сборка бандла и подписание с политиками в каталоге task_1
opa build -b .\task_1\ --verification-key .\certs\public_key.pem --signing-key .\certs\private_key.pem
  > bundle.tar.gz

$ tar tzf bundle.tar.gz
  .manifest
  .signatures.json
  [...]

$ awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' public_key.pem > public_key.cer

### cong.yaml
services:
  dev:
    url: http://localhost:9000

bundles:
  policy:
    service: dev
    resource: bundle.tar.gz
    signing:
      keyid: verifier
keys:
  verifier:
    key: "-----BEGIN PUBLIC KEY-----..."
### end

$ opa run --server --config-file=opa-conf.yaml --addr 127.0.0.1:8181 --log-level debug
> {"level":"info","msg":"Bundle loaded and activated successfully.","name":"policy","plugin":"bundle","time":"2025-02-25T09:49:46+03:00"}
```
