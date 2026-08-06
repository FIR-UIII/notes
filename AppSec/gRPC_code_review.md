# Security Code Review Checklist: gRPC (Go)

### 1. Аутентификация и авторизация
Аутентификация должна устанавливать личность (например, через Keycloak), а авторизация — проверять права (например, отдельный сервис через OPA/SpiceDB/OpenFGA).

// Уязвимо (Доверие клиенту):
```
message DeleteUserRequest {
    string user_id = 1; // Клиент сам говорит, кого удалить и под кем он работает
}

func (s *Server) DeleteUser(ctx context.Context, req *pb.DeleteUserRequest) (*emptypb.Empty, error) {
    // IDOR: Любой пользователь способен удалить любого пользователя
    return s.repo.Delete(req.UserId) 
}
```

// Безопасно (Context & Interceptors):
```
func (s *Server) DeleteUser(ctx context.Context, req *pb.DeleteUserRequest) (*emptypb.Empty, error) {
    // Идентификатор берется строго из токена, проверенного интерцептором
    actorID := auth.UserFromContext(ctx) 
    
    // Проверка прав (например, вызов OpenFGA/SpiceDB: actorID can "delete" req.UserId)
    if !s.authzEngine.Check(ctx, actorID, "delete", req.UserId) {
        return nil, status.Error(codes.PermissionDenied, "access denied")
    }
    return s.repo.Delete(req.UserId)
}
```

### 2. Transport Security
Работа по незашифрованному каналу позволяет перехватывать токены и модифицировать трафик.
Уязвимо:
// Использование insecure credentials в production
creds := insecure.NewCredentials()
s := grpc.NewServer(grpc.Creds(creds))

Безопасно:
// Использование mTLS (взаимная аутентификация) или строгого TLS
creds, err := credentials.NewServerTLSFromFile("server.crt", "server.key")
if err != nil {
    log.Fatalf("Failed to generate credentials: %v", err)
}
s := grpc.NewServer(grpc.Creds(creds))

3. Input Validation
gRPC гарантирует типы данных, но не их бизнес-валидность.
Уязвимо:
func (s *Server) CreateUser(ctx context.Context, req *pb.UserReq) (*pb.UserRes, error) {
    // Нет проверки формата email или отрицательного возраста
    db.Save(req.Email, req.Age) 
}

Безопасно (через protovalidate):
import "buf/validate/validate.proto";

message UserReq {
    string email = 1 [(buf.validate.field).string.email = true];
    int32 age = 2 [(buf.validate.field).int32.gt = 0];
}

import "github.com/bufbuild/protovalidate-go"

func (s *Server) CreateUser(ctx context.Context, req *pb.UserReq) (*pb.UserRes, error) {
    v, _ := protovalidate.New()
    if err := v.Validate(req); err != nil {
        return nil, status.Errorf(codes.InvalidArgument, "validation failed: %v", err)
    }
    // ...
}

4. Information Disclosure
Случайный возврат клиенту внутренних структур БД.
Уязвимо:
// DTO совпадает с моделью БД. Утекают хэши паролей и внутренние роли.
return &pb.User{
    Id: dbUser.ID,
    Username: dbUser.Username,
    PasswordHash: dbUser.PasswordHash, 
}

Безопасно:
// Использование строгого маппинга в Public DTO
return &pb.PublicUser{
    Id: dbUser.ID,
    Username: dbUser.Username,
}

5. Mass Assignment
Передача protobuf-модели напрямую в ORM.
Уязвимо:
// Злоумышленник передал is_admin=true в запросе обновления профиля
db.Model(&user).Updates(req) 

Безопасно:
// Явное присвоение только разрешенных полей
user.Name = req.Name
user.Email = req.Email
db.Model(&user).Updates(user)

6. Field Tag Confusion
Переиспользование номеров удаленных protobuf-полей ломает обратную совместимость и может привести к подмене типов у старых клиентов.
Уязвимо:
// Было: string user_id = 1; bool is_admin = 2;
// Стало:
message UpdateProfileRequest {
    string user_id = 1;
    string new_password = 2; // Переиспользовали тег 2
}

Безопасно:
message UpdateProfileRequest {
    string user_id = 1;
    reserved 2;
    reserved "is_admin";
    string new_password = 3;
}

