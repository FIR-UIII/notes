
---

## Архитектурные паттерны аутентификации (шпаргалка)

Ниже - практическая заметка для проектирования AuthN-архитектуры: что выбирать, где применять, какие компромиссы.

## 1) SAML 2.0 (Federation / SSO)

### Где применяют
- Корпоративный SSO между организациями и enterprise-порталами.
- Интеграции с legacy/enterprise системами (особенно веб).

### Плюсы
- Зрелый и широко поддерживаемый в enterprise.
- Хорошо подходит для междоменных B2B SSO сценариев.
- Богатые возможности федерации и атрибутов пользователя.

### Минусы
- XML + подписи/каноникализация = высокая сложность реализации и аудита.
- Тяжелее дебажить и безопасно конфигурировать, чем OIDC.
- Плохо подходит для мобильных и современных SPA API-first сценариев.

### Когда выбирать
- Если экосистема заказчика уже стандартизована на SAML/ADFS/enterprise IdP.
- Если основной сценарий: браузерный SSO между корпоративными сервисами.

## 2) OAuth 2.0 + OpenID Connect (де-факто стандарт для modern apps)

Важно: OAuth 2.0 сам по себе про авторизацию. Для аутентификации пользователя обычно используют OIDC поверх OAuth 2.0.

### Общие плюсы
- Подходит для web, SPA, mobile, API, M2M.
- Большая экосистема SDK/IdP/API Gateway.
- Гибкость: можно включать современные расширения безопасности.

### Общие минусы
- Легко ошибиться в выборе grant/хранении токенов.
- Нужны дополнительные контрмеры: PKCE, audience restriction, rotation, sender-constrained tokens.

## 3) Разделение потоков по типам клиента

### SPA (public client)
Рекомендуемый поток:
- Authorization Code + PKCE.
- Без client secret в браузере.
- Refresh token только при ротации, коротком TTL, привязке к рискам.

Плюсы:
- Современный стандартный подход.
- PKCE снижает риск перехвата authorization code.

Минусы/риски:
- Токены в браузере: XSS и утечки через runtime.
- Нужна строгая CSP, защита от XSS/CSRF, минимизация времени жизни токенов.

### Mobile (public client)
Рекомендуемый поток:
- Authorization Code + PKCE.
- Системный браузер/ASWebAuthenticationSession/Custom Tabs (не embedded webview).
- Universal/App Links для redirect URI.

Плюсы:
- Устойчивый профиль безопасности для нативных приложений.
- Единый UX с IdP и MFA.

Минусы/риски:
- Ошибки в redirect URI и deep link hijacking.
- Требуется аккуратная работа с secure storage и lifecycle токенов.

### M2M (confidential client)
Рекомендуемый поток:
- Client Credentials.
- Лучше с `private_key_jwt` или mTLS вместо shared secret.

Плюсы:
- Простой и быстрый межсервисный сценарий.
- Хорошо масштабируется для service-to-service.

Минусы/риски:
- Риск компрометации секретов при плохом secret management.
- Нет user context, только сервисная идентичность.

## 4) Расширения OAuth/OIDC: PAR, JAR, JARM

### PAR (Pushed Authorization Requests)
Суть:
- Клиент отправляет параметры авторизации напрямую на AS по защищенному каналу.
- В браузер уходит только `request_uri`.

Плюсы:
- Скрывает чувствительные параметры из front-channel.
- Уменьшает риск подмены/утечки параметров запроса.

Минусы:
- Дополнительный вызов и усложнение интеграции.
- Не все legacy-клиенты поддерживают из коробки.

### JAR (JWT Secured Authorization Request)
Суть:
- Authorization request упакован и подписан (иногда шифрован) как JWT (`request`/`request_uri`).

Плюсы:
- Целостность и аутентичность параметров запроса.
- Меньше шансов на parameter tampering.

Минусы:
- Управление ключами и криптографией усложняет систему.
- Требует строгой синхронизации конфигураций клиента и AS.

### JARM (JWT Secured Authorization Response Mode)
Суть:
- Ответ от authorization endpoint возвращается как подписанный JWT.

