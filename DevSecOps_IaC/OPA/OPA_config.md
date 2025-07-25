### Конфигурация
https://www.openpolicyagent.org/docs/latest/configuration/

```yaml
services: # внешний сервис с которого можно получать бандл или отправлять логи
  acmecorp: # название сервиса (продукта)
    url: http://localhost:9000/ # базовый URL
    allow_insecure_tls: true # разрешает подключение по http
    response_header_timeout_seconds: 5
    # credentials: # включает аутентификацию
    #   bearer:
    #     token: "test"

labels: # маркирование инстанса OPA - для тегирования при отправке логов и статуса
  app: myapp
  region: ru
  environment: test

bundles:
  data:
    service: acmecorp # имя сервиса для скачивания бандл
    resource: bundle.tar.gz # имя ресурса для скачивания бандл http://localhost:9000/bundle.tar.gz
    # успех "level":"info","msg":"Bundle loaded and activated successfully.","name":"data","plugin":"bundle","time":""
    persist: true # способ обновления
    trigger: periodic # способ обновления периодически или manual. Время опроса в polling
    polling:
      min_delay_seconds: 60
      max_delay_seconds: 120
      signing.keyid: verifier

decision_logs: # удаленный сервер для отправки логов аудита о выданных решениях POST методом
  # успех "level":"info","msg":"Starting decision logger.","plugin":"decision_logs","time":""
  service: acmecorp
  resource: .
  reporting:
    min_delay_seconds: 300
    max_delay_seconds: 600

status:
  service: acmecorp

default_decision: /http/example/authz/allow # ?

persistence_directory: /var/opa # ?

keys:
  global_key:
    algorithm: RS256
    key: <PEM_encoded_public_key>
    scope: read

caching:
  inter_query_builtin_cache:
    max_size_bytes: 10000000
    forced_eviction_threshold_percentage: 70
    stale_entry_eviction_period_seconds: 3600

distributed_tracing:
  type: grpc
  address: localhost:4317
  service_name: opa
  sample_percentage: 50
  encryption: "off"
  resource:
    service_namespace: "my-namespace"
    service_version: "1.1"
    service_instance_id: "1"

server: # настройка для всех входящих подключений к OPA
  decoding:
    max_length: 134217728
    gzip:
      max_length: 268435456
  encoding:
    gzip:
        min_length: 1024
        compression_level: 9

keys:
  verifier:
    key: public_key.pem
```
