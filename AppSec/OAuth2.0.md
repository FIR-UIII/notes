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


Authorization code grant type
```bash
# Protocol Flow

+--------+                               +---------------+
|        |--(A)- Authorization Request ->|   Resource    |
|        |                               |     Owner     |
|        |<-(B)-Authorization code Grant-|     /auth     |
|        |                               +---------------+
|        |
|        |                               +---------------+
|        |--(C)-- Access token request ->| Authorization |
| Client |                               |     Server    |
|        |<-(D)----- Access Token -------|     /token    |
|        |                               +---------------+
|        |
|        |                               +---------------+
|        |--(E)----- Access Token ------>|    Resource   |
|        |                               |     Server    |
|        |<-(F)--- Protected Resource ---|               |
+--------+                               +---------------+

# (A) Authorization Request запрос доступа
GET /authorization?
    client_id=12345&        # публичная информация guid клиента
    redirect_uri=https://client-app.com/callback& # должно проверять это поле по списку допустимых URL иначе open redirect attack
    response_type=code&     # если code > OAuth flow; если token OAuth authentication либо это Implicit flow
    scope=openid%20profile& # запрашиваемый скоуп
    state=ae13d489bd00e3c24 # или nonce - обязательный параметр для защиты от CSRF
    + со стороны бэка может быть добавлено поле client_secret
Host: oauth-authorization-server.com # название сервера OAuth 

# (B) Authorization code Grant
GET /callback?code=a1b2c3d4e5f6g7h8& # уникальный код для запроса токена
    state=ae13d489bd00e3c24 # обязательный параметр для защиты от CSRF для подтверждения факта что это оригинальный запрос
Host: client-app.com

# В случае implicit flow user agent сразу получит токен GET /callback#access_token=z0y9x8w7v6u5&token_type=Bearer&expires_in=5000&scope=openid%20profile&state=ae13d489bd00e3c24 HTTP/1.1

# (C) Access token request
POST /token HTTP/1.1
Host: oauth-authorization-server.com
…
    client_id=12345&
    client_secret=SECRET& # это поле не должно быть у пользователя а формироваться бэком
    redirect_uri=https://client-app.com/callback& # должно проверять это поле по списку допустимых URL иначе open redirect attack
    grant_type=authorization_code&
    code=a1b2c3d4e5f6g7h8 # уникальный код для запроса токена
```

Проверка на мисконфигурации
1. Проверить доступность
/.well-known/oauth-authorization-server
/.well-known/openid-configuration

2. Ошибки на клиентской части
- не проверяется TLS сертификат сервера (получение токена от недоверенного сервера)
- передача токена по незащищенному соединению (HTTP)
- не проверяется валидность токена (client_id, подпись , TTL, "aud")
- в запросе /auth и /token нет state или иной защиты от CSRF
- используется implicit flow
- набор токенов access, refresh хранятся в браузере без защиты
- client secret доступен пользователю, или хранится небезопасно
- рекомендуется использовать flow PKCE RFC 7636

3. Ошибки на сервере аутентификации
- не проверяется redirect_uri по белому списку для данной типа клиента, либо используются * в URL (https://*.somesite.example/*)
- использовать конфиденциальный клиент
- атака authorization code injection attack
- выставляются большие значения для кеша в браузере

4. Ошибки на сервере клиента (resource server)
- проверка токенов по клейму aud (что к ним пришел access token от их клиента, а не используется чужой access token)

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

### Best Current Practice for OAuth 2.0 Security (RFC 9700)
https://datatracker.ietf.org/doc/rfc9700/

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
