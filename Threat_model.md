### OWAST Threat Dragon
At windows via docker
[Quickstart](https://owasp.org/www-project-threat-dragon/docs-2/install-environment/)

```sh
### Create env.json file
NODE_ENV=development
ENCRYPTION_KEYS='[{"isPrimary": true, "id": 0, "value": "0123456789abcdef0123456789abcdef"}]'
ENCRYPTION_JWT_SIGNING_KEY=deadbeef112233445566778899aabbcc
ENCRYPTION_JWT_REFRESH_SIGNING_KEY=00112233445566778899aabbccddeeff
SERVER_API_PROTOCOL='http'
###
docker pull owasp/threat-dragon:stable
docker run -d -p 8080:3000 -v C:\..\env.json:/app/.env owasp/threat-dragon:stable
```
