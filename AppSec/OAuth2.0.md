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