# Security Code Review Checklist: gRPC (Go)

## 1. Аутентификация и авторизация

### Проверить

* Есть ли аутентификация для каждого RPC (отдельно для каждого метода или используется общий interceptor)
* Выполняется ли авторизация внутри каждого обработчика
* Не доверяет ли сервер данным из запроса (`user_id`, `role`, `tenant_id`)
* Проверяются ли ownership и ACL

### Уязвимый пример

```proto
message DeleteUserRequest {
    string user_id = 1;
}
```

```go
func (s *Server) DeleteUser(ctx context.Context, req *pb.DeleteUserRequest) (*emptypb.Empty, error) {
    return s.repo.Delete(req.UserId)
}
```

Любой пользователь способен удалить любого пользователя.

### Безопасно

Получать идентификатор пользователя только из JWT/mTLS/interceptor.

```go
user := auth.UserFromContext(ctx)
```

---

# 2. Transport Security

Проверить

* Используется ли TLS
* Проверяется ли сертификат клиента (если требуется mTLS)
* Не используется ли `grpc.WithInsecure()`

---

# 3. Input Validation

Проверить

* UUID
* email
* enum
* диапазоны
* длину строк
* регулярные выражения

Лучше использовать

```protobuf
protoc-gen-validate
```

или

```protobuf
Protovalidate
```

---

# 4. Information Disclosure

## Проверить

Не возвращаются ли внутренние модели БД клиенту.

### Уязвимый пример

```proto
message User {
    string id = 1;
    string username = 2;
    string password_hash = 3;
    string internal_role = 4;
}
```

```go
return &pb.User{
    Id: dbUser.ID,
    Username: dbUser.Username,
    PasswordHash: dbUser.PasswordHash,
    InternalRole: dbUser.InternalRole,
}
```

### Безопасно

Использовать отдельные DTO.

```proto
message PublicUser {
    string id = 1;
    string username = 2;
}
```

---

# 5. Mass Assignment

Проверить

Не используется ли protobuf-модель напрямую для обновления ORM.

Плохой пример

```go
db.Model(&user).Updates(req)
```

Лучше

```go
user.Name = req.Name
user.Email = req.Email
```

---

# 6. Field Tag Confusion

## Проверить

Не переиспользуются ли номера protobuf-полей.

### Уязвимо

```proto
message UpdateProfileRequest {
    string user_id = 1;
    bool is_admin = 2;
}
```

Позже

```proto
message UpdateProfileRequest {
    string user_id = 1;
    string new_password = 2;
}
```

Старые клиенты будут интерпретировать поле иначе.

### Безопасно

```proto
reserved 2;
reserved "is_admin";

string new_password = 3;
```

---

# 7. Integer Overflow

Проверить

* int32/int64
* uint
* преобразования типов

Например

```go
size := int(req.Size)
```

---

# 8. DoS через repeated

Проверить

Есть ли ограничения на количество элементов.

Уязвимо

```proto
repeated string payload = 1;
```

```go
results := make([]string, len(req.Payload))
```

Пользователь может отправить миллионы элементов.

Проверять

```go
if len(req.Payload) > 1000 {
    return nil, status.Error(...)
}
```

---

# 9. DoS через bytes

Уязвимо

```proto
bytes file = 1;
```

gRPC сначала полностью загрузит сообщение в память.

Лучше использовать streaming RPC.

---

# 10. Streaming Security

Проверить

* ограничение количества сообщений
* ограничение общего размера
* deadline
* timeout
* context cancellation

---

# 11. Max Receive Size

Проверить

Настроены ли

```go
grpc.MaxRecvMsgSize(...)
grpc.MaxSendMsgSize(...)
```

Иначе возможно OOM.

---

# 12. Metadata Security

Проверить

* Authorization
* x-user-id
* x-role

Нельзя доверять пользовательским metadata.

---

# 13. Deadlines

Проверить

Используется ли

```go
context.WithTimeout()
```

или

```go
grpc-timeout
```

