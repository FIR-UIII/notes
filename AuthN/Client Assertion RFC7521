В целях защиты от кражи client secret рекомендуется использовать Client Assertion (rfc7521). т.е. секрет меняется на токен JWT, подписанный закрытым ключом самого клиента. Клиент генерирует пару закрытого и открытого ключей и передает открытый ключ на сервер авторизации или предоставляет ему ссылку на этот открытый ключ в формате JWKS (URL JWKS)
```
# обычный запрос с паролем client secret 
curl --location 'http://localhost:8080/realms/medium/protocol/openid-connect/token' \ 
--header 'Content-Type: application/x-www-form-urlencoded' \ 
--data-urlencode 'client_secret=<<YOUR_CLIENT_SECRET>>' \ 
--data-urlencode 'client_id=app' \ 
--data-urlencode 'grant_type=client_credentials'

# Client Assertion
curl --location 'http://localhost:8080/realms/medium/protocol/openid-connect/token' \ 
--header 'Content-Type: application/x-www-form-urlencoded' \ 
--data-urlencode 'client_assertion=eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhcHAiLCJpc3MiOiJhcHAiLCJhdWQiOiJodHRwOi8vbG9jYWxob3N0OjgwODAvcmVhbG1zL21lZGl1bSIsImp0aSI6ImM5ZjNlOGEyLTVkNGItNGI2ZS05YTFjLTJmM2Q2ZTdiOGM5ZiIsImlhdCI6MTc2NDE0NjI5MCwiZXh wIjoxNzY0MTQ4MDIwfQ.Oe4meKpr3bhaT8Z4PkSWH2UOh4kWqHqZSm6OMW4vWxOTggNSKI-DmhTzEfkJJSRYPAVCChRwZvf5mHJ3UtJ84et8LyfOlXdrGEeVUhwictks07IcTRnJJ75AURbTjk8Pz25RR-zflFBB8CH--5qe9v4uit40MVfilBAgno2kIiEA-1x2SPkwageGBJ4jCwRL-mC8xoqUTQfonoQFhZ23CkM i2gfH1CW5tWOhbtVNQArejfWMJKN7ydkeYxWnZuVuceZRRKICiLBwiwg3UR9D_41gFgXxCQ1kGv0IPtUcx4sjx_h5o5Nx9N81Md7GkIa1TtMLSiYKT7Yx yPX0Sud3uFiMAr8miPS1R8oHp7ptw0x7Pcvh2oOiFnD4Oimq560eMw8PcuaP9zXSN4nevoTzMsGQkqaKmaHrUoj7wcb97e4bPP5VhSnXI6cVBoMQME2pK f1Lq8gtSOZ_aXfiMJhJma9gjlkgeJHzxpKhQZroet4BAOyskevMoZ7Chb6bAfIn1orl4tjACTKEhOBnCrlHOvIaver1mPb6FS7To6S_5vOORsT3G5iHr82PzoJEq5Qxgy98EeCI4UhOy49X6p77-aIb2D6qKkxo--ZvTRUvbXIYxDHbREKdr565UL5JIq3VtMwkO_tR_HXoySR4uiMTNKwQwVO05YNiYMqI71T3Zbw' \ 
--data-urlencode 'client_assertion_type=urn:ietf:params:oauth:client-assertion-type:jwt-bearer' \ 
--data-urlencode 'grant_type=client_credentials'
```
