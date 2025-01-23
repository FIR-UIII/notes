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