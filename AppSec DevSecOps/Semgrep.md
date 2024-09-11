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
2. Стратегия обрубания: Скопировать кусок "уязвимого кода" в pattern и начать "обрубать" фолсы выявляя общий паттерн через добавление pattern-not. https://semgrep.dev/docs/writing-rules/generic-pattern-matching
3. Стратегия регулярное выражение: Если уязвимость можно найти по регулярному выражению - regex101.com
4. Стратегия добавления мета: для дополнительной фильтрации переменных $X как тонкая настройка правила
  поиск переменных которые `><=` какого-то значения > `metavariable-comparison`
  поиск конкретной переменной > `focus-metavariable`
  поиск по доп.правилу > `metavariable-pattern`
  поиск по рег.выражению > `metavariable-regex` metavariable: $METHOD regex: (insecure)
  поиск по типу > `metavariable-type` metavariable: $Y type: String или java.util.logging.LogRecord
  поиск по анализаторам энтропия > `metavariable-analysis` analyzer: entropy metavariable: $VARIABLE
 
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
    patterns: # логическое И. Все правила должны быть выполнены. Найдет только совпадения обоих правил
      - pattern: TODO # ищет точно совпадение
      - pattern-not: TODO # исключение
      - pattern-not-inside: TODO # исключает внутри класса
      - pattern-inside: class $CLASS: ...  # будет искать внутри класса, функции
      - pattern-regex: \d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3} # регулярное выражение
      - pattern-not-regex: -foo # исключение регулярное выражение

    pattern-either: # логическое ИЛИ. A+B. Будет искать все совпадения.
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

### Find secret
```
rules:
  - id: generic-entropy-assignment
    patterns:
      - pattern: string $A = "$B";
      - metavariable-analysis:
          analyzer: entropy
          metavariable: $B
```

### Find key < 2048
```
# найти pvk, err := rsa.GenerateKey(rand.Reader, 1024)
rules:
  - id: use-of-weak-rsa-key
    languages:
      - go
    severity: ERROR
    message: RSA < 2048
    patterns:
      - pattern: rsa.GenerateKey($X, $KEYSIZE)
      - metavariable-comparison:
          comparison: $KEYSIZE < 2048 and $KEYSIZE != 0
          metavariable: $KEYSIZE
```