Без deadline возможны зависшие соединения.

---

# 14. Error Handling

Проверить

Не возвращаются ли

* stack trace
* SQL
* filesystem path
* internal error

Использовать

```go
status.Error(codes.PermissionDenied, ...)
```

вместо

```go
fmt.Errorf(...)
```

---

# 15. Reflection

Проверить

В production желательно отключать

```go
reflection.Register(server)
```

иначе злоумышленник может получить описание всех сервисов.

---

# 16. Over-Exposed Interface

Проверить

Нет ли внутренних RPC рядом с публичными.

Уязвимо

```proto
service UserService {

    rpc GetProfile(...);

    rpc DebugDumpDatabase(...);

    rpc HardResetPassword(...);

}
```

Лучше

```proto
service PublicUserService

service InternalAdminService
```

И публиковать только Public.

---

# 17. Rate Limiting

Проверить

Есть ли ограничения

* на RPC
* на IP
* на пользователя

---

# 18. Logging

Проверить

Не логируются ли

* JWT
* пароль
* refresh token
* grpc metadata
* file contents

---

# 19. Secrets

Проверить

Не передаются ли

```proto
string api_key
```

или

```proto
string password
```

в ответах.

---

# 20. gRPC-Gateway Security

Если используется grpc-gateway:

Проверить

* все ли методы действительно должны быть доступны по HTTP
* нет ли внутренних RPC
* корректно ли работают middleware
* одинаковы ли политики авторизации для REST и gRPC

---

# 21. Interceptors

Проверить

Подключены ли

* Authentication
* Authorization
* Logging
* Recovery
* Rate Limit
* Validation

Именно через interceptor обычно реализуются security-механизмы.

---

# 22. Протокол и эволюция API

Проверить

* не переиспользуются ли field tags
* используются ли `reserved`
* не меняются ли типы существующих полей
* не удаляются ли поля без резервирования
* не меняется ли семантика enum

---

# ====================================
### Общая логика
```
1. Определение контракта
Разрабатывается .proto-файл с описанием сервиса, методов (unary, streaming) и структур данных (сообщений).
Из этого файла генерируются клиентские и серверные заглушки (stubs) на нужном языке.

2. Установка соединения (HTTP/2 over TCP | UnixSocket) и передача данных
Клиент                     HTTP/2                     Сервер
   │                         │                          │
   ├─── Создать канал ──────►│                          │
   │                         ├────── Установка соединения ───►
   │                         │                          │
   ├─── Вызвать метод ──────►│                          │
   │   (сериализация)       ├── HEADERS + DATA ────────►│
   │                         │                          ├── десериализация
   │                         │                          ├── вызов обработчика
   │                         │                          ├── сериализация ответа
   │                         │◄── HEADERS + DATA ──────┤
   │                         │◄── TRAILERS ────────────┤
   ├─── получить ответ ─────►│                         │
   │   (десериализация)     │                          │
```

### Безопасность gRPC
```
Layer	          Security Concern	                  Potential Impact            Security
Transport (TLS)	Plaintext / weak ciphers / no mTLS	Credential and data theft   Enforce TLS 1.3 + mTLS
HTTP/2	        HPACK bombs, window exhaustion	    Denial of service           MaxRecvMsgSize + depth cap
Reflection API	Schema disclosure	                  Recon / attack planning     Disable reflection in prod
Protobuf parser	Recursive or oversized messages	    Memory exhaustion, crash
Metadata	      Token leakage, header smuggling	    Auth bypass, log poisoning  Verify token signature, exp, aud, iss	
Interceptors	  Missing/ordered incorrectly	        Authz bypass
Streams	        Long-lived, unbounded	              Resource exhaustion
Handlers	      Injection / IDOR / RCE	            Data breach, takeover
```

