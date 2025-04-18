## JS
```js
/* 
Формируется переменная currentUriParams, которой присваивается результат вызова функции splitUriIntoParams
Функция splitUriIntoParams преобразует document.location.search в объект JavaScript
Отсутствие проверки или санитизации приводит к уязвимости Prototype Pollution. Если строка запроса содержит ?__proto__[key]=value 
*/

const currentUriParams: Record<string, any> = splitUriIntoParams(
document.location.search
);
```

## How to find manually
Формируется при создании Object (kv, json), простой PoC:
var user = {username: "Bob", password:"foo"}
var admin = {username: "Alice", password:"123", isAdmin: true}
>> инъекция: user.__proto__.isAdmin = true
user.isAdmin // true

На что обращать внимание в коде:
// функции слияния значений
function merge(dst, src) 
Object.assign, _.merge, etc.

// __proto__
var a = test.__proto__;
var a = test['__proto__'];

// небезопасн
app.put('/todos/:id', (req, res) => {
    let id = req.params.id;
    let items = req.session.todos[id];
    if (!items) {
        items = req.session.todos[id] = {};
    }
    items[req.query.name] = req.query.text;
    res.end(200);
});

app.get('/news', (req, res) => {
  let prefs = lodash.merge({}, JSON.parse(req.query.prefs));
})

## SAST rules
semgrep - [javascript.lang.security.audit](https://semgrep.dev/r?q=javascript.lang.security.audit.prototype-pollution)
codeql - https://github.com/github/codeql/tree/main/javascript/ql/src/Security/CWE-915

## How to mitigate
1. Use safe function / lib
A prototype pollution mitigation, where a hacker tries to send a malicious input, but a safe merge function is used, preventing the malicious input from affecting the prototype
```js
import safeMerge from 'lodash.merge';

async function updateUser(userId, requestBody) {
  const userData = await db.loadUserData(userId);
  safeMerge(userData, requestBody);
```

2. Create objects without prototypes: Object.create(null)
Another way to avoid prototype pollution is to consider using the Object.create() method instead of the object literal {} or the object constructor new Object() when creating new objects. This way, we can set the prototype of the created object directly via the first argument passed to Object.create(). If we pass null, the created object will not have a prototype and therefore cannot be polluted.
```js
const safeObject = Object.create(null);
```

3. Solution: Prevent any changes to the prototype: use Object.freeze()
JavaScript comes with an Object.freeze() method and Object.seal(), which we can use to prevent any changes to the attributes of an object. Since the prototype is just an object, we can freeze it, too. We can freeze the default prototype by invoking Object.freeze(Object.prototype), which prevents the default prototype from getting polluted.
```js
Object.freeze(Object.prototype);
```

4. Node.js configuration flag
Node.js also offers the ability to remove the __proto__ property completely using the --disable-proto=delete flag. Note this is a defense in depth measure.
Prototype pollution is still possible using constructor.prototype properties but removing __proto__ helps reduce attack surface and prevent certain attacks.

5. Use "new Set()" or "new Map()"
Developers should use new Set() or new Map() instead of using object literals:
```js
let allowedTags = new Set();
allowedTags.add('b');
if(allowedTags.has('b')){
  //...
}

let options = new Map();
options.set('spaces', 1);
let spaces = options.get('spaces')
```

6. Запретить использование ключей __proto__ и constructor
if (key === "__proto__" || key === "constructor") continue;

7. Проверка ключей
Use Object.hasOwn() or hasOwnProperty(): Always check if a property belongs to the object itself and not its prototype:
```js
if (Object.hasOwn(obj, 'prop')) { /* safe to use obj.prop */ }
```