### alg: none, Accepting unsigned tokens
https://www.rfc-editor.org/info/rfc7519/#section-6.1 
```js
// vulnerable
const jwt = require('jsonwebtoken');
const token = jwt.sign({ role: 'admin' }, 'mysecret', { algorithm: 'HS256' });

// Exploit: attacker crafts token with alg: none
const fakeToken = Buffer.from(JSON.stringify({ alg: 'none', typ: 'JWT' })).toString('base64') + '.' +
Buffer.from(JSON.stringify({ role: 'admin' })).toString('base64') + '.';
jwt.verify(fakeToken, null, { algorithms: ['none'] }); // Never do this
```

### Проверка подписи (процедура)
https://datatracker.ietf.org/doc/html/rfc7515
1. Декодировать из base64 и распарсить токен на части: `{JOSE Header}.{JWS Payload}.{JWS Signature}` Если частей не ровно 3, процесс сразу прекращается (ошибка Malformed token).
2. Из JOSE Header проверить поле "alg" со списком разрешенных алгоритмов, переданных разработчиком в коде (например, вы жестко указали algorithms=["RS256"]). Если в токене написано alg: "none" или alg: "HS256", а вы ждали RS256, SDK выбросит ошибку. Это защищает от уязвимости подмены алгоритма. Либо это проверить на этапе парсинга /certs там передается поле "alg", указывающая в каком алгоритме происходит шифрование.
3. Из JOSE Header взять поле "kid" (Key ID) - он указывает, каким именно ключом была создана подпись. 
4. Загрузить публичные ключи (JWKS) для keycloak - https://<keycloak>/auth/realms/<realm>/protocol/openid-connect/certs. Здесь важно выставить Rate Limit (например, 1 запрос в 1 час) если злоумышленник начнет слать тысячи токенов с рандомными/несуществующими kid, чтобы заставить ваш сервер непрерывно спамить Keycloak запросами (DDoS-атака).
5. Из JWKS найти с совпадающим kid токена. Что если ключа нет? Сделать инвалидацию кеша и выполнить один «свежий» HTTP-запрос к /certs Keycloak. Возможно, в Keycloak только что произошла ротация (смена) ключей, и появился новый kid. Если ключа все еще нет — выдается ошибка Unknown Key ID.
6. Получив нужный kid распарсить его и взять поля "n" (Modulus — модуль) и "e" (Exponent — экспонента) -> SDK декодирует из base64 в байты (большие целые числа / Big-Endian) -> На основе n и e (или используя цепочку сертификатов x5c) SDK конструирует объект публичного ключа (например, в формате PEM/DER), который уже понимает низкоуровневая библиотека шифрования.
7. Из токена взять `{JOSE Header}.{JWS Payload}` -> вычислить хеш SHA-256 -> взять JWS Signature и декодировать из Base64URL в байты -> с помощью созданного ранее публичного ключа п.6 и алгоритма RSA математически верифицируется, что данная подпись была создана именно из этого хеша. Если математическое равенство сошлось — токен подлинный и Payload не менялся.

```py
import jwt
from jwt.exceptions import PyJWTError

# 1. Инициализируем JWKS-клиент (кеширование включено по умолчанию)
jwks_url = "https://<keycloak>/auth/realms/<realm>/protocol/openid-connect/certs"
jwks_client = jwt.PyJWKClient(jwks_url)

token = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ik..."

try:
    # 2. Получаем нужный ключ. 
    # Клиент сам распарсит заголовок токена, возьмет kid, залезет в JWKS и вернет объект ключа.
    signing_key = jwks_client.get_signing_key_from_jwt(token)

    # 3. Декодируем и проверяем токен
    data = jwt.decode(
        token,
        signing_key.key,              # Передаем сам публичный ключ
        algorithms=["RS256"],         # СТРОГО фиксируем алгоритм
        issuer="https://<keycloak>/auth/realms/<realm>", # Проверяем iss
        options={"require": ["exp", "iss"]} # Требуем обязательного наличия этих полей
    )
    
    print("Токен валиден. Пользователь:", data)

except PyJWTError as e:
    print(f"Ошибка валидации токена: {e}")
```

### check JWT payload / claims
JWT может быть либо подписан, либо подписан и зашифрован. Если JWT подписан и зашифрован, JSON-документ должен быть сначала подписан, затем зашифрован, а результат – структура вложенного JWT – Nested JWT.
```json
   "sub": "248289761001", // subject – ID пользователя токена
   "aud": "получатель-XXX" //  обязательная проверка аудитории: кому предназначен токен. [RFC7519] https://www.rfc-editor.org/rfc/rfc7519#section-4.1.3
   "iss": "iam-system" // обязательная проверка поля issuer (издатель) со стороны ИС [RFC9207] https://datatracker.ietf.org/doc/html/rfc9207#name-validating-the-issuer-ident [RFC7519] https://www.rfc-editor.org/rfc/rfc7519#section-4.1.1
   "azp": "отправитель-АВС" // авторизированная сторона, обязательная проверка поля со стороны ИС https://openid.net/specs/openid-connect-core-1_0.html 
   "iat": 1716249600 // issued at time. обязательная проверка времени со стороны ИС, не должен быть выписан ранее запроса [RFC7519] https://www.rfc-editor.org/info/rfc7519/#section-4.1.6
   "exp": 1716249600 // expiration time. обязательная проверка по времени после которого токен не должен быть валидным [RFC7519] https://www.rfc-editor.org/info/rfc7519/#section-4.1.4
   "jti": // JWT ID, уникальный идентификатор JWT, можно использовать для проверки использования [RFC7519] https://www.rfc-editor.org/info/rfc7519/#section-4.1.7
   "nbf": // (опциональный) время, до которого JWT не должен приниматься к обработке; [RFC7519] https://www.rfc-editor.org/info/rfc7519/#section-4.1.5
```

### Strong secret for HMAC-signed tokens
at least 32 bytes / 128 bit in length 
