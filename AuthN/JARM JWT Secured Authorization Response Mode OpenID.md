JARM по логике похож на JAR, но JAR защищает первый запрос от клиента к серверу Authorization Request: Client → Authorization Server. А JARM защищает обратный запрос от сервера Authorization Response: Authorization Server → Client

```
# обычный без JARM
GET /authorize?&nonce...&state=...%client_id=...&client_secret=...
| запрос идет к IAM 
▼
HTTP/1.1 302 Found
Location: https://client.example.com/callback? # возвращается ответ от сервера также как query параметры с описанием
    code=SplxlOBeZQQYbYS6WxSbIA
    &state=abc123

# с JARM
GET /authorize?&nonce...&state=...%client_id=...&client_secret=...
| запрос идет к IAM 
▼
HTTP/1.1 302 Found
Location: https://client.example.com/callback?
    response=eyJhbGciOiJSUzI1NiIs... # возвращается ответ от сервера но в JWT токене
```

Где внутри токена теже параметры
```
{
   "iss":"https://accounts.example.com",
   "aud":"s6BhdRkqt3",
   "exp":1311281970,
   "code":"PyyFaux2o7Q0YfXBU32jhw.5FXSQpvr8akv9CeRDSd0QA",
   "state":"S8NJ7uqk5fY4EjNvP_G_FtyJu6pUsvH9jsYni9dMAJw"
}
```
