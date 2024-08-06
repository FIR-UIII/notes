hook# requests
```
GET

payload = {'key1': 'value1', 'key2': 'value2'}
response = requests.get('http://.com', params=payload)
print(response.text)


POST
payload = {'key1': 'value1', 'key2': 'value2'}
response = requests.post('http://httpbin.org/post', data=payload)



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
        ├── submod1.py
        └── submod2.py
```

### __init__.py
```py
# __init__.py marking the directory as a Python package
# file can be empty or contain initialization code
from .module1 import *
from . import module1, module2

# main.py
import package
print(dir(package))

# submid1.py
import ..module1

```
