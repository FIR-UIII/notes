# Requests
```python
# GET
payload = {'key1': 'value1', 'key2': 'value2'}
response = requests.get('http://.com', params=payload)
print(response.text)

# POST
payload = {'key1': 'value1', 'key2': 'value2'}
response = requests.post('http://httpbin.org/post', data=payload)
```

# Basics
```python
name: str = "Ivan" # добавляй тип данных и контекст
age: list[int] = [20,  50, 30] # аналогично для списка и проч

def greet(greeting: str, people: list[str]) -> None: # return  None
    """add how func works here"""
    # or use comments
def greet(greeting: str, people: list[str]) -> str: # return some string

if __name__ == `__main__`:
    main_function()
```

### Banner
https://www.youtube.com/watch?v=Xh7bEIvUQfM

### Find, Regex
```python
### Sample 1
import re
text = "My phone number is 123-456-7890" # Sample text
pattern = r"\d{3}-\d{3}-\d{4}" # Pattern to match a phone number
match = re.search(pattern, text) # Search for the pattern in the text
if match:
    print(f"Phone number found: {match.group()}")
else:
    print("No phone number found")

### Sample 2
script_tags = [elem.tag for elem in root.iter() if re.search(r'script', elem.tag, re.IGNORECASE)]
print(f"[+] Potential XSS vulnerability detected in element: {script_tags}")
```

# modules, package, `__init__.py`
Exaple stucture
```
├── main.py
└── package
    ├── __init__.py
    ├── module1.py
    ├── module2.py
    └── sub_pack
        ├── __init__.py
        └── submod1.py
```

### __init__.py
```py
# __init__.py marking the directory as a Python package
# file can be empty or contain initialization code
from .module1 import *
from . import module1, module2

# main.py
import package
from package import module2
print(dir(package))

# submod1.py
import ..module1
from ..module1 import *

```

# OOP
```
class BlueCar:
    def __init__(self, brand: str) -> None:
    '''Функция определяющее по поведение класса по умолчанию'''
        self.brand = brand
        self.drive: bool = False

    def drive(self) -> None:
        if self.drive:
            print(f'The Car ({self.brand}) is already driving')
        else:
            self.drive = True
            print(f'The Car ({self.brand}) is now driving')
tesla = BlueCar('Tesla') # the same as tesla: BlueCar = BlueCar()
```

# Crypto
```py
from hashlib import sha256
message = b'message'
print(hash_function = sha256(message))

# Функции контрольного суммирования. Контрольное суммирование происходит быстрее, но в ущерб криптографической стойкости.
import zlib
message = b'this is repetitious' * 42
checksum = zlib.crc32(message)
compressed = zlib.compress(message)
decompressed = zlib.decompress(compressed)
zlib.crc32(decompressed) == checksum

# Генерация случайных чисел
import random # небезопасен
import os.urandom # источник этих байтов – сама операционная система аналог /dev/urandom
import secrets # специальный модуль для генерации криптобезопасных случайных чисел 
    token_bytes(16) # генерация 16 случайных байт
    token_hex(16) # генерация 16 случайных байт в виде шестнадцатеричного текста
    token_urlsafe(16) # генерация 16 случайных байт для URL 

# Хеширование с ключом / HMAC с
import hashlib
import hmac
hmac_sha256 = hmac.new(b'key', msg=b'message', digestmod=hashlib.sha256)
print(hmac_sha256.hexdigest()) # Хеш в виде шестнадцатеричного текста
```
