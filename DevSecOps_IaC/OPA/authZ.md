Пример поступающего сообщения (полный input)
```
{
   "client_addr":"127.0.0.1:53231",
   "level":"info",
   "line":"/auth.rego:10",
   "msg":"{\"body\": {\"input\": {\"age\": 19}}, \"headers\": {\"Accept\": [\"*/*\"], \"Accept-Encoding\": [\"gzip, deflate, br\"], \"Authorization\": [\"Bearer eyJhbGciO..."], \"Cache-Control\": [\"no-cache\"], \"Connection\": [\"keep-alive\"], \"Content-Length\": [\"21\"], \"Content-Type\": [\"application/json\"], \"Postman-Token\": [\"b1695af6-c523-4f94-8a74-d9ff9ebbbd93\"], \"User-Agent\": [\"PostmanRuntime/7.29.2\"]}, \"identity\": \"eyJhbGciO...", \"method\": \"POST\", 
\"params\": {}, \"path\": [\"v1\", \"data\", \"task_1\"]}",
   "req_id":1,
   "req_method":"POST",
   "req_path":"/v1/data/task_1",
   "time":"2025-10-06T09:20:46+03:00"
}{
   "client_addr":"127.0.0.1:53231",
   "level":"info",
   "msg":"Sent response.",
   "req_id":1,
   "req_method":"POST",
   "req_path":"/v1/data/task_1",
   "resp_body":"{\"result\":{\"result\":\"allowed\"}}\n",
   "resp_bytes":32,
   "resp_duration":37.8934,
   "resp_status":200,
   "time":"2025-10-06T09:20:46+03:00"
}
```

Запуск сервера
```
--authentication {token,​tls,​off} # включает правило откуда будет принимать аутентификатор
# token означает что будет парситься поле из заголовка Authorization: Bearer <HERE>
# tls означает что будет парситься сертификат и значение certificate's subject. И обязательно будет правка по корневому серту переданному в OPA через --tls-ca-cert-file
--authorization	{basic,​off} # включает авторизацию запросов по политике rego с пакетом system.authz или нет
```

Сценарий 1. Аутентификация по простому токену, не JWT структуры
```
package system.authz

default allow := false          # Reject requests by default.

allow {                         # Allow request if...
    input.identity == "secret"  # Identity is the secret root key.
}
```
Запуск сервера обязателен с флагам --authentication и --authorization
```
opa run -s -b .\bundle.tar.gz --log-level debug --addr 127.0.0.1:8181 --authentication=token --authorization=basic
```

Запрос. Особое внимание на заголовок Authorization: Bearer secret, где secret присваивается к переменной input.identity в политике rego
```
GET /v1/data HTTP/1.1
Host: 127.0.0.1:8181
Content-Type: application/json
Authorization: Bearer secret
```

Без заголовка Authorization, ответ будет
```
{
  "code": "unauthorized",
  "message": "request rejected by administrative policy"
}
```

Сценарий 2. Аутентификация по JWT токену
```
package system.authz

default allow := false

allow := true {
	input.path == ["v1", "config"]
	io.jwt.decode(input.identity)[1]["azp"] == "integration_test"
	token_verify.valid
}
```

Запуск сервера обязателен с флагам --authentication и --authorization
```
opa run -s -b .\bundle.tar.gz --log-level debug --addr 127.0.0.1:8181 --authentication=token --authorization=basic
```

Сценарий 3. Разрешение на определенные пути без аутентификации
```
package system.authz

# Deny access by default.
default allow := false

# Allow anonymous access to the default policy decision.
allow := true {
	input.method == "POST"
    io.jwt.decode(input.identity)[1].azp == "integration_test"
}

allow := true {
	input.method == "GET"
	input.path == ["v1", "data", "task_1"]
}
```

