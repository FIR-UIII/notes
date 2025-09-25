Безопасное исполнение
При использовании ORM - нужно понять какая версия используется в продукте. Если у нее есть CVE - найти.
Изучить документацию ORM
Слои безопасности при работе с СУБД:
- безопасное конфигурирование (некоторые функции ORM можно отключить при запуске приложения или обьявление функции или флагов)
- валидация пользотельского ввода до попадания в ORM на уровне приемника запроса
- использование безопасных функции - не вызывать сырой вызов raw query
- контекст использования: если код используется для миграции БД или его сборки, но не частью самого приложения в runtime

Анализ безопасного использования ORM sequelize
Документация: https://sequelize.org/docs/
Правила semgrep: https://semgrep.dev/playground/r/javascript.sequelize.security.audit.sequelize-injection-express.express-sequelize-injection?editorMode=advanced 

```
// Safe Тег sql автоматически экранирует значения, поэтому вам не придется беспокоиться о SQL-инъекциях.
User.findAll({where: sql`"data"->'id' = ${id}`,}); 
await sequelize.query(sql`SELECT * FROM users WHERE first_name = ${firstName}`);

// Safe Используется параметеризированный запрос ? replacements
m.sequelize.query(
  'SELECT * FROM projects WHERE status = ?',
  {
	replacements: [req.body.foo],
	type: QueryTypes.SELECT
  }
)

 
// Safe передача через механизм bind - синтаксис $1 или $key см. https://sequelize.org/docs/v6/core-concepts/raw-queries/#bind-parameter
await sequelize.query(
  'SELECT *, "text with literal $$1 and literal $$status" as t FROM projects WHERE status = $1',
  {
    bind: ['active'],
    type: QueryTypes.SELECT,
  },
);
```

Небезопасное исполнение
Don't put parameters in strings https://sequelize.org/docs/v7/querying/raw-queries/#%EF%B8%8F-dont-put-parameters-in-strings
### 1. Никогда не помещайте параметры в строки, включая строки PostgreSQL, заключенные в долларовые кавычки , так как это может легко привести к атакам с использованием SQL-инъекций.
Требование "Не помещайте параметры в строки" в документации Sequelize предупреждает об опасности SQL-инъекций, когда внешние данные подставляются внутрь строкового литерала SQL-запроса, особенно при использовании dollar-quoted строк (например, $$)
После досрочного закрытия строки всё, что следует далее (включая потенциально вредоносный код, подставленный злоумышленником), может быть выполнено СУБД
```
# уязвимый код
const id = '$$';

sequelize.query(
  sql`
DO $$
DECLARE r record;
BEGIN
  SELECT * FROM users WHERE id = ${id}; # Sequelize корректно экранирует значение переменной id, но проблема в другом. Строка, ограниченная $$, завершается, как только встречает очередные $$. Если злоумышленник передаст в качестве id значение $$, то строка с DO-блоком завершится досрочно
END
$$;
  `,
);
```
Чтобы избежать этой проблемы, Sequelize предлагает безопасные способы подстановки данных:
- Используйте replacements (подстановки) и bind parameters (привязанные параметры). 
```
await sequelize.query('SELECT * FROM projects WHERE status = :status', {
  replacements: { status: 'active' }, // Безопасно
  type: QueryTypes.SELECT
});
```
- Для имен таблиц и столбцов применяйте sql.identifier
Если нужно динамически подставлять имена, используйте специальную функцию sql.identifier(), которая корректно их экранирует.
```
SELECT * FROM ${sql.identifier('projects')}
```
- Для списков значений используйте sql.list. Если нужно подставить список значений в оператор IN, используйте sql.list(), чтобы Sequelize правильно сформировал синтаксис.
```
SELECT * FROM projects WHERE status IN ${sql.list(statuses)}
```

### 2. В Sequelize 6 некоторые атрибуты, указанные в параметре «attributes» средства поиска ( findAll, findOne, и т. д.), имели особое значение и не экранировались.
```
Например, следующий запрос:

await User.findAll({
  attributes: ['*', 'a.*', ['count(id)', 'count']],
});

Будет создан следующий SQL-код:
SELECT *, "a".*, count(id) AS "count" FROM "users"

Начиная с версии 7, будет выдан следующий SQL:
SELECT "*", "a.*", "count(id)" AS "count" FROM "users"

Это было сделано для повышения безопасности Sequelize за счёт уменьшения поверхности атаки ORM. Предыдущее поведение по-прежнему доступно, но для его использования необходимо явно включить его с помощью функций literal, colили fn:
User.findAll({
  attributes: [sql.col('*'), sql.col('a.*'), [sql`count(id)`, 'count']],
});
```

### 3. При использовании json()
In Sequelize 6, you could use raw SQL in json() functions:
```
import { json } from 'sequelize';

// This was valid in Sequelize 6
User.findAll({
  where: where(json(`("data"->id)`), Op.eq, id),
});
```
Чтобы предотвратить риск внедрения SQL-кода, единственный способ использования сырого SQL в Sequelize — через sqlтег шаблона, literalфункцию или sequelize.query
```
import { sql } from '@sequelize/core';

// This is valid in Sequelize 7
User.findAll({
  where: sql`"data"->'id' = ${id}`,
});
```

### Написание сырых запросов sequelize.query
При интерполяции переменных в запросе обязательно убедитесь, что вы помечаете свой запрос тегом sql. sequelize.query— одна из немногих функций, которая интерпретирует простые строки как чистый SQL, поэтому если вы забудете пометить свой запрос тегом , sqlэто может привести к уязвимостям SQL-инъекции:
```
// Dangerous Case 0
await sequelize.query(`SELECT * FROM users WHERE first_name = ${firstName}`);

// Dangerous Case 1: run query by string concatenation using template literals
db.sequelize.query(
  `INSERT INTO user (username, password) VALUES('${username}','${password}')`
)

// Dangerous Case 3: Build query by string concatenation using template literals
var query = `INSERT INTO user (username, password) VALUES('${username}','${password}')`
console.log("check password");
db.sequelize.query(query)

// Dangerous Case 4: run query by string concatenation using + operator
b.sequelize.query(
  "INSERT INTO user (username, password) VALUES('" + username + "','" + password + "')"
)

// Dangerous Case 5: Build query by string concatenation using + operator
var query = "INSERT INTO user (username, password) VALUES('" + username + "','" + password + "')"
console.log("check password");
db.sequelize.query(query)

// Safe
await sequelize.query(sql`SELECT * FROM users WHERE first_name = ${firstName}`);
```

### CVE-2023-25813 SQL-инъекция через замены, исправлено в Sequelize >= 6.19.2.
Не используйте параметр replacements и where в одном запросе, если вы не используете Sequelize >= 6.19.2.
```
User.findAll({
  where: or(
    literal('soundex("firstName") = soundex(:firstName)'),
    { lastName: lastName },
  ),
  replacements: { firstName },
})
```
Если пользователь передал такие значения, как
{
  "firstName": "OR true; DROP TABLE users;",
  "lastName": ":firstName"
}
Sequelize сначала сгенерирует такой запрос: SELECT * FROM users WHERE soundex("firstName") = soundex(:firstName) OR "lastName" = ':firstName'
