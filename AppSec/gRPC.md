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
