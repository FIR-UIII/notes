### RabbitQA, Kafka

### Theat model

##### Authentication
For Kafka
```
SASL/GSSAPI (Kerberos)
SASL/PLAIN (simple username / password)
SASL/SCRAM-SHA-256 (salted challenge-response handshake)
SASL/SCRAM-SHA-512
SASL/OAUTHBEARER (OAuth 2.0/OIDC)
mTLS
```

Producer identity binding: the broker principal should match the actor or producer claim in the event, otherwise any authorized producer can spoof another service's events. This is the main spoofing risk.

##### Authorization
```
1. Event identity ≠ user identity. Модель доверия должна строить на том что действие асинхронное, и может быть выполнена отдельно от запроса пользователя. поэтому важен контекст операции и какие данные передаются в шине. Например действие может прийти после авторизации пользователя alice->OPA->action->consumer
тогда будет виден что запрос авторизован и может быть выполнен.
{
  "actor": "alice",
  "action": "transfer",
  "resource": "account:123",
  "authorization_opa": {
    "decision": "allow"
  }
  "jwt_token_with_permission"
}

2. Защита топиков через механизм ACL. Кто может писать в топик - кто читать. Защита от возможности анонимных и неавторизированных действий
$ bin/kafka-acls.sh --bootstrap-server localhost:9092 --add --allow-principal User:Bob --allow-principal User:Alice --allow-host 198.51.100.0 --allow-host 198.51.100.1 --operation Read --operation Write --topic Test-topic

3. Периодический аудит ACL -> в идеале через IaC сканеры
```

##### Integrity	
Защита от изменений и модификаций 
```
добавление в отправляемое событие hash для защиты от подделки
{   
    ...
    "hash": "aen13bad..." # attacker who can modify the event can recompute the hash
    "HMAC": # hash sign with priv key - more secure 
}
```

##### Confidentiality
Определить что можно передавать в событиях, нужно ли шифровать данные до передачи в по шине?
Шифрование трафика внутри шины
```
# Broker configuration with TLS 1.3
listeners=PLAINTEXT://localhost:9092,SSL://localhost:9093
ssl.keystore.location=/var/private/ssl/kafka.server.keystore.jks
ssl.keystore.password=your-keystore-password
ssl.key.password=your-key-password

# Enforce TLS 1.3
ssl.protocol=TLSv1.3
ssl.enabled.protocols=TLSv1.3,TLSv1.2

# Strong cipher suites for TLS 1.3
ssl.cipher.suites=TLS_AES_256_GCM_SHA384,TLS_AES_128_GCM_SHA256,TLS_CHACHA20_POLY1305_SHA256
```

##### Replay
старый event повторно выполняет действие (например выполнить перевод денег). 
```
добавление в отправляемое событие id для защиты от повторов
{   
    ...
    "event_id": "01H...",
    "expire": ...,
    "timestamp" ... 
}
```

##### Ordering
Изменение порядка событий, т.к. действия могут быть доставлены асинхронно, для критичных операций нужно делать блокеры выполнения до передачи всег контекста
```
{
  "timestamp": "1234854", # добавление временной метки для определения последовательности - важна синхронность времени на всех нодах
  "chunk": "1/3", # добавление информации о том что сообщение часть и нужно получить больше
  "expire": "monday 13:55" # добавление времени жизни события, после которого consumer не должен обрабатывать событие 
}
```

##### Message validation
a schema registry (Avro/Protobuf/JSON Schema) with enforced compatibility, and who may register schemas. Consumers must treat every event as untrusted input.

##### Availability
quotas and rate limits per producer and consumer, partition and replication design, and backpressure. You have "DoS" and "replication" as one-word bullets that need detail.

##### Hardening 
- защита от привилигированных пользователей
- удаление guest пользователей и неавторизированные действия
- сетевая изоляция
- No public-facing brokers: Brokers should never be exposed directly to the public internet
- репликация данных, защиты от падений и план восстановления
- защита от DoS
- аудит событий и мониторинг: Authentication failures, ACL violations, TLS handshake failures, Unusual access patterns
- защита секретов через vault