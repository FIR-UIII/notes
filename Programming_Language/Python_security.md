* SAST tools > semgrep,  SonarQube, Codacy, Pylint, Pyflakes
* Virtual environment and network isolation > isolate dev stand

```bash
# использовать lock-файлы (pipenv, poetry, uv)
pip install pipenv

pipenv shell — активация виртуального окружения;
exit — выход из виртуального окружения;
pipenv check — проверка на наличие уязвимостей безопасности.
pipenv graph — отображение графа зависимостей
pipenv lock --requirements > requirements.txt

pipenv lock — генерация Pipfile.lock;
pipenv sync — установка пакетов из Pipfile.lock;
pipenv clean — удаление из virtualenv всех пакетов, которых нет в Pipfile.lock.

pipenv install scrapy==1.8.0 — установит фиксированную версию пакета;
pipenv install — установка всех пакетов из Pipfile;
pipenv uninstall --all — удаление всех установленных пакетов в виртуальной среде.

# альтернативный вариант использование отдельно вирутального окружения
python3 -m pip install virtualenv
python3 -m venv env
source venv/bin/activate
```

* Modules > import only what u need
```python
from sys import stdin
from sys import * # not secure
```

* phantom dependency
Испорт зависимости в теле функции
```py
try:
 import subprocess
...
```

*  Input validation
   - whitelist: regex
   - blacklist: bad practice
*  Try-except vs. if-else
  - it is safer to use the try-except block when we are unsure about possible errors or when there is little possibility of some error/exception. In the other cases, it is recommended to use the if-else block
*  Check library, framework vulnerabilities / Open Source Security<br>
Check offsites and CWE:
  - https://docs.python.org/3/library/security_warnings.html
  - https://codeql.github.com/codeql-query-help/python/
  - https://fastapi.tiangolo.com/tutorial/security/
  - https://docs.djangoproject.com/en/dev/howto/deployment/checklist/
*  Know vulnerable function
  - Function mktemp() has been deprecated since Python 2.3, but it is still in the module
  - do not use pickle module (using for serializing or de-serializing data), use JSON. do not pickle or unpickle data from untrusted sources. use HMAC or other algorithms for ensuring integrity of data
  - Command injection (try to avoid exec, eval, input, os.subprocess.function(), os.system())
  - Injections (SQLi, XSS etc.)
  - ReDoS attacks > DoS for regex
    visit https://owasp.org/www-community/attacks/Regular_expression_Denial_of_Service_-_ReDoS
    ```
    # vulnerable for input "aaaaaaaaaaaaaaaaaaaaaaaa!" causes timeouts and crashes:
    ([a-zA-Z]+)*
    (a|aa)+
    (.*a)x for x \>10
    ```
  - String formatting
  - XML attacks
  - Do not use Random use module secrets instead for cryptographic tasks
  - Do not use assert in production (Python interpreter removes assertion, and the assert condition will be skipped)
    ```python
    def check_permission(super_user):
      try:
      assert(super_user)
      print("\nYou are a super user\n")
      except AssertionError:
      print(f"\nNot a Super User!!!\n")
    ```
   - Tarfile and zipfile. Programmers should avoid using tarfile when extracting from untrusted sources > Use module tarsafe instead. Programmers can defend by setting and checking the maximum size of decompressed data and the maximum number of files
   - Buffer overflow

Optimized Asserts
внимательно смотреть на использование конструкций assert в логике безопасности. операторы assert следует использовать в качестве отладочных средств, а не для обработки ошибок во время выполнения. либо использовать try...except(...else...finally)
```py
def superuser_action(request, user):
    assert user.is_super_user
    # execute action as super user
```

Разрешения на создание каталогов
```py
def init_directories(request):
    os.makedirs("A/B/C", mode=0o700) # Функция os.makedirs создает папки А B C, в Python > 3.6 только последняя папка C имеет разрешение 700, а остальные папки A и B создаются с разрешением по умолчанию 755
    return HttpResponse("Done!")
```

Абсолютные соединения путей
Функция  os.path.join(path, *paths) используется для объединения нескольких компонентов пути файла в объединенный путь файла
Если один из добавленных компонентов начинается с  /, все предыдущие компоненты, включая базовый путь, удаляются, и этот компонент рассматривается как абсолютный путь
```py
def read_file(request): filename = request.POST['filename']
    file_path = os.path.join("var", "lib", filename)
    if file_path.find(".") != -1: # если злоумышленник передает параметр как /a/b/c.txt то результирующая переменная file_path в строке 3 является абсолютным путем к файлу
        return HttpResponse("Failed!") 
    with open(file_path) as f:
        return HttpResponse(f.read(), content_type='text/plain')
```

Произвольные временные файлы
Функция  tempfile.NamedTemporaryFile используется для создания временных файлов с определенным именем. Однако  параметры prefix и  suffix уязвимы для атаки обхода пути /../var/www/test
```py
def touch_tmp_file(request):
    id = request.GET["id"]
    tmp_file = tempfile.NamedTemporaryFile(prefix=id)
    return HttpResponse(f"tmp file: {tmp_file} created!", content_type="text/plain")
```

Zip Slip
В Python функции  TarFile.extractall и  TarFile.extract известны своей уязвимостью к  атаке Zip Slip. записи архива всегда следует рассматривать как ненадежные источники.
```py
def extract_html(request):
    filename = request.FILES["filename"]
    zf = zipfile.ZipFile(filename.temporary_file_path(), "r")
    for entry in zf.namelist():
        if entry.endswith(".html"):
            file_content = zf.read(entry)
            with open(entry, "wb") as fp:
                fp.write(file_content)
    zf.close()
    return HttpResponse("HTML files extracted!")
```

