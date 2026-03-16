# 1. Что такое сериализация и десериализация

### Сериализация
Это процесс превращения **Java-объекта в поток байтов**, чтобы его можно было:
* сохранить в файл
* отправить по сети
* сохранить в кэше

Например:
```java
ObjectOutputStream out = new ObjectOutputStream(new FileOutputStream("user.ser"));
out.writeObject(user);
```
Java объект → `user.ser` файл. ([Greyshell’s Diary][1])

---
### Десериализация
Обратный процесс — **восстановление объекта из байтов**.

```java
ObjectInputStream in = new ObjectInputStream(new FileInputStream("user.ser"));
User user = (User) in.readObject();
```

Файл → Java объект в памяти. ([Greyshell’s Diary][1])
---

# 2. Интерфейс Serializable
Чтобы объект можно было сериализовать, класс должен реализовать:
```java
class User implements Serializable {
}
```

Это **marker interface** — у него нет методов.
Он просто говорит JVM:
> этот объект можно сериализовать. ([Greyshell’s Diary][1])

---

# 3. Где возникает уязвимость
Главная проблема — метод:
```java
ObjectInputStream.readObject()
```

Во время десериализации он:
1. читает байты
2. **создаёт объект любого класса из classpath**
3. только потом проверяет тип

То есть порядок такой:
```
1. Создать объект
2. Выполнить его код
3. Проверить тип
```

Если объект делает **что-то вредоносное при создании**, проверка типа уже **слишком поздно**. ([Greyshell’s Diary][1])
---
# 4. Пример проблемы с наследованием
Допустим есть:
```java
class User implements Serializable
class SuperUser extends User
```

Если код ожидает:
```java
User u = (User) in.readObject();
```
и атакер передаст:

```
SuperUser
```

ошибки не будет, потому что:

```
SuperUser is-a User
```

То есть можно подсунуть **другой класс**. ([Greyshell’s Diary][1])

---

# 5. Почему это опасно

Атакер может отправить **специальный сериализованный объект**.

При десериализации можно:

### 1️⃣ Выполнить код на сервере (RCE)

Используя gadget chains.

Например:

```
Runtime.getRuntime().exec("gnome-calculator")
```

В статье пример payload генерируется через **ysoserial**. ([Greyshell’s Diary][1])

---

### 2️⃣ DoS

Объект может:

* бесконечно аллоцировать память
* загружать CPU

→ сервер падает. ([Greyshell’s Diary][1])

---

### 3️⃣ Обход авторизации

Если сериализуется объект с ролью:

```
User(role="user")
```

атакер может подменить на

```
User(role="admin")
```

если нет проверки подписи.

---

# 6. Как находить эту уязвимость

Content-Type: application/x-java-serialized-object

Ищем в коде:
```
ObjectInputStream
readObject()
```

пример payload:
```
java -jar ysoserial.jar CommonsCollections7 calc
```

# 7. Как защищаться

## 1️⃣ Никогда не десериализовать недоверенные данные
Самое важное правило.
---
## 2️⃣ Whitelist классов
Создать свой `ObjectInputStream`:

```java
class SafeObjectInputStream extends ObjectInputStream {

    protected Class<?> resolveClass(ObjectStreamClass cls) {
        if (!whitelist.contains(cls.getName())) {
            throw new InvalidClassException();
        }
    }
}
```
Тогда только разрешённые классы можно десериализовать. ([Greyshell’s Diary][1])
---

## 3️⃣ transient для секретных полей

```java
transient String password;
```

Поле не будет сериализовано. ([Greyshell’s Diary][1])

---

## 4️⃣ Security Manager / блокировка gadget-классов

Например:

```
InvokerTransformer
```

---


[1]: https://greyshell.github.io/posts/insecure_deserialization_java/?utm_source=chatgpt.com "Insecure Deserialization in Java | Greyshell's Diary"
[2]: https://greyshell.github.io/posts/demystify_java_gadget_chain/?utm_source=chatgpt.com "Demystify a Java gadget chain to exploit insecure deserialization | Greyshell's Diary"
