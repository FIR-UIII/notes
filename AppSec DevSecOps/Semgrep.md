При выборе SAST важно два отличительных фактора:
- широта поддержки ЯП, и библиотека правил
- гибкость и удобство языка для написания собственных правил

Learn: https://semgrep.dev/playground/

### Basics
Syntax: https://semgrep.dev/docs/writing-rules/rule-syntax
semgrep --validate --config [filename]

### Run
Docker: 
```
# https://semgrep.dev/onboarding/scan
docker pull semgrep/semgrep
docker run -it -v "${PWD}:/src" returntocorp/semgrep semgrep login
docker run -e SEMGREP_APP_TOKEN=... --rm -v "${PWD}:/src" returntocorp/semgrep semgrep ci
docker run -e SEMGREP_APP_TOKEN=... --rm -v "${PWD}:/src" returntocorp/semgrep semgrep ci --output scan_results.txt --text
```

### Rules
Общий концепт:
1. Составить список "уязвимого" и "правильного" кода для тестирования правила
2. Скопировать кусок "уязвимого кода" и начать обрубать лишние
3. 

```
# Testing rules
semgrep --config rule.yaml rule.fixed.py --autofix
```

`FUNC(...)` выбрать все внутри функции
`"..."` выбрать любое значение str 
`...` выбрать все
`$X` обозначает любую переменную

```
rules:
  - id: untitled_rule # название правила
    
    # применение нескольких правил одновременно 
    patterns: # логическое И. Все правила должны быть выполнены
      - pattern: TODO # ищет точно совпадение
      - pattern-not: TODO # исключение 
      - pattern-inside: class $CLASS: ...  # будет искать внутри класса, функции
      - pattern-regex: \d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3} # регулярное выражение
      - pattern-not-regex: -foo # исключение регулярное выражение

    pattern-either: # логическое ИЛИ. Хотя бы одно из правил должно быть выполнено.
      - pattern: hashlib.sha1(...)
      - pattern: hashlib.md5(...)

    # Единичные правила
    pattern: print("...") # функция с одним входным параметром str
    pattern: print(...) # функция с любым кол-вом входных параметров
    pattern: | # для многострочного правила поиска
      $FUNC(...) {
        ...
        make_transaction($PARAM);
        ...
      }

    metavariable-regex: #обязательно указать metavariable: '$F' И regex: '.*(fee|salary).*'
    pattern-sinks: #
    
    
    message: Semgrep found a match
    languages: 
        - python # описание ЯП для валидации
    severity: WARNING

    mode: taint
```

# Use cases

### Find library
```
pattern-either:
    - pattern: import $EXPORT from AcmeCorpHTTP;
    - pattern: import { $EXPORT } from AcmeCorpHTTP;
    - pattern: var $EXPORT = require('AcmeCorpHTTP');
    - pattern: var { $EXPORT } = require('AcmeCorpHTTP');
```

### Find class
```
pattern: new AcmeCorpHTTP.ProxyAgent(...);
```

### Find func
``` 
pattern: def get_user(): ...
pattern: requests.get("...", timeout=$X, verify=True)
```