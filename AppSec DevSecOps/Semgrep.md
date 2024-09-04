Learn: https://academy.semgrep.dev/courses/take/custom-rules/lessons/55446939-how-to-get-started

### Basics
Syntax: https://semgrep.dev/docs/writing-rules/rule-syntax
semgrep --validate --config [filename]

### Run
Docker: 
```
# https://semgrep.dev/onboarding/scan
docker pull semgrep/semgrep
docker run -e SEMGREP_APP_TOKEN=$ --rm -v "${PWD}:/src" semgrep/semgrep semgrep ci
```

### Rules
```
rules:
  - id: rule-writing-fundamentals
    languages:
      - js
    severity: ERROR
    message: Semgrep matched a metavariable with the value `$FUNC` 
    pattern: db_query(...)
```

`FUNC(...)` выбрать все внутри функции
`"..."` выбрать любое значение str 
`...` выбрать все
`$X` обозначает любую переменную

`pattern` единичный паттерн ||
`pattern-either` логическое ИЛИ после нужно указать единичные паттерны
`pattern-not` исключение
`pattern-inside` 
`metavariable-regex` обязательно указать metavariable: '$F' И regex: '.*(fee|salary).*'

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