#### Атаки:
> В gRPC существует server reflection, это схожий механизм с introspection в GraphQL: сервис может отдавать свой API‑контракт (методы, сообщения, типы) динамически
> Protobuf manipulation
```
отправка неожиданных значений для enum/required полей;
плохая обработка неизвестных полей (unknown fields);
манипуляции со streaming RPC;
использование нестандартных пакетов данных для тестирования парсинга.
Такие манипуляции могут привести к логическим сбоям, ошибкам десериализации, непредсказуемому поведению.
```

### Code review
```proto
syntax = "proto3";

package payments.v1;

service PaymentService {
  // Unary - standard risks
  rpc GetPayment(GetPaymentRequest) returns (Payment);

  // Client streaming - attacker controls message count
  rpc ImportPayments(stream Payment) returns (ImportResult);

  // Server streaming - server keeps sending
  rpc StreamLedger(LedgerQuery) returns (stream LedgerEvent);

  // Bidirectional streaming - long-lived, hardest to secure
  rpc Reconcile(stream ReconcileCmd) returns (stream ReconcileAck);
}

message Payment {
  string id = 1;
  string user_id = 2;    // IDOR risk - is caller allowed to read this?
  int64 amount_cents = 3;
  string raw_metadata = 4;   // Free-text field - injection into downstream?
  repeated Payment related = 5;  // Self-reference - recursion/zip-bomb
}
```

> no TLS
```vuln_server.go
// VULNERABLE: plaintext server
lis, _ := net.Listen("tcp", ":50051")
s := grpc.NewServer() // No TLS credentials!
pb.RegisterPaymentServiceServer(s, &server{})
s.Serve(lis)

// VULNERABLE: plaintext client
conn, _ := grpc.Dial(
    "payments.internal:50051",
    grpc.WithTransportCredentials(insecure.NewCredentials()),
)

// VULNERABLE: TLS but skipping verification
conn, _ := grpc.Dial(
    "payments.internal:50051",
    grpc.WithTransportCredentials(credentials.NewTLS(&tls.Config{
        InsecureSkipVerify: true, // accepts any cert!
    })),
)
```

> no AuthN
```vuln_server.go
// VULNERABLE: trusting x-user-id set by a gateway,
// but the service is also reachable directly
func (s *server) GetPayment(ctx context.Context, req *pb.GetPaymentRequest) (*pb.Payment, error) {
    md, _ := metadata.FromIncomingContext(ctx)
    userID := md.Get("x-user-id")[0] // attacker can just set this header
    return s.store.GetForUser(userID, req.Id)
}

// VULNERABLE: no auth at all — relies on "only internal callers"
func (s *server) DeletePayment(ctx context.Context, req *pb.DeletePaymentRequest) (*emptypb.Empty, error) {
    return &emptypb.Empty{}, s.store.Delete(req.Id)
}

// VULNERABLE: validates token but never checks scope/audience
func authFromMetadata(ctx context.Context) (*User, error) {
    md, _ := metadata.FromIncomingContext(ctx)
    raw := md.Get("authorization")[0]
    token := strings.TrimPrefix(raw, "Bearer ")
    claims, _ := jwt.ParseUnverified(token) // !!
    return &User{ID: claims["sub"].(string)}, nil
}
```

> DoS via Streams & Messages
```vuln_server.go
// VULNERABLE: no limits on anything
s := grpc.NewServer(grpc.Creds(creds))
// - No MaxRecvMsgSize (default 4 MB — but handler may still OOM)
// - No MaxConcurrentStreams (unlimited per connection)
// - No ConnectionTimeout
// - No KeepaliveEnforcementPolicy
// - No timeouts on handlers
// - No recursion / depth limits on protobuf parsing
```

### Tools
`grpcurl` <br>
```bash
# List every service on the server
grpcurl payments.example.com:443 list

# List methods on a service
grpcurl payments.example.com:443 list payments.v1.PaymentService

# Describe the full request/response schema
grpcurl payments.example.com:443 describe payments.v1.Payment

# Call a method with no prior knowledge
grpcurl -d '{"id": "p_123"}' payments.example.com:443 \
payments.v1.PaymentService/GetPayment
```
    
Burp extension `InQL`
