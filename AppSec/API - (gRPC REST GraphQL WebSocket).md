### REST (API) 
Representational state transfer. 
Описание: Client-Server, использует HTTP методы
Транспорт: HTTP
Формат данных: JSON
Пример:
```
GET /users  # для получения списка пользователей;
ответ: 
HTTP/1.1 200 OK 
Content-Type: application/json 
    { 
        "id": 1, 
        "name": "Alex" 
    }
```

### GraphQL
Facebook
Описание: есть единая точка доступа к приложению — `/graphql`. На нее мы отправляем все наши запросы. Cводит получение данных к одному запросу через один endpoint «дай всё, что есть». Строго типизирован.
Транспорт: HTTP, Websockets, SSH
Формат данных: JSON
Пример:
```

query GetCategories {
    categories {
        name
        id
    }
}
ответ: 
{
    "data": {
        "categories": [
            "name": "Electronics", "id": "1",
            "name": "Clothing", "id": "2",
            "name": "Books", "id": "3"
        ]
    }
}
```


### gRPS
https://book.hacktricks.xyz/pentesting-web/grpc-web-pentest
https://www.youtube.com/watch?v=w75_ixNzM24&ab_channel=AminNasiri
Описание: 
Транспорт: HTTP/2 
Задача:  вызов процедур. одна точка входа, и телом запроса определяется, какой ресурс или какое действие будет выполнено. Позволяет передавать данные потоком, не дожидаясь ответа.
Поддерживает: SSL/TLS (mTLS, no TLS, Server-side TLS), ALTS (механизм защиты данных), аутентификация на основе токенов. 
Формат данных: Protobuf - протокол (передачи) структурированных данных (аналог XML, JSON но в машинном виде)
```
08 96 01 # tag lengh value
```

**Как работает**
Т.к. реализация на HTTP/2 данные идут потоком (Stream_ID) а сами данные делятся на заголовки (headers) и данные (data). В HTTP нужно искать content-type:"application/grpc"

![[Pasted image 20240104125559.png]]

```Python
### Выполняет простой вызов RPC к серверу с именем "Hello Greeter". Сервер возвращает сообщение "Hello, John Doe!"

import grpc
from greeter import GreeterStub
def main():
    # Создаем канал для подключения к серверу
    channel = grpc.insecure_channel("localhost:50051")
    # Создаем заглушку клиента
    client = GreeterStub(channel)
    # Создаем запрос
    request = GreeterRequest(name="John Doe")
    # Выполняем вызов
    response = client.SayHello(request)
    # Печатаем ответ
    print(response.message)
if __name__ == "__main__":
    main()
```

**Как тестировать:**
Сканирование: 
стандартные порты 50050, 50051

Инструменты которые могут пригодиться
1. https://github.com/fullstorydev/grpcui инструмент командной строки, который позволяет взаимодействовать с серверами gRPC через браузер
2. https://github.com/fullstorydev/grpcurl
3. Postman
4. BurpSuite


перехват трафика (прокси) - десерилизация (дешифровка) protobuf - отправляем в Intruder:
	фаззинг
	ввод payload

### **gRPC-web**
протокол на JS отличается но имеет protobuf

### WebSocket
Описание: 
Транспорт: TCP (держит постоянное соединение с сервером - сессию)
Задача: Real-time applications, Chat application, Games, Dashboards, IoT
Формат данных: бинарный формат, внутри которого вы можете передавать что угодно в удобной для вашего приложения форме
Пример:
```
socket.send(JSON.stringify({ type: 'getCategories' }));
ответ:
[1,2,3]
```

OAuth2 - токены аутентификации
JWT-токенов
шлюз BFF