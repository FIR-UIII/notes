# Security Code Review Checklist: gRPC (Go)

### Аутентификация и авторизация
Аутентификация должна устанавливать личность (например, через Keycloak), а авторизация — проверять права (например, отдельный сервис через OPA/SpiceDB/OpenFGA).

❌ Уязвимо (Доверие клиенту):
```
message DeleteUserRequest {
    string user_id = 1; // Клиент сам говорит, кого удалить и под кем он работает
}

func (s *Server) DeleteUser(ctx context.Context, req *pb.DeleteUserRequest) (*emptypb.Empty, error) {
    // IDOR: Любой пользователь способен удалить любого пользователя
    return s.repo.Delete(req.UserId) 
}
```

✅ Безопасно (Context & Interceptors):
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

### Transport Security
Работа по незашифрованному каналу позволяет перехватывать токены и модифицировать трафик.

❌ Уязвимо:
```
// Использование insecure credentials в production
creds := insecure.NewCredentials()
s := grpc.NewServer(grpc.Creds(creds))
```

✅ Безопасно:
```
// Использование mTLS (взаимная аутентификация) или строгого TLS
creds, err := credentials.NewServerTLSFromFile("server.crt", "server.key")
if err != nil {
    log.Fatalf("Failed to generate credentials: %v", err)
}
s := grpc.NewServer(grpc.Creds(creds))
```

### Input Validation
gRPC гарантирует типы данных, но не их бизнес-валидность.

❌ Уязвимо:
```go
func (s *Server) CreateUser(ctx context.Context, req *pb.UserReq) (*pb.UserRes, error) {
    // Нет проверки формата email или отрицательного возраста
    db.Save(req.Email, req.Age) 
}
```

✅ Безопасно (через protovalidate):
```
// proto
import "buf/validate/validate.proto";

message UserReq {
    string email = 1 [(buf.validate.field).string.email = true];
    int32 age = 2 [(buf.validate.field).int32.gt = 0];
}

// go
import "github.com/bufbuild/protovalidate-go"

func (s *Server) CreateUser(ctx context.Context, req *pb.UserReq) (*pb.UserRes, error) {
    v, _ := protovalidate.New()
    if err := v.Validate(req); err != nil {
        return nil, status.Errorf(codes.InvalidArgument, "validation failed: %v", err)
    }
    // ...
}
```

### Information Disclosure
Случайный возврат клиенту внутренних структур БД.

❌ Уязвимо:
```
// DTO совпадает с моделью БД. Утекают хэши паролей и внутренние роли.
return &pb.User{
    Id: dbUser.ID,
    Username: dbUser.Username,
    PasswordHash: dbUser.PasswordHash, 
}
```

✅ Безопасно:
```
// Использование строгого маппинга в Public DTO
return &pb.PublicUser{
    Id: dbUser.ID,
    Username: dbUser.Username,
}
```

### Field Tag Confusion
Переиспользование номеров удаленных protobuf-полей ломает обратную совместимость и может привести к подмене типов у старых клиентов.

❌ Уязвимо:
```
// proto
// Было: string user_id = 1; bool is_admin = 2;
// Стало:
message UpdateProfileRequest {
    string user_id = 1;
    string new_password = 2; // Переиспользовали тег 2
}
```

✅ Безопасно:
```
message UpdateProfileRequest {
    string user_id = 1;
    reserved 2;
    reserved "is_admin";
    string new_password = 3;
}
```

### Integer Overflow
Ошибки приведения типов (кастинге) из больших размерностей в меньшие.

❌ Уязвимо:
```
// req.Size имеет тип uint64, а int в Go на 32-битных системах это int32.
// Переполнение может привести к выделению 0 байт памяти и дальнейшей панике.
size := int(req.Size)
buffer := make([]byte, size) 
```

✅ Безопасно:
```
if req.Size > math.MaxInt32 {
    return nil, status.Error(codes.InvalidArgument, "size too large")
}
size := int(req.Size)
```

### DoS

❌ Уязвимо:
```
// example - 1 Атака исчерпания памяти (OOM) через огромные массивы.
repeated string payload = 1;

// Если клиент пришлет миллион элементов, мы аллоцируем огромный срез
results := make([]string, len(req.Payload))

// example -2 gRPC загрузит весь файл в память до вызова обработчика
message UploadReq {
    bytes file_content = 1; 
}
```

✅ Безопасно:
```
// example - 1 SAFE
if len(req.Payload) > 1000 {
    return nil, status.Error(codes.InvalidArgument, "payload too large")
}

// example -2 SAFE Использование потоков (streaming) для чанков фиксированного размера
rpc Upload(stream FileChunk) returns (UploadStatus);
```


