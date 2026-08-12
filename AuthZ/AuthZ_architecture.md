### Docs
https://openid.net/specs/authorization-api-1_0.html
https://docs.oasis-open.org/xacml/3.0/xacml-3.0-core-spec-os-en.html

# AuthZ core logic

### ACL
Список управления доступом (Access Control List - ACL) представляет собой список пользователей, имеющих доступ к определенному ресурсу, а также разрешения которые каждый пользователь имеет по отношению к этому ресурсу (только чтение, чтение-запись и т. д.).
Наиболее распространенным примером ACL и DAC в действии является файловая система Windows, правила брандмауэров веб-приложений (WAF), сетевых маршрутизаторов и коммутаторов. В то время как RBAC определяет привилегии доступа на уровне роли, ACL определяет их на уровне отдельного пользователя.
Access control list for Object:fileA
User:alice Action:read
User:bob Action:write

### RBAC (контроль доступа на основе ролей) 
это модель, в которой доступ предоставляется или запрещается на основе ролей, назначенных пользователю. Пользователь – роль – набор прав доступа (разрешения)

### ABAC (Attribute-Based Access Control) 
это модель, в которой решения о доступе принимаются на основе атрибутов субъекта (пользователя), объекта (ресурса) и среды. Она динамически оценивает, может ли субъект выполнить действие над объектом, на основе этих атрибутов и политик, которые ими управляют.
https://www.osohq.com/learn/what-is-attribute-based-access-control-abac 
Для этого требуется составить перечень этих атрибутов
|Cубьект|Атрибуты|
|------|---------|
|Пользователь|роль, отдел, должность|
|Ресурс|тип, создатель|
|Действие|название (read, write, execute)|
|Среда|сеть, IP, время, устройство|

### ReBAC (контроль доступа на основе отношений) 
это новая модель, которая предоставляет доступ на основе отношений между пользователями и ресурсами. Например, она может разрешить редактировать публикацию только тому пользователю, который ее создал. Эта модель особенно полезна в приложениях социальных сетей, сетевой диск, где доступ зависит от отношений пользователей (например, друзей, подписчиков или владельцев контента).
https://www.osohq.com/academy/relationship-based-access-control-rebac 

# AuthZ architecture
Архитектура авторизации

##### Централизованный сервис PEP/PDP/PAP/PIP
Эталонная модель
```
Client 
│ GET /documents/123 
▼ PEP 
│ "Can subject X perform action Y on resource Z?" 
▼ PDP 
| "Give me attributes" 
▼ PIP 
| user.role = admin, resource.owner = user123 department = security 
▼ PDP 
| evaluate(policy, attributes) 
▼ PDP  
│ make decision ALLOW / DENY
▼ PEP 
├── ALLOW ──► 200 OK 
└── DENY  ──► 403 Forbidden
```

##### Встраиваемый сервис в приложение


# Contracts
### Evaluate
```
"input": {"subject": "alice", "action": "read", "resource": "book", "context": {"netwok": 1.1.1.1/10, "time": 1786408368} }

"output": { "decision": true, "id": 1231231, "context": { "reason": "Request failed policy C076E82F" }} 
```

### Search and Pagination
```
"input": {"subject": "alice", "action": "read", "resource": "book"}

"output": [{"type": "account", "id": "123"}, {"type": "account","id": "456"}]
```

### Partial eval / data filtering
```
"input": {"subject": "alice", "action": "read", "resource": "book"}

"output": {"query": "WHERE employees.department = 'book_readers'"}
```

### Obligation / restriction
```
"input": {"subject": "alice", "action": "read", "resource": "book"}

"output": { "decision": true, "id": 1231231, "obligation": "mask sensitive data"}
```