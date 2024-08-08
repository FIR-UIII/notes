# PKI

Generate private key
```
openssl genrsa 2048 > vault_private.pem
```

Generate public key
```
openssl req -x509 -new -key vault_private.pem -out vault_public.pem -days 365
```
