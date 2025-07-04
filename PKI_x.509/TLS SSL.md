# Security/Server Side TLS
https://wiki.mozilla.org/Security/Server_Side_TLS#Modern_compatibility

# Verify TLS configuration
```
https://github.com/rbsec/sslscan
$ sslscan 127.0.0.1:8200 # verify TLS configuration
$ openssl x509 -in cert.pem -noout -text # read certificate from file 

```

# Basics

### TLS 1.2 RFC 5246
```
Client				Server (Certificate | Pub_key | Priv_key)
*------------------------------*
ClientHello (01)
|----------------------------->|
	    			ServerHello (02)
				Certificate + Pub_key
		 		ServerKeyExchange (optional)
				CertificateRequest (optional)
				ServerHelloDone
|<-----------------------------|
| Certificate (optional mTLS)
| ClientKeyExchange (PreMasterSecret)
| CertificateVerify
| ChangeCipherSpec
| Finished  
|----------------------------->|
				ChangeCipherSpec
				Finished
|<-----------------------------|
     ENCRYPTED DATA EXCHANGE
|----------------------------->|
|<-----------------------------|
```

*Важные моменты обмена:*<br>
1. ClientHello (01) cостоит из: Version + ClientRandom (32 bytes \ 256 bits) + SessionID + Cipher Suites + Compression Methods + Extensions<br>
2. ServerHello (02) cостоит из:  выбранный Version + ServerRandom + SessionID + выбранный Cipher Suites + выбранный Compression Methods + Extensions<br>
3. После ClientHello и ServerHello обе стороны обменялись ClientRandom ServerRandom и согласовали версию TLS и шифронаборы (Version Cipher Suites) и знают SessionID<br>
4. После отправки Certificate сервером - клиент узнает pub_key и цепочку сертификатов. На этом этапе клиент может проверить - доверяет ли он корневому центру выдавшем сертификат серверу или нет.<br>
5. В момент отправки ClientKeyExchange - клиент генерирует и включает в него PreMasterSecret (48 bytes) зашифрованный pub_key сервера<br> 
6. До Finished обе стороны вычисляют MasterSecret. Master_secret = Pseudo-Random Function(pre_master_secret, "master secret", ClientRandom + ServerRandom)<br> 
7. До Finished обе стороны вычисляют 4 сессионых ключа. Формируется в несколько операций:<br>
```
1. Расчитывается key_block = Pseudo-Random Function(master_secret, "key expansion", ClientRandom + ServerRandom)
2. На основе key_block формируются симметричные ключи шифрования:
- Client Encryption Key # для шифрования \ расшифрования данных клиента
- Clint HMAC Key 	# 
- Server Encryption Key # для шифрования \ расшифрования данных сервера
- Server HMAC Key	# 
```

<br>
*Особенности:*<br>
1. Протокол никак не скрывает факт установления соединения (как указано выше, системы DPI могут уверенно детектировать начало сеанса TLS при помощи простых правил-фильтров)<br>
2. В TLS возможны утечки метаинформации: число переданных блоков, различные предупреждения, информация о типе совершаемых пользователем на веб-ресурсе действий. <br>
3. Цель TLS защита от перехвата и модификации саму передаваемую информацию.<br>
4. В веб-контексте TLS-аутентификация обычно односторонняя. Только браузер проверяет подлинность сайта, например, google.com. Но можно создать двустронную mTLS<br>


MasterSecret (48 bytes) - это ещё не сеансовый ключ

https://tls.dxdt.ru/tls.html#logic

### X.509
ASN.1 ... text ............. (Certificate ::= SEQUENCE {tbsCertificate ...})
DER ..... bite-encoded ..... (3082054a0004...)
PEM ..... base64-encoded ... (BEGIN CERTIFICATE...)
