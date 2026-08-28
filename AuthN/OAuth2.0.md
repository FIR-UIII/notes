### RFC reference
```
OAuth 2.0 Authorization Framework https://www.rfc-editor.org/rfc/rfc6749
OAuth 2.0 Authorization Framework: Bearer Token Usage https://www.rfc-editor.org/rfc/rfc6750
JSON Web Token (JWT) https://www.rfc-editor.org/rfc/rfc7519
JSON Web Token (JWT) Profile for OAuth 2.0 Access Tokens https://www.rfc-editor.org/rfc/rfc9068 
OAuth 2.0 Dynamic Client Registration Protocol https://www.rfc-editor.org/rfc/rfc7591
OAuth 2.0 PKCE https://www.rfc-editor.org/rfc/rfc7636
OAuth 2.0 Token Revocation https://www.rfc-editor.org/rfc/rfc7009
OAuth 2.0 Token Introspection https://www.rfc-editor.org/rfc/rfc7662
OAuth 2.0 Device Authorization Grant https://www.rfc-editor.org/rfc/rfc8628

# Расширения OAuth 2.0
OAuth 2.0 Step Up Authentication Challenge Protocol https://www.rfc-editor.org/rfc/rfc9470
OAuth 2.0 Demonstrating Proof of Possession (DPoP) https://www.rfc-editor.org/rfc/rfc9449
OAuth 2.0 Rich Authorization Requests https://www.rfc-editor.org/rfc/rfc9396
OAuth 2.0 Authorization Server Issuer Identification https://www.rfc-editor.org/rfc/rfc9207
OAuth 2.0 Pushed Authorization Requests https://www.rfc-editor.org/rfc/rfc9126
The OAuth 2.0 Authorization Framework: JWT-Secured Authorization Request (JAR) https://www.rfc-editor.org/rfc/rfc9101
Resource Indicators for OAuth 2.0 https://www.rfc-editor.org/rfc/rfc8707
OAuth 2.0 Mutual-TLS Client Authentication and Certificate-Bound Access Tokens https://www.rfc-editor.org/rfc/rfc8705
OAuth 2.0 Token Exchange https://www.rfc-editor.org/rfc/rfc8693
Proof-of-Possession Key Semantics for JSON Web Tokens (JWTs) https://www.rfc-editor.org/rfc/rfc7800
Authentication Method Reference Values https://www.rfc-editor.org/rfc/rfc8176
JSON Web Token (JWT) Profile for OAuth 2.0 https://www.rfc-editor.org/rfc/rfc7523
Assertion Framework for OAuth 2.0 https://www.rfc-editor.org/rfc/rfc7521
Security Assertion Markup Language (SAML) 2.0 Profile for OAuth 2.0 https://www.rfc-editor.org/rfc/rfc7522
OAuth 2.0 Authorization Server Metadata https://www.rfc-editor.org/rfc/rfc8414

# Best practice
Best Current Practice for OAuth 2.0 Security (Best Current Practice) https://www.rfc-editor.org/rfc/rfc9700
JSON Web Token Best Current Practices (Best Current Practice) https://www.rfc-editor.org/rfc/rfc8725
OAuth 2.0 Threat Model and Security Considerations https://www.rfc-editor.org/rfc/rfc6819
OAuth 2.0 for Native Apps (Best Current Practice) https://www.rfc-editor.org/rfc/rfc8252
```

## 🚫 Запрещенные и устаревшие механизмы

* **Implicit Grant (`response_type=token`)**: Полностью запрещен. Токены не должны передаваться через URI-фрагмент браузера из-за риска утечки через историю, HTTP Referer и логи.
* **Resource Owner Password Credentials (ROPC)**: Строго запрещен. Передача логина и пароля пользователя напрямую клиенту нарушает архитектуру делегированного доступа и расширяет поверхность атаки.

## 🔒 Требования к потоку авторизации

* **Тотальный PKCE**: Использование Proof Key for Code Exchange обязательно **для всех клиентов**, включая конфиденциальные (серверные). В качестве алгоритма хеширования должен использоваться исключительно `S256` (`code_challenge_method=S256`).
* **Защита от CSRF**: Механизм PKCE (в базовом OAuth 2.0) или параметр `nonce` (в OIDC) полностью берут на себя защиту от подделки межсайтовых запросов. Параметр `state` сохраняет свою полезность, но теперь применяется только для контроля логики и состояния самого приложения.
* **Pushed Authorization Requests (PAR)**: Стандарт настоятельно рекомендует использовать PAR (часто в комбинации с JAR/JARM) для защиты параметров запроса от перехвата и внедрения на фронтенде, перенося инициализацию транзакции на защищенный backchannel.