Плюсы:
- Защита целостности ответа front-channel.
- Снижение риска подмены параметров ответа.

Минусы:
- Дополнительная валидация JWT на клиенте.
- Усложнение разработки и диагностики проблем совместимости.

### Практическая связка
- Для high-security профилей часто используют вместе: PAR + JAR + JARM + PKCE.

## 5) SPIFFE/SPIRE для сервисной аутентификации (workload identity)

### Что это
- SPIFFE: стандарт идентичности workload (SPIFFE ID, SVID).
- SPIRE: референсная реализация SPIFFE (выдача и ротация identity).

### Где применяют
- Kubernetes/VM/Hybrid для mTLS между сервисами.
- Zero Trust архитектуры, где сервис доверяет identity, а не сети.

### Плюсы
- Автоматическая выдача и ротация короткоживущих X.509/SVID.
- Уменьшение зависимости от статических секретов.
- Сильная основа для service-to-service AuthN/AuthZ.

### Минусы
- Операционная сложность внедрения (bootstrap trust, attestation, observability).
- Требует дисциплины в platform engineering.

### Когда выбирать
- Если много микросервисов и нужен единый доверенный слой mTLS identity.
- Если уходите от long-lived secrets в сторону workload identity.

## 6) BFF (Backend-for-Frontend) как Auth boundary для SPA

### Идея
- SPA не работает напрямую с токенами OAuth.
- SPA общается только с BFF по session cookie.
- BFF выполняет OAuth/OIDC dance, хранит токены server-side и вызывает API.

### Плюсы
- Токены не попадают в браузерный JS-контекст.
- Снижается blast radius XSS для token theft.
- Проще централизовать refresh, revocation, token exchange.

### Минусы
- Дополнительный слой, latency и стоимость эксплуатации.
- Необходима масштабируемая сессионная инфраструктура.

### Когда особенно полезно
- Высокие требования к безопасности SPA.
- Необходимость строгого контроля сессий и токенов в одном месте.

## 7) Auth через Proxy/Gateway (вынесение логики аутентификации за pod'ы)

### Паттерн
- Ingress/API Gateway/Service Mesh proxy валидирует токен, проводит authn checks.
- Внутренние pod'ы получают уже проверенный identity context (headers/claims/MTLS identity).

### Плюсы
- Централизация проверки JWT/mTLS/policies.
- Единый enforcement, меньше дублирования кода в сервисах.
- Быстрее вводить новые требования (например, обязательный `aud`, `iss`, `exp`, `azp`).

### Минусы
- Риск "слепого доверия" внутренним заголовкам.
- Ошибка конфигурации gateway затрагивает сразу много сервисов.
- Сервисам все равно нужна валидация критичных бизнес-решений (defense in depth).

### Рекомендации по безопасной реализации
- Подписывать/защищать identity headers на внутреннем контуре.
- Межсервисно использовать mTLS (в идеале SPIFFE/SPIRE).
- Явно отделять: edge authn и domain-level authz внутри сервисов.
- Делать короткоживущие токены + ротацию ключей + строгую валидацию `aud/iss/exp/nbf`.

## 8) Что выбирать на практике (быстрый decision guide)

- Enterprise SSO/legacy B2B: SAML или OIDC federation (если доступно).
- Новый web/mobile продукт: OIDC Authorization Code + PKCE.
- SPA с повышенной безопасностью: BFF + cookie-сессия + server-side token handling.
- M2M: Client Credentials + `private_key_jwt`/mTLS + короткие TTL.
- Kubernetes/microservices zero-trust: SPIFFE/SPIRE + mTLS + policy engine.
- Высокорисковый perimeter: добавить PAR/JAR/JARM.

## 9) Минимальный security baseline

- Только Authorization Code flow (без implicit).
- PKCE везде, где клиент публичный.
- Строгая валидация токенов: `iss`, `aud`, `exp`, `iat`, `nbf`, `azp`, `nonce` (где применимо).
- Ротация refresh token и детект reuse.
- Sender-constrained токены (mTLS или DPoP) для чувствительных API.
- MFA/step-up для рискованных операций.
- Централизованный audit trail и корреляция событий auth.