Неполное совпадение с регулярным выражением
В Python есть тонкое различие между  re.match и  re.search
не использовать список запрещенных регулярных выражений для любых проверок безопасности.
```py
def is_sql_injection(request):
    pattern = re.compile(r".*(union)|(select).*") # В строке 2 определяется шаблон, который соответствует  union или  select для обнаружения возможной SQL-инъекции
    name_to_test = request.GET["name"]
    if re.search(pattern, name_to_test): # aaaaaa \n union select пройдет валидацию
        return True
    return False
```

Обход кодировки Unicode
Пример уязвимого кода https://nvd.nist.gov/vuln/detail/CVE-2019-9636
```py
# шаблон 
<!DOCTYPE html>
<html lang="en">
    <body>
        {{ my_input | safe }} # При использовании ключевого слова  safe переменная не очищается
    </body>
</html>

# код  
import unicodedata
from django.shortcuts import render
from django.utils.html import escape

def render_input(request):
    user_input = escape(request.GET["p"]) # пользовательский ввод очищается  escape
    normalized_user_input = unicodedata.normalize("NFKC", user_input) # очищенный ввод нормализуется с помощью алгоритма NFKC, но если передать %EF%B9%A4 это будет преобразовано в < а %EF%B9%A5 в >
    context = {"my_input": normalized_user_input}
    return render(request, "test.html", context)
```

Конфликт регистров Unicode
символы Unicode сопоставляются с кодовыми точками. Однако существует множество различных человеческих языков, и Unicode пытается унифицировать их. 
Это также означает, что существует высокая вероятность того, что разные символы имеют одинаковую «раскладку». Например, строчный турецкий  ı символ (без точки) находится  I в верхнем регистре. 
```py
from django.core.mail import send_mail
from django.http import HttpResponse
from vuln.models import User

def reset_pw(request):
    email = request.GET["email"]
    result = User.objects.filter(email__exact=email.upper()).first() # злоумышленник может просто передать  foo@mıx.com адрес электронной почты в строке 6, где  i заменяется на турецкий  ı.
    if not result:
        return HttpResponse("User not found!")
    send_mail(
        "Reset Password",
        "Your new pw: 123456.",
        "from@example.com",
        [email],
        fail_silently=False,
    )
    return HttpResponse("Password reset email sent!")
```

Обход нормализации / санитизации
Злоумышленник может использовать нормализацию для обхода потенциальных валидаторов для атак Server-Side Request Forgery 
```py
import requests
import ipaddress

def send_request(request):
    ip = request.GET["ip"]
    try:
        if ip in ["127.0.0.1", "0.0.0.0"]:
            return HttpResponse("Not allowed!")
        ip = str(ipaddress.IPv4Address(ip)) # например 127.0.00.1 не входит в список запрещенных и после нормализации будет - 127.0.0.1 
    except ipaddress.AddressValueError:
        return HttpResponse("Error at validation!")
    requests.get("https://" + ip)
    return HttpResponse("Request send!")
```

Безопасность асинхронного кода (asyncio)<br>
Блокирующие вызовы (Blocking Calls). Проблема: Вызов синхронной блокирующей функции (например, тяжелое вычисление, time.sleep(10), синхронный HTTP-запрос) внутри асинхронной корутины блокирует весь цикл событий (event loop). Это останавливает выполнение всех других корутин в этом потоке, убивая производительность и масштабируемость.
```
async def bad_example():
    # Это заблокирует весь event loop на 10 секунд!
    time.sleep(10)

async def good_example():
    # Это асинхронно "уснет", позволив другим корутинам работать.
    await asyncio.sleep(10)
```

Гонка данных (Race Conditions)<br>
Проблема: Асинхронный код часто подразумевает работу с разделяемыми ресурсами (базами данных, кэшем, глобальными переменными). Так как корутины могут приостанавливаться и возобновляться в любой точке await, возникает классическая проблема гонки данных.
```
async def withdraw(amount):
    balance = await get_balance()  # Чтение баланса (допустим, 100)
    # В этот момент event loop может переключиться на другую корутину withdraw()
    if balance >= amount:
        await set_balance(balance - amount)  # Запись нового баланса
    # Если две корутины прочли 100 и пытаются снять 80, итоговый баланс будет 20, а не -60.
```

Доступ к "приватным" атрибутам и методам.<br>
Проблема: В Python нет настоящей инкапсуляции. Имена с ведущими двойными подчеркиваниями __private всего лишь искажаются (_MyClass__private), но все равно доступны извне. Это не механизм безопасности, а способ избежать конфликтов имен.

Динамический импорт (importlib)
Проблема: __import__(module_name) или importlib.import_module(module_name), куда передается пользовательский ввод, может привести к загрузке и выполнению нежелательного модуля.
Меры: Жестко валидируйте и ограничивайте строки, которые используются для динамического импорта. Используйте белые списки разрешенных модулей.

Магические методы (__del__)
Проблема: Метод __del__ (деструктор) вызывается не всегда и не предсказуемо из-за работы сборщика мусора. Код в нем может выбросить исключение, которое прервет выполнение программы в неожиданный момент.
Меры: Избегайте использования __del__ для критически важной логики (например, закрытия соединения с БД). Вместо этого используйте контекстные менеджеры (with statement) и явные методы .close().
