SPNEGO (Simple and Protected GSS-API Negotiation Mechanism): механизм обертки (RFC 2478 / RFC 4559), позволяющий клиенту и серверу договориться о методе аутентификации (обычно выбирается Kerberos, а в качестве запасного варианта — устаревший NTLM)

HTTP Negotiate: заголовок HTTP-протокола (WWW-Authenticate: Negotiate и Authorization: Negotiate), через который передаются токены SPNEGO.

Kerberos: сетевой протокол аутентификации на основе билетов (tickets), использующий Центр распределения ключей (KDC), чаще всего в Microsoft Active Directory.

```mermaid
sequenceDiagram
    autonumber
    actor U as Пользователь
    participant W as Windows
    participant AD as Active Directory / KDC
    participant B as Браузер / WebView
    participant K as Keycloak
    participant LDAP as LDAP Federation
    participant APP as Desktop APP Backend

    U->>W: Вход в Windows под доменной учётной записью
    W->>AD: Kerberos-аутентификация
    AD-->>W: TGT

    U->>B: Открывает Desktop APP 
    B->>K: OIDC Authorization Request
    K-->>B: 401 Unauthorized<br/>WWW-Authenticate: Negotiate

    B->>AD: Запрос сервисного билета<br/>HTTP/sso.example.com
    AD-->>B: Kerberos Service Ticket

    B->>K: Повторный запрос<br/>Authorization: Negotiate
    K->>K: Проверка Kerberos-билета
    K->>LDAP: Поиск пользователя по principal
    LDAP->>AD: LDAP-запрос пользователя
    AD-->>LDAP: Учётная запись и атрибуты
    LDAP-->>K: Сопоставленный пользователь

    K-->>B: OIDC Authorization Response<br/>Authorization Code
    B->>APP: Передача результата авторизации
    APP->>K: Обмен code на токены<br/>с code_verifier при PKCE
    K-->>APP: Access Token + ID Token

    APP->>APP: Проверка токена и создание сессии
```
