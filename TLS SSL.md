# Security/Server Side TLS
https://wiki.mozilla.org/Security/Server_Side_TLS#Modern_compatibility

# Verify TLS configuration
```
https://github.com/rbsec/sslscan
$ sslscan 127.0.0.1:8200 # verify TLS configuration
$ openssl x509 -in cert.pem -noout -text # read certificate from file 

```

# Basics
```
# TLS 1.2
Client --ClientHello-----> Server (supported ciphers, versions)
Client <--ServerHello----- Server (choose ciphers, versions)
Client --ClientPubKey----> Server (supported ciphers, versions)
Client <--ServerPubKey---- Server (client pubkey)
Client <---- DATAFLOW----> Server (server pubkey)

# TLS 1.3
Client --ClientHello------> Server (supported ciphers, versions, +client pubkey)
Client <--ServerHello------ Server (supported ciphers, versions, +server pubkey)
Client <--Auth------        Server (cert chain)
Client <---- DATAFLOW ----> Server
```

### X.509
ASN.1 ... text ............. (Certificate ::= SEQUENCE {tbsCertificate ...})
DER ..... bite-encoded ..... (3082054a0004...)
PEM ..... base64-encoded ... (BEGIN CERTIFICATE...)
