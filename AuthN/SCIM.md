### SCIM
https://www.rfc-editor.org/info/rfc7643/

SCIM решает задачу: "Как сделать так, чтобы система заранее знала о пользователе, его правах (ролях), группах и вовремя его удаляла или обновляла о нем информацию?" т.е. решение задачи IdM. По сравнению с прямой интеграцией с LDAP, Active Directory или SQL, SCIM представляет собой более современную и легковесную альтернативу. 
Он предлагает API на основе REST, что упрощает его внедрение.

В основе SCIM лежат два привычных веб-стандарта: REST API и формат данных JSON.
Протокол делит:
1. SCIM Client (Identity Provider / IdP): Источник правды. Место, где сидит администратор и управляет сотрудниками. Примеры: Microsoft Entra ID (Azure AD), Okta, Keycloak (как клиент).
2. SCIM Server (Service Provider / SP): Конечная система (клиент), которой пользуются люди и где должны появиться учетные записи. Примеры: Zoom, Slack, Salesforce, Jira, ваше собственное корпоративное приложение.

Жизненный цикл пользователя в SCIM. Когда в компании происходят кадровые изменения, IdP отправляет стандартные HTTP-запросы к серверу SCIM:
• Наем сотрудника (Create): SCIM Client отправляет POST /Users с JSON-телом, где указаны имя, email и департамент. Приложение принимает запрос и автоматически создает у себя учетную запись.
```
curl -X POST http://localhost:8080/realms/myrealm/scim/v2/Users \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/scim+json" \
  -d '{
    "schemas": ["urn:ietf:params:scim:schemas:core:2.0:User"],
    "userName": "jdoe",
    "name": {
      "givenName": "John",
      "familyName": "Doe"
    },
    "emails": [
      {
        "value": "jdoe@example.com",
        "type": "work",
        "primary": true
      }
    ],
    "active": true
  }'
```

• Смена фамилии или отдела (Update): Сотрудница сменила фамилию. SCIM Client отправляет PUT /Users/{id} или PATCH /Users/{id}. Данные в приложении мгновенно обновляются.
```
curl -X PUT http://localhost:8080/realms/myrealm/scim/v2/Users/{id} \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/scim+json" \
  -d '{
    "schemas": ["urn:ietf:params:scim:schemas:core:2.0:User"],
    "id": "{id}",
    "userName": "jdoe",
    "name": {
      "givenName": "John",
      "familyName": "Smith"
    },
    "emails": [
      {
        "value": "john.smith@example.com",
        "type": "work",
        "primary": true
      }
    ],
    "active": true
  }'
```

• Увольнение (Delete / Deactivate): Администратор блокирует учетную запись в главном каталоге. SCIM Client отправляет запрос на отключение (active: false) или удаление DELETE /Users/{id}. Доступ к приложению закрывается за секунду.
```
curl -X DELETE http://localhost:8080/realms/myrealm/scim/v2/Users/{id} \
  -H "Authorization: Bearer $ACCESS_TOKEN"
```
