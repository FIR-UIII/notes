# Certs 

### Generate cert (TLS)
```sh
# private key
openssl genrsa -out https_private.key 2048
# pub key
openssl req -new -x509 -sha256 -key https_private.key -out https_public.crt -days 365
```

### PEM to string
```
awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' privatekey.pem > privatekey.cer
```

### PFX to PEM
```
openssl pkcs12 -in certificate.pfx -clcerts -nokeys -out certificate.crt
# извлекаем приватный ключ
openssl pkcs12 -in certificate.pfx -nocerts -out key-encrypted.key
# для снятия парольной защиты с приватного ключа
openssl rsa -in key-encrypted.key -out key-decrypted.key
```