7. Integer Overflow
Ошибки приведения типов (кастинге) из больших размерностей в меньшие.
Уязвимо:
// req.Size имеет тип uint64, а int в Go на 32-битных системах это int32.
// Переполнение может привести к выделению 0 байт памяти и дальнейшей панике.
size := int(req.Size)
buffer := make([]byte, size) 

Безопасно:
if req.Size > math.MaxInt32 {
    return nil, status.Error(codes.InvalidArgument, "size too large")
}
size := int(req.Size)

8. DoS через repeated
Атака исчерпания памяти (OOM) через огромные массивы.
Уязвимо:
repeated string payload = 1;

// Если клиент пришлет миллион элементов, мы аллоцируем огромный срез
results := make([]string, len(req.Payload)) 

Безопасно:
if len(req.Payload) > 1000 {
    return nil, status.Error(codes.InvalidArgument, "payload too large")
}

9. DoS через bytes
Загрузка больших файлов одним пакетом бьет по оперативной памяти сервера.
Уязвимо:
// gRPC загрузит весь файл в память до вызова обработчика
message UploadReq {
    bytes file_content = 1; 
}

Безопасно:
// Использование потоков (streaming) для чанков фиксированного размера
rpc Upload(stream FileChunk) returns (UploadStatus);

10. Streaming Security
Бесконечные стримы без лимитов и таймаутов.
Уязвимо:
func (s *Server) Upload(stream pb.Service_UploadServer) error {
    var data []byte
    for {
        chunk, err := stream.Recv()
        // Стрим может литься бесконечно, исчерпав RAM
        data = append(data, chunk.Content...) 
    }
}

Безопасно:
func (s *Server) Upload(stream pb.Service_UploadServer) error {
    var totalSize int
    for {
        // Защита от зависших стримов клиента
        if err := stream.Context().Err(); err != nil {
            return err
        }
        chunk, err := stream.Recv()
        totalSize += len(chunk.Content)
        if totalSize > MaxUploadSize {
            return status.Error(codes.ResourceExhausted, "file too large")
        }
        // ...
    }
}

11. Max Receive Size
Дефолтные настройки gRPC допускают размер входящего сообщения до 4 МБ, что иногда слишком много (или мало), что позволяет провести DoS.
Уязвимо:
// Используются настройки по умолчанию
s := grpc.NewServer()

Безопасно:
// Строгое ограничение размера Unary-сообщения (например, 1 MB)
s := grpc.NewServer(
    grpc.MaxRecvMsgSize(1024 * 1024 * 1),
    grpc.MaxSendMsgSize(1024 * 1024 * 1),
)

12. Metadata Security
Доверие заголовкам (metadata), которые может прислать клиент.
Уязвимо:
md, _ := metadata.FromIncomingContext(ctx)
// Злоумышленник может просто передать заголовок "x-role: admin"
role := md["x-role"][0] 

Безопасно:
// Metadata используется только для получения JWT-токена.
// Роли и ID извлекаются сервером после криптографической проверки подписи токена.
claims := validateJWT(md["authorization"][0])
ctx = context.WithValue(ctx, roleKey, claims.Role)

13. Deadlines
Отсутствие таймаутов приводит к зависанию горутин и соединений БД, если внешний сервис или БД тормозит.
Уязвимо:
// Запрос в БД будет висеть бесконечно
db.QueryContext(context.Background(), "SELECT ...") 

Безопасно:
// Передача gRPC-контекста дальше. Если клиент отвалился по своему таймауту,
// запрос в БД автоматически отменится.
func (s *Server) GetData(ctx context.Context, req *pb.Req) (*pb.Res, error) {
    db.QueryContext(ctx, "SELECT ...")
}

14. Error Handling
Утечка stack trace или синтаксиса SQL.
Уязвимо:
if err != nil {
    // Клиент получит текст "Error 1064 (42000): You have an error in your SQL syntax..."
    return nil, status.Errorf(codes.Internal, "database error: %v", err)
}

Безопасно:
if err != nil {
    log.Error("Database query failed", zap.Error(err))
    return nil, status.Error(codes.Internal, "internal server error")
}

