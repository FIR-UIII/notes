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

### Missing exp,  Tokens that never expire
```js
// vulnerable
mport jwt

payload = {"user_id": 1} # No expiration
encoded = jwt.encode(payload, "secret", algorithm="HS256")
```

### Ignoring aud, Misused across apps
The aud claim ensures the token is intended for your service. Ignoring this lets tokens be used in unintended places.
```js
```
