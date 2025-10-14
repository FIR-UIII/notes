### alg: none, Accepting unsigned tokens
```js
// vulnerable
const jwt = require('jsonwebtoken');
const token = jwt.sign({ role: 'admin' }, 'mysecret', { algorithm: 'HS256' });

// Exploit: attacker crafts token with alg: none
const fakeToken = Buffer.from(JSON.stringify({ alg: 'none', typ: 'JWT' })).toString('base64') + '.' +
Buffer.from(JSON.stringify({ role: 'admin' })).toString('base64') + '.';

jwt.verify(fakeToken, null, { algorithms: ['none'] }); // Never do this
```

### JWT payload веб-токена
JWT может быть либо подписан, либо подписан и зашифрован. Если JWT подписан и зашифрован, JSON-документ должен быть сначала подписан, затем зашифрован, а результат – структура вложенного JWT – Nested JWT.
```json
   "sub": "248289761001", // subject – ID пользователя токена
   "aud": "получатель-XXX" //  обязательная проверка аудитории: кому предназначен токен. [RFC7519] https://www.rfc-editor.org/rfc/rfc7519#section-4.1.3
   "iss": "iam-system" // обязательная проверка поля issuer (издатель) со стороны ИС [RFC9207] https://datatracker.ietf.org/doc/html/rfc9207#name-validating-the-issuer-ident [RFC7519] https://www.rfc-editor.org/rfc/rfc7519#section-4.1.1
   "azp": "отправитель-АВС" // авторизированная сторона, обязательная проверка поля со стороны ИС https://openid.net/specs/openid-connect-core-1_0.html 
   "iat": 1716249600 // issued at time. обязательная проверка времени со стороны ИС, не должен быть выписан ранее запроса
   "exp": 1716249600 // expiration time. обязательная проверка по времени после которого токен не должен быть валидным
   "jti": // JWT ID, уникальный идентификатор JWT, можно использовать для проверки использования
   "nbf": // (опциональный) время, до которого JWT не должен приниматься к обработке;
```