## 🛡️ Валидация Redirect URI

* **Только точное совпадение (Exact Matching)**: Сервер авторизации обязан выполнять строгую посимвольную проверку Redirect URI. Использование регулярных выражений (pattern matching) недопустимо.
* **Изоляция параметров**: Запрещено использовать Redirect URI, полученные динамически из query-параметров запроса (во избежание Open Redirect).
* *Исключение:* Нативным приложениям разрешено использовать изменяющиеся порты на `loopback` интерфейсе (`127.0.0.1` / `[::1]`).

## 🔑 Аутентификация клиентов

* **Отказ от статических секретов**: Для конфиденциальных клиентов рекомендуется уходить от базовых разделяемых секретов (`client_secret`) в пользу асимметричной криптографии.
* **Строгие методы**: Следует использовать **JWT Client Assertions** (`private_key_jwt`) или **Mutual TLS (mTLS)**. Это критически важное требование для безопасной работы с CIBA и высоконагруженными федеративными системами.

## 📦 Защита токенов и Sender-Constraining

* **Привязка к отправителю**: Access-токены должны быть защищены от извлечения и несанкционированного использования атакующим. Для этого необходимо применять механизмы **DPoP (Demonstrating Proof-of-Possession)** или **mTLS**, которые криптографически привязывают токен к конкретному легитимному клиенту.
* **Минимизация привилегий**: Токены должны выдаваться с жестко ограниченным набором scope и минимальным сроком жизни.

## 🔄 Управление Refresh-токенами

Refresh-токены долговечны, поэтому для публичных клиентов (SPA, мобильные приложения) они должны быть защищены одним из двух способов:

1. **Sender-Constraining**: Жесткая привязка к клиенту через DPoP или mTLS.
2. **Refresh Token Rotation (RTR)**: Одноразовое использование токена. При попытке повторного использования уже погашенного refresh-токена сервер **обязан** расценить это как компрометацию и немедленно аннулировать всю цепочку токенов, выданных в рамках данной сессии.

## 🔀 Защита от Mix-Up атак

* **Идентификация эмитента (RFC 9207)**: Клиенты, взаимодействующие с несколькими серверами авторизации (AS), обязаны проверять параметр `iss` (Issuer) в ответе сервера. Это гарантирует, что код авторизации и токены получены именно от того сервера, куда изначально направлялся пользователь.
* Серверы авторизации обязаны всегда возвращать параметр `iss` в ответе `authorize`.

## 📡 Discovery и Метаданные

* Серверы авторизации обязаны публиковать свои настройки (согласно RFC 8414).
* Критически важный параметр для публикации — `code_challenge_methods_supported`. Это позволяет клиентам (а также инструментам автоматизированного сканирования уязвимостей) динамически проверять, что сервер поддерживает защищенный метод `S256` для PKCE.

```

### Механизм обмена токенов (Token exchange):

Пример запроса на обмен токена:
```
POST /token-exhacnge HTTP/1.1
Host: https://iam.local
Content-Type: application/x-www-form-urlencoded
Authorization: Basic <base64-encoded-clientId:clientSecret>

grant_type=urn:ietf:params:oauth:grant-type:token-exchange
&subject_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9... # токен для обмена
&subject_token_type=urn:ietf:params:oauth:token-type:access_token
&resource=https://resource-server.com/api/resource
&scope=read write
```

Пример ответа:
```
HTTP/1.1 200 OK
 Content-Type: application/json
 Cache-Control: no-cache, no-store

 {
  "access_token":"eyJhbGciOiJFUzI1NiIsImtpZCI6IjllciJ9.eyJhdWQiOiJo
    dHRwczovL2JhY2tlbmQuZXhhbXBsZS5jb20iLCJpc3MiOiJodHRwczovL2FzLmV
    4YW1wbGUuY29tIiwiZXhwIjoxNDQxOTE3NTkzLCJpYXQiOjE0NDE5MTc1MzMsIn
    N1YiI6ImJkY0BleGFtcGxlLmNvbSIsInNjb3BlIjoiYXBpIn0.40y3ZgQedw6rx
    f59WlwHDD9jryFOr0_Wh3CGozQBihNBhnXEQgU85AI9x3KmsPottVMLPIWvmDCM
    y5-kdXjwhw",
  "issued_token_type":
      "urn:ietf:params:oauth:token-type:access_token",
  "token_type":"Bearer",
  "expires_in":60
 }
