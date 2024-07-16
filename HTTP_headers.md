
| Заголовок                     | Описание                                                                                   | Рекомендуемое значение | ПСИ проверка                                                                                   |
|--------------------------------|------------------------------------------------------------------------------------------|------------------------|------------------------------------------------------------------------------------------------|
| Content-Security-Policy        | Определяет откуда можно загружать контент на страницу.                                   | [content-security-policy.com](https://content-security-policy.com/)                                     | [CSP Evaluator](https://csp-evaluator.withgoogle.com/)                                               |
| X-Content-Type-Options         | Предотвращает неправильную интерпретацию браузером MIME-типов загружаемых ресурсов.     | `nosniff`               | -                                                                                    |
| Content-Type                   | Определяет тип передаваемого контента.                                                    | `text/html; charset=UTF-8` | -                                                                                    |
| X-Frame-Options               | Предотвращает встраивание вашего документа в другие приложения.                           | `DENY`, `SAMEORIGIN`     | -                                                                                    |
| CORP                          | Защита от встраивания для предотвращения возможности использования ресурсов вашего сайта.   | `same-origin`            | -                                                                                    |
| COOP                          | Защита от встраивания позволяет запретить открытие вашего сайта с помощью `window.open()`. | `same-origin`            | -                                                                                    |
| COEP                          | Защита от встраивания требует использование `Cross-Origin-Resource-Policy`.                 | `require-corp`           | -                                                                                    |
| CORS                           | Частичная защита от XSS и CSRF.                                                          | `Access-Control-Allow-Origin: https://example.com` | -                                                                                    |
| HSTS                          | Обеспечивает обслуживание всего контента вашего приложения через HTTPS.                  | `max-age=<expire-time>; includeSubDomains` | -                                                                                    |
| Referrer-Policy               | Определяет содержание информации о реферере, указываемой в заголовке Referer.            | `strict-origin-when-cross-origin` | -                                                                                    |
| Set-Cookie                     | Управляет установкой cookie.                                                              | `Secure`, `SameSite: Lax`, `HttpOnly` | -                                                                                    |
| Clear-Site-Data              | Запускает очистку хранящихся в браузере данных (куки, хранилище, кеш), связанных с источником. | `"cache", "cookies", "storage"` | -                                                                                    |
| X-XSS-Protection              | Приказывает браузеру прервать выполнение обнаруженных атак межсайтового скриптинга.        | `1; mode=block`           | -                                                                                    |
| Permissions-Policy            | Управляет доступом к определенным функциям браузера.                                    | `camera=(), fullscreen=*, geolocation=(self "https://example.com" "https://another.example.com")` | -                                                                                    |




const dbRequest = indexedDB.open("YourDatabaseName");

dbRequest.onsuccess = function(event) {
  const db = event.target.result;
  const transaction = db.transaction(["yourObjectStore"], "readonly");
  const objectStore = transaction.objectStore("yourObjectStore");
  const getRequest = objectStore.getAll();

  getRequest.onsuccess = function(event) {
    // Alert the data
    alert(JSON.stringify(event.target.result));
  };
};

dbRequest.onerror = function(event) {
  console.error("Error opening database:", event.target.errorCode);
};
