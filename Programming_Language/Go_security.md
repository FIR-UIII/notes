### Безопасность серилизации данных JSON, XML, YAML
https://blog.trailofbits.com/2025/06/17/unexpected-security-footguns-in-gos-parsers
https://bishopfox.com/blog/json-interoperability-vulnerabilities

1. Неправильное использование тега для ограничения изменения поля
Правило SAST: https://github.com/trailofbits/semgrep-rules/blob/main/go/unmarshal_tag_is_dash.yaml
```go
// Неправильно
type User struct {
    Username string `json:"username,omitempty"`
    Password string `json:"password,omitempty"`
    IsAdmin  bool   `json:"-,omitempty"` // при передаче значения {"-": true}, результат: {Username:"", Password:"", IsAdmin:true}
}
`-` вместо тега стал ключом из-за разделителя запятой `-,`

// Правильно:
type User struct {
    Username string  `json:"username,omitempty"`
    Password string  `json:"password,omitempty"`
    IsAdmin  bool    `json:"-"`
}
```
2. Неправительное использование omitempty
Правило SAST: https://github.com/trailofbits/semgrep-rules/blob/main/go/unmarshal_tag_is_omitempty.yaml
```go
// Неправильно
type User struct {
    Username string `json:"omitempty"` // парсер будет использовать его omitempty в качестве значения
}
```
3. Ошибки логики обработки значений
```go
// От пользователя модет прийти запрос с передачей дублирующего значения {"action": "Action1", "action": "Action2"}. В Go парсер JSON всегда выбирает последний . Предотвратить это поведение невозможно.
в логике кода следует создать обработку ошибки при дублировании полей и создание безопасного значения по умолчанию
```
4. Сопоставление ключей без учета регистра
```go
// JSON-парсер Go анализирует имена полей без учёта регистра. Независимо от того, пишете ли вы action action, ACTION, или aCtIoN, парсер считает их идентичными. См. https://pkg.go.dev/encoding/json#Unmarshal
```
5. Путаница в форматах данных, кодировке
```go
// Если поведение системы заыисит от Content-type, Accept заголовков, то злоумышленник может изменить формат и обойти логику парсера
// По умолчанию анализаторы JSON, XML и YAML не блокируют неизвестные поля.
// Предотвращение появления мусорных данных []{}#/* и их санитизация. Не доверять полям от пользователя
// Возможна атака с передачей больних чисел 1E+96. Такие ошибки часто возникают при обработке целых чисел или чисел с плавающей точкой, которые невозможно точно представить.
// Возможна атака на парсер с передачей сломанной кодировки `\ud888`
// Реализуйте строгий парсинг по умолчанию . Используйте DisallowUnknownFields для JSON KnownFields(true)и YAML. К сожалению, это всё, что можно сделать напрямую с помощью API парсера Go.
// Поддерживайте согласованность данных при обработке. При обработке входных данных в нескольких сервисах обеспечьте единообразие результатов анализа, всегда используя один и тот же парсер или реализуя дополнительные уровни проверки, например, strictJSONParseфункцию
```