15. Reflection
Включенная рефлексия (Server Reflection) позволяет атакующему сдампить всю схему API (эквивалент OpenAPI/Swagger).
Уязвимо:
s := grpc.NewServer()
reflection.Register(s) // Оставлено включенным в Production

Безопасно:
s := grpc.NewServer()
if env == "development" {
    reflection.Register(s)
}

16. Over-Exposed Interface
Смешивание публичных и внутренних админских методов в одном сервисе.
Уязвимо:
service UserService {
    rpc GetProfile(Req) returns (Res);
    rpc HardResetPassword(Req) returns (Res); // Внутренний метод торчит наружу
}

Безопасно:
service PublicUserService {
    rpc GetProfile(Req) returns (Res);
}
service InternalAdminService {
    rpc HardResetPassword(Req) returns (Res);
}
// Слушаем Public на порту 443 (Internet), а Internal на порту 9090 (VPC/Mesh)

17. Rate Limiting
Отсутствие защиты от брутфорса и L7 DDoS.
Уязвимо:
// Сервер обрабатывает запросы с любой скоростью, пока не упадет БД
s := grpc.NewServer() 

Безопасно (Interceptor):
// Использование In-Tap Handle для максимально раннего дропа соединения
// или UnaryInterceptor с Token Bucket алгоритмом
s := grpc.NewServer(
    grpc.UnaryInterceptor(ratelimit.UnaryServerInterceptor(limiter)),
)

18. Logging
Логирование чувствительных данных (PII, пароли, токены).
Уязвимо:
func (s *Server) Login(ctx context.Context, req *pb.LoginReq) (*pb.LoginRes, error) {
    // В лог улетает пароль в открытом виде
    log.Printf("Received request: %v", req) 
}

Безопасно:
// Использование опций протокола для маскирования (например, экосистема logv2)
message LoginReq {
    string username = 1;
    string password = 2 [debug_redact = true];
}

19. Secrets
Случайная передача секретов (API keys, хэшей) клиенту в теле ответа.
Уязвимо:
message LoginResponse {
    string access_token = 1;
    string internal_db_password = 2; // Упс
}

Безопасно:
Тотальное разделение моделей хранения и транспортных protobuf-сообщений. Секреты никогда не должны присутствовать в .proto файлах ответов.
20. gRPC-Gateway Security
Специфичные уязвимости при трансляции REST (HTTP) в gRPC.
Уязвимо:
// Подняли Gateway, но забыли повесить CORS и HTTP-middlewares для защиты от CSRF/XSS,
// полагаясь только на gRPC interceptors.
mux := runtime.NewServeMux()

Безопасно:
mux := runtime.NewServeMux()
// Оборачивание gRPC-Gateway в стандартные HTTP-хендлеры для защиты
secureHandler := applyCORS(applyCSRFProtection(mux))
http.ListenAndServe(":8080", secureHandler)

21. Interceptors
Логика безопасности размазана по бизнес-коду методов, что ведет к тому, что в новых методах про нее забудут.
Уязвимо:
func (s *Server) UpdateData(ctx context.Context, req *pb.Req) (*pb.Res, error) {
    if !isValidToken(ctx) { ... } // Проверка скопипащена в каждый метод
    // ...
}

Безопасно:
// Цепочка интерцепторов гарантирует, что запрос не дойдет до бизнес-логики,
// если он не прошел аутентификацию, валидацию и лимиты.
s := grpc.NewServer(
    grpc.ChainUnaryInterceptor(
        recoveryInterceptor,
        loggingInterceptor,
        authInterceptor,
        validationInterceptor,
    ),
)

22. Протокол и эволюция API
Поломка контракта, ведущая к уязвимостям на стороне старых клиентов (например, изменение семантики поля).
Уязвимо:
// v1
enum Status {
    ACTIVE = 0;
    BANNED = 1;
}

// v2: Поменяли местами. Старый клиент получит 0 и подумает, что пользователь BANNED,
// хотя он ACTIVE в новой системе.
enum Status {
    BANNED = 0;
    ACTIVE = 1;
}

Безопасно:
Никогда не менять значения enum и типы полей. Если логика меняется — добавлять новое поле (status_v2) или создавать новую версию сервиса (service UserV2).






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
