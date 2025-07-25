
| Заголовок                     | Описание                                                                                   | Рекомендуемое значение | Проверка                                                                                   |
|--------------------------------|------------------------------------------------------------------------------------------|------------------------|------------------------------------------------------------------------------------------------|
|[**Content-Security-Policy**](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy)| Определяет откуда можно загружать контент на страницу [content-security-policy.com](https://content-security-policy.com/) [CSP Evaluator](https://csp-evaluator.withgoogle.com/)| `Content-Security-Policy: default-src 'self'; img-src  'self'; media-src media1.com media2.com; script-src example.com`<br>`Content-Security-Policy: frame-ancestors 'self' *.somesite.com https[:]//myfriend.site.com;`<br>`Content-Security-Policy-Report-Only: default-src https:report-uri /csp-report-url/; report-to csp-endpoint;`| ```eval('alert("Hello, world!");');```|
| [**X-Content-Type-Options**](https://developer.mozilla.org/ru/docs/Web/HTTP/Headers/X-Content-Type-Options)| Предотвращает неправильную интерпретацию браузером MIME-типов загружаемых ресурсов | `X-Content-Type-Options: nosniff`<br>`Content-Type: text/html; charset=utf-8` | - |
| [**Content-Type**](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Type)| Определяет тип передаваемого контента. Если тип контента — text/*, /+xml или application/xml, то должна быть указана кодировка (например, charset=UTF-8 или ISO-8859-5) | `text/html; charset=UTF-8` | - |
| [***X-Frame-Options**](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Frame-Options)| Предотвращает встраивание вашего документа в другие приложения. Небезопасные настройки:<br> `X-Frame-Options: AllowAll`| `X-Frame-Options: DENY` - полный запрет<br> `X-Frame-Options: SAMEORIGIN` - для своего домена| - |
| [**CORP**](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cross-Origin-Resource-Policy)| Защита от встраивания для предотвращения возможности использования ресурсов вашего сайта.   | `Cross-Origin-Resource-Policy: same-origin` | - |
| [**COOP**](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cross-Origin-Opener-Policy)| Защита от встраивания позволяет запретить открытие вашего сайта с помощью `window.open()`. | `Cross-Origin-Opener-Policy: same-origin` | - |
| [**COEP**](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cross-Origin-Embedder-Policy) | Защита от встраивания требует использование `Cross-Origin-Resource-Policy` | `require-corp`| - |
| [**CORS**](https://developer.mozilla.org/ru/docs/Web/HTTP/CORS) | Частичная защита от XSS и CSRF. Разрешает другим сайтам через JS, CSS обращаться к ресурсам вашего сайта, а также увеличивает поверхность атаки в случае передачи данных пользователя<br> Небезопасные настройки:<br> `Access-Control-Allow-Origin: *`| `Access-Control-Allow-Origin: https://example.com`<br>`Access-Control-Allow-Credentials=True` | С другого сайта (вкладки)<br>```fetch('http://localhost:8888/api/users').then(response => response.text()).then(data => console.log(data)).catch(error => console.error('Error:', error));``` |
| [**HSTS / Strict-Transport-Security**](https://developer.mozilla.org/ru/docs/Web/HTTP/Headers/Strict-Transport-Security)| Обеспечивает обслуживание всего контента вашего приложения через HTTPS.| `Strict-Transport-Security: max-age=15778463; includeSubDomains` | - |
| [**Referrer-Policy**](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Referrer-Policy)| Определяет содержание информации о реферере, указываемой в заголовке Referer| `Referrer-Policy: strict-origin-when-cross-origin` | - |
| [**Set-Cookie**](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie)| Управляет установкой cookie | `Secure`, `SameSite: Strict`, `HttpOnly` `Path=/` `__Host`| - |
| [**Clear-Site-Data**](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Clear-Site-Data)| Запускает очистку хранящихся в браузере данных (куки, хранилище, кеш), связанных с источником. | При выходе из сессии `Clear-Site-Data: "*"`<br>`Clear-Site-Data: "cache", "cookies", "storage", "executionContexts"` | - |
| [**X-XSS-Protection**](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-XSS-Protection)| **Deprecated** Приказывает браузеру прервать выполнение обнаруженных атак межсайтового скриптинга <br> X-XSS-Protection: 1 - включает санитизацию. Значение по умолчанию <br> X-XSS-Protection: 1; mode=block - включает блокирование исполнения <br> X-XSS-Protection: 1; report=<reporting-uri> <br> Небезопасные настройки: X-XSS-Protection: 0 - отключает | X-XSS-Protection: 1; mode=block | - |
| [**Permissions-Policy**](https://www.w3.org/TR/permissions-policy-1/) | Управляет доступом к определенным функциям браузера `camera=(), fullscreen=*, geolocation=(self) =() — полный запрет; =* — полный доступ; (self "https://example.com") — предоставление разрешения только указанному источнику | - | - |
|Server X-Powered-By X-Vault-Token ETag x-amz-request-id|Защита от раскрытия информации о сервере и техстеке|Рекомендуется исключить||

## Тестирование
https://securityheaders.com/
https://github.com/rustcohlnikov/awesome-frontend-security?tab=readme-ov-file

1. Получение информации о сервере через вызов ошибки
```http
GET %2f HTTP/2
Host: redacted.com

HTTP/2 400 Bad Request
Server: Apache
X-Content-Type-Options: nosniff
Accept-Ranges: bytes
Vary: X-Forwarded-Host,Origin # возврат этого заголовка - cache poisoning
X-REDACTED_Session: <redacted-value>
```

2. HTTP injection
Добавить X-Forwarded-Host -  spoofing, server-side request forgery (SSRF) и других
Host
X-Forwarded-For
X-Forwarded-Host
X-Forwarded-Proto
X-Real-IP
X-Envoy-External-Address
X-Envoy-Internal
X-Envoy-Original-Dst-Host

```
GET / HTTP/1.1
Host: test.com 
X-Forwarded-Host: test.com 

```
