### Безопасность серилизации данных JSON, XML, YAML
https://blog.trailofbits.com/2025/06/17/unexpected-security-footguns-in-gos-parsers/
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
