```bash
1. Скачать CLI
https://github.com/github/codeql-cli-binaries/releases
Добавить путь исполняемого файла codeql в $PATH и проверить выполнение 
export PATH=$PATH:/path/to/codeql
> codeql --version

Провести тест
> codeql resolve languages
    python (C:\codeql\python)
> codeql resolve packs

2. Скачать workspace
https://github.com/github/vscode-codeql-starter
Открыть его в vscode

3. Установить расширение для vscode
GitHub.vscode-codeql

4. Скачать код и создать базу данных для анализа
git clone <you-repo-with-code>
cd <you-repo-with-code>
$ codeql database create /codeql-dbs/example-repo --language=javascript \    --source-root /checkouts/example-repo

$ codeql database create /codeql-dbs/example-repo-multi \
    --db-cluster --language python,cpp \
    --command make --no-run-unnecessary-builds \
    --source-root /checkouts/example-repo-multi
  Successfully created database at ...

5. При необходимости установить недостающие библиотеки/модули (если есть ошибка could not resolve module javascript)
vscode Ctrl+Shift+P> CodeQL: Install Pack Dependencies
vscode Ctrl+Shift+P> CodeQL: Download Packs
$ codeql pack install codeql/python-all # установить конретный набор
    codeql/cpp-queries
    codeql/csharp-queries
    codeql/go-queries
    codeql/java-queries
    codeql/javascript-queries
    codeql/python-queries
    codeql/ruby-queries

6. Добавить БД в рабочую область
В пространстве vscode из зайти в расширение codeql выбрать БД созданную ранее 
И обязательно нажать правой кнопкой контекстное меню и выбрать добавить add database source to workspace

7. запустить тестовый шаблон ql для проверки работы кода. 
Также можно запустить формирование AST

8. Shortcuts
{
  "key": "ctrl+r",
  "command": "codeQL.runLocalQueryFromFileTab",
  "when": "\"resourceFilename == '*.ql\"'"
}

9. Recon
Найти sink, sources

10. Vulnerability reseach
```

https://github.com/github/codeql/tree/main
https://codeql.github.com/codeql-standard-libraries/python/
https://codeql.github.com/docs/codeql-language-guides/codeql-for-go/
https://github.com/GeekMasher/security-codeql

### CodeQL qeury and pack
1. Создать qlpack.yml
```yaml
name: codeql/java-queries
version: 0.0.6-dev
groups: java
suites: codeql-suites
extractor: java
defaultSuiteFile: codeql-suites/java-code-scanning.qls
dependencies:
    codeql/java-all: "*"
    codeql/suite-helpers: "*"
```

2. Написать запрос query.ql в том же каталоге
```sql
/**
https://codeql.github.com/docs/writing-codeql-queries/metadata-for-codeql-queries/
**/
import <module>
from IfStmt a # декларация переменных из модуля и присваивание ей названия a
where a = "Hello" # условие где a равно "Hello"
select a, "I found" # что вывести на экран
predicate name(ARG arg_name) {  } - как функции
class EmptyBlock extend Block { ... }

import python
from Call c
where c.getLocation().getFile().getRelativePath().regexpMatch("2/challenge-1/.*")
select c, "This is a function call"
```

3. Общая логика написания 
“Show me all function calls”
“Show me all function calls to functions called eval”
“Show me all function definitions”
“Show me all function definitions for functions called eval”
“Show me all method calls to methods called ‘execute’” (Ding dong. Does this remind you of a certain vulnerability?)
“Show me all method calls to methods called ‘execute’ defined within the django.db library”
“Show me all method calls to methods called ‘execute’ defined within the django.db library that do not take a string literal as input”

### Сценарии использования
1. SAST - использование как обычного сканера в pipeline по набору правил (query packs)
2. Аудит системы, построение модели угроз и поверхности атаки, выявление sink, source
3. Доизучение системы, например SCA выявлил библиотеку и нужно провести анализ достижимости

### Java
Expr - expressions 
Stmt - statements 

### JS



### Python