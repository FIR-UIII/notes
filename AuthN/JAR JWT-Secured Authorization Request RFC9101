Request Object — это, по сути, сердце спецификации JAR. Он позволяет кодировать каждую часть запроса авторизации в виде отдельных утверждений JWT
Если идти в эту историю то лучше делать в связке с PAR

```
# Как в обычном запросе OAuth
GET /authorize?
    client_id=my-client
    &response_type=code
    &redirect_uri=https://client.example/callback
    &scope=openid
    &state=abc
    &nonce=xyz

# Как в JAR - Клиент создает pub/priv ключи формирует запрос и кледет его в токен и подписывает
GET /authorize?
    client_id=my-client
    &request=eyJhbGciOiJSUzI1NiIs...

# где внутри request как раз все параметры запроса
{
  "iss": "my-client",
  "aud": "https://auth.example.com",
  "client_id": "my-client",
  "response_type": "code",
  "redirect_uri": "https://client.example/callback",
  "scope": "openid profile",
  "state": "abc123",
  "nonce": "xyz789",
  "code_challenge": "...",
  "code_challenge_method": "S256"
}
```

IAM после получения парсит и проверяет токен и только потом делает дальнейшую логику