```

Условие использования:
ИС должна использовать конфиденциальный клиент IAM (если клиент публичный, то в случае утечки токена есть риск увеличения поверхности атаки на другое приложение через обмен токена)
Полномочия должны быть точечными, как минимум не превышать scope оригинального токена, а лучше иметь один конкретный гранулярный запрос

Сценарии использования:
Использование в суперапп smartapp (приложение - платформа) для доступа к информации других приложений.
Сценарий делегирования критичный действий или конфиденциальной информации другим. Например внутренним микросервисам или ТУЗу выполнять действия от имени пользователя без раскрытия полных учетных данных. Дополнительно рекомендуется получение согласия от пользователя на такое действие
Интеграция с другими IdP / IAM провайдерами. Если нужно применить аналог SSO, где происходит обмен токена одного IAM на токен другого IAM.
Миграция с одного IAM на другой. Временный период 

Преимущества:
Используется эфемерный временный токен доступа для совершения операции. 
IdP (IAM) может контролировать взаимодействия ИС<->ИС с данными пользователя через политику обмена.
Пользователь явно может видеть какому приложения были даны права и отозвать при наличии функционала в ИС.
Соблюдение принципа "наименьших привилегий", сами права не полные - а точечные, их можно настраивать.
Сокращается время на использование токена. Если пользователь аутентифицирован - вне сессии пользователя нельзя произвести обмен токена.

Риски:
Сложность реализации для ИС
Зависимость от сервера IAM - как точка отказа
Если злоумышленник перехватит оригинальный токен ИС и будет знать куда обратиться для обмена, он может получить целевой токен другой ИС. Однако это можно смягчить с помощью ограничения TTL и ограничений по аудитории aud claim, а также внедрения механизма проверки использования токена (кол-ва его использования)

### Модель угроз
https://datatracker.ietf.org/doc/rfc9700

1. Open redirection attack
Если на сервере настроены такие правила валидации https://*.somesite.example/*. Чтобы  https://app1.somesite.example/redirect смог работать. Но атакующий может заменить адрес на
https://attacker.example/.somesite.example/
> найти запрос авторизации /auth?client_id=[...] и отправить в Repeater
> подменить значение redirect_uri:
    A. подменить значение redirect_uri на свой домен с подстановкой домена жертвы как своего URI
    redirect_uri=https://attacker.example/.somesite.example/
    B. parameter pollution
    redirect_uri=https://somesite.example/&redirect_uri=https://attacker.example/.somesite.example/
    C. @
    redirect_uri=https://somesite.example@https://attacker.example/.somesite.example/
    D.  open redirect. На сайте нужно найти эндпоинт осущесвляющий редирект на другую страницу https://YOUR-LAB-ID.web-security-academy.net/oauth-callback/../post?postId=1 подменить значение redirect_uri     
    redirect_uri=https://YOUR-LAB-ID.web-security-academy.net/oauth-callback/../post/next?path=https://YOUR-EXPLOIT-SERVER-ID.exploit-server.net/exploit

> отправить жертве подготовленную ссылку (phishing)

2. Authorization Code Injection
Если злоумышленник получил authorization code, то он может раньше клиента обратиться за получением access токена
Защита использовать PKCE или Nonce для OIDC

3. Access Token Injection
Если злоумышленник получил access token 
Защита - проверка at_hash claim

4. PKCE Downgrade Attack

5. SSRF via client registration
Проверить https[:]//oauth-ID.oauth-server.net/.well-known/openid-configuration
> найти registration_endpoint /reg на сервере авторизации
> создать и зарегистрировать своего клиента. 
> проверить гипотезу что при создании клиента есть некий URL от защищенного ресурса. Например "logo_uri" : "http://169.254.169.254/latest/meta-data/iam/security-credentials/admin/" 
    POST /reg HTTP/1.1
    Host: oauth-YOUR-OAUTH-SERVER.oauth-server.net
    Content-Type: application/json

    {
        "redirect_uris" : [
            "https://example.com"
        ],
        "logo_uri" : "http://169.254.169.254/latest/meta-data/iam/security-credentials/admin/"
    }
> Сделать запрос к защищенной странице GET /client/{CLIENT_ID}/logo HTTP/2 на client id только что созданного клиента, который дасть доступ к закрытой информации

6. Authentication bypass via OAuth implicit flow
> Модифицировать запрос POST /authenticate 
{"email":"wiener@hotdog.com","username":"wiener","token":"X009bmC5Z8m9JPKw_9Ow1-V_r0UIOnVmCFbOkt4QIA7"}
 На POST /authenticate 
{"email":"carlos@carlos-montoya.net","username":"wiener","token":"X009bmC5Z8m9JPKw_9Ow1-V_r0UIOnVmCFbOkt4QIA7"}

7. CSRF
> если нет state, nonce, PKCE
> если есть state, nonce
убрать, заменить на другое значение и проверить
> если есть PKCE

8. Кража client secret
Вместо простого пароля использовать Signed JWT
