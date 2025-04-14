```bash
1. Скачать CLI
https://github.com/github/codeql-cli-binaries/releases
Добавить путь исполняемого файла codeql в $PATH и проверить выполнение 
export PATH=$PATH:/path/to/codeql
> codeql --version

Провести тест
> codeql resolve langluages
> codeql resolve packs

2. Скачать workspace
https://github.com/github/vscode-codeql-starter
Открыть его в vscode

3. Установить расширение для vscode
GitHub.vscode-codeql

4. Скачать код и создать базу данных для анализа
git clone <you-repo-with-code>
cd <you-repo-with-code>
> codeql database create <database> --language=<language-identifier>
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
```

https://github.com/github/codeql/tree/main
https://codeql.github.com/codeql-standard-libraries/python/
https://codeql.github.com/docs/codeql-language-guides/codeql-for-go/
https://github.com/GeekMasher/security-codeql
```
/**
https://codeql.github.com/docs/writing-codeql-queries/metadata-for-codeql-queries/
//.
import <module>

from IfStmt a # декларация переменных из модуля и присваивание ей названия a
where a = "Hello" # условие где a равно "Hello"
select a, "I found" # что вывести на экран

predicate name(ARG arg_name) {  } - как функции


class EmptyBlock extend Block { ... }

```