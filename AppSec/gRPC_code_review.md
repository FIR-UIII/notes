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

### Инструменты
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
