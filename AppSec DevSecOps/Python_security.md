* SAST tools > semgrep,  SonarQube, Codacy, Pylint, Pyflakes
* Virtual environment and network isolation > isolate dev stand
```bash
python3 -m pip install virtualenv
python3 -m venv env
source venv/bin/activate
```
* Modules > import only what u need
```python
from sys import stdin
from sys import * # not secure
```
*  Input validation
   - whitelist: regex
   - blacklist: bad practice
*  Try-except vs. if-else
  - it is safer to use the try-except block when we are unsure about possible errors or when there is little possibility of some error/exception. In the other cases, it is recommended to use the if-else block
*  Check library, framework vulnerabilities / Open Source Security
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