### DoS - Max Receive Size
Дефолтные настройки gRPC допускают размер входящего сообщения до 4 МБ, что иногда слишком много (или мало), что позволяет провести DoS.

❌ Уязвимо:
```
// Используются настройки по умолчанию
s := grpc.NewServer()
```

✅ Безопасно:
```
// Строгое ограничение размера Unary-сообщения (например, 1 MB)
s := grpc.NewServer(
    grpc.MaxRecvMsgSize(1024 * 1024 * 1),
    grpc.MaxSendMsgSize(1024 * 1024 * 1),
)
```

### Metadata Security
Доверие заголовкам (metadata), которые может прислать клиент.

❌ Уязвимо:
```
md, _ := metadata.FromIncomingContext(ctx)
// Злоумышленник может просто передать заголовок "x-role: admin"
role := md["x-role"][0] 
```

✅ Безопасно:
```
// Metadata используется только для получения JWT-токена.
// Роли и ID извлекаются сервером после криптографической проверки подписи токена.
claims := validateJWT(md["authorization"][0])
ctx = context.WithValue(ctx, roleKey, claims.Role)
```

### Deadlines (DoS)
Отсутствие таймаутов приводит к зависанию горутин и соединений БД, если внешний сервис или БД тормозит.

❌ Уязвимо:
```
// Запрос в БД будет висеть бесконечно
db.QueryContext(context.Background(), "SELECT ...") 
```

✅ Безопасно:
```
// Передача gRPC-контекста дальше. Если клиент отвалился по своему таймауту,
// запрос в БД автоматически отменится.
func (s *Server) GetData(ctx context.Context, req *pb.Req) (*pb.Res, error) {
    db.QueryContext(ctx, "SELECT ...")
}
```

### Error Handling
Утечка stack trace или синтаксиса SQL.

❌ Уязвимо:
```
if err != nil {
    // Клиент получит текст "Error 1064 (42000): You have an error in your SQL syntax..."
    return nil, status.Errorf(codes.Internal, "database error: %v", err)
}
```

✅Безопасно:
```
if err != nil {
    log.Error("Database query failed", zap.Error(err))
    return nil, status.Error(codes.Internal, "internal server error")
}
```

### Reflection
Включенная рефлексия (Server Reflection) позволяет атакующему сдампить всю схему API (эквивалент OpenAPI/Swagger).

❌ Уязвимо:
```
s := grpc.NewServer()
reflection.Register(s) // Оставлено включенным в Production
```

✅Безопасно:
```
s := grpc.NewServer()
if env == "development" {
    reflection.Register(s)
}
```

### Exposed Interface
Смешивание публичных и внутренних админских методов в одном сервисе.

❌ Уязвимо:
```
service UserService {
    rpc GetProfile(Req) returns (Res);
    rpc HardResetPassword(Req) returns (Res); // Внутренний метод торчит наружу
}
```

✅ Безопасно:
```
service PublicUserService {
    rpc GetProfile(Req) returns (Res);
}
service InternalAdminService {
    rpc HardResetPassword(Req) returns (Res);
}
// Слушаем Public на порту 443 (Internet), а Internal на порту 9090 (VPC/Mesh)
```

### Rate Limiting (DoS)
Отсутствие защиты от брутфорса и L7 DDoS.

❌ Уязвимо:
```
// Сервер обрабатывает запросы с любой скоростью, пока не упадет БД
s := grpc.NewServer() 
```

✅ Безопасно (Interceptor):
```
// Использование In-Tap Handle для максимально раннего дропа соединения
// или UnaryInterceptor с Token Bucket алгоритмом
s := grpc.NewServer(
    grpc.UnaryInterceptor(ratelimit.UnaryServerInterceptor(limiter)),
)
```

### Log poisoning / sensetive info
Логирование чувствительных данных (PII, пароли, токены).

❌ Уязвимо:
```
func (s *Server) Login(ctx context.Context, req *pb.LoginReq) (*pb.LoginRes, error) {
    // В лог улетает пароль в открытом виде
    log.Printf("Received request: %v", req) 
}
```

✅ Безопасно:
```
// Использование опций протокола для маскирования (например, экосистема logv2)
message LoginReq {
    string username = 1;
    string password = 2 [debug_redact = true];
}
```

### Interceptors (bissness logic vuln)
Логика безопасности размазана по бизнес-коду методов, что ведет к тому, что в новых методах про нее забудут.

❌ Уязвимо:
```
func (s *Server) UpdateData(ctx context.Context, req *pb.Req) (*pb.Res, error) {
    if !isValidToken(ctx) { ... } // Проверка скопипащена в каждый метод
    // ...
}
```

✅ Безопасно:
```
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
```

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
