### Спецификация IETF: Draft OAuth Transaction Tokens

Главная идея: Спецификация описывает новый тип токенов для безопасного взаимодействия между внутренними сервисами (workloads) 
в рамках одной доверенной зоны. Она призвана защитить систему от атак на цепочки поставок ПО или компрометации отдельных микросервисов.

Как это работает: Внешний запрос поступает на шлюз с обычным токеном (например, OAuth Access Token)<br>
Шлюз обменивает его через Token Exchange (RFC 8693) у специальной службы на короткоживущий транзакционный токен (Txn-Token)<br>
Свойства токена: Это подписанный JWT, который содержит неизменяемый контекст конкретной транзакции: уникальный ID запроса (txn), параметры вызова (azd), данные источника (req_ctx) и данные пользователя (sub_id)<br>
Безопасность: Срок действия токена крайне мал (порядка 5 минут). Злоумышленник, захвативший микросервис, не сможет использовать этот токен для совершения сторонних вызовов вне контекста данной транзакции или подделать цепочку вызовов.
```
# header
{
    "typ": "txn_token",
    "alg": "RS256",
    "kid": "identifier-to-key"
},
# body
{
    "iss": "https://trust-domain.example/txn-token-service",
    "iat": "1686536226000",
    "aud": "trust-domain.example",
    "exp": "1686536526000",
    "txn": "97053963-771d-49cc-a4e3-20aad399c312",
    "sub_id": {
        "format": "email",
        "email": "user@trust-domain.example"
    },
    "req_ctx": {
      "req_ip": "69.151.72.123", // env context of external call
      "authn": "urn:ietf:rfc:6749", // env context of the external call
      "req_wl": "apigateway.trust-domain.example" // the internal entity that requested the Txn-Token
    },
    "purp" : "trade.stocks",
    "azd": {
        "action": "BUY", // parameter of external call
        "ticker": "MSFT", // parameter of external call
        "quantity": "100", // parameter of external call
        "user_level": "vip" // computed value not present in external call
    }
}
```
