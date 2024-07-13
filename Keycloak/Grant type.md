https://auth0.com/docs/api/authentication

**Authorization code** (с или без PKCE) — используется для аутентификации пользователей (не API), т.к. необходим браузер (UserAgent).
(1) Пользователь нажимает ЛОГИН > Приложение подготавливает ссылку (если пользователь не был аутентифицирован, пришел без куки) и отдает 302 
Браузер проводит обращение http://localhost:8080/realms/web_app/protocol/openid-connect/auth?response_type=code&client_id=web_app&redirect_uri=http%3A%2F%2Flocalhost%3A8000%2Fcallback&scope=openid&state=something
(2) Появляется страница Keycloak для ввода логина и пароля. Пользователь вводит
(3) Keycloak отправляет пользователя на redirect_uri и отдает приложению auth_code на redirect_uri
(4) Приложение обращается за токеном к Keycloak http://localhost:8080/realms/web_app/protocol/openid-connect/token в формате x-www-urlencoding для получению токена access с телом
{
    "grant_type": "authorization_code",
    "client_id": "web_app",
    "client_secret": "2BFoiJOhE7DIPdUEahzTSxxZ8yCh1gDy"
    "code": "7cfc743a-3fbb-4eb8-9497-49e65e337df4.815b156a-871b-4847-8d33-93d68b26acf8.f72b23d4-c843-439c-a8d9-4344098422e6",
    "redirect_uri": "http://localhost:8000/callback",
}
(5) И получает ответ с access токеном 

![[Pasted image 20240429193910.png]]

**Client credentials** — используется для внутренних клиентов-сервисов, которые запрашивают доступ к своим ресурсам или ресурсам, заранее согласованным с сервером авторизации.  Доступ по client id (код приложения) и client secret (секрет приложения)
![[Pasted image 20240429193637.png]]

**Implicit** — использовался публичными-клиентами, которые умеют работать с redirection URI (например, для браузерных и мобильных приложений), но был вытеснен authorization code grant с PKCE (Proof Key for Code Exchange — дополнительная проверка, позволяющая убедиться, что token получит тот же сервис, что его и запрашивал. подробнее — [RFC 7636](https://tools.ietf.org/html/rfc7636)).
![[Pasted image 20240429194019.png]]

**Resource owner password credentials**. В [RFC 6819](https://tools.ietf.org/html/rfc6819#section-4.4.3), данный тип grant считается ненадёжным. Если раньше его разрешалось использовать только для миграции сервисов на OAuth 2.0, то в данный момент его не разрешено использовать совсем. Приложение собирает информацию о пользователе и меняет на токен доступа. Resource owner просто берёт и отдаёт в открытом виде свой логин и пароль клиенту, что не безопасно. Изначально он был сделан только для клиентов, которым вы доверяете или тех, что являются частью операционной системы.
![[Pasted image 20240429193812.png]]
**Device authorization** (добавлен в RFC 8628) – используется для авторизации устройств, которые могут не иметь веб-браузеров, но могут работать через интернет. Например, это консольные приложения, умные устройства или Smart TV.
![[Pasted image 20240429194105.png]]