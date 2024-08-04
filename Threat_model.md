### OWAST Threat Dragon
Визуализирует угрозы. Нет автоматизации, подсказок после выстраивания
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


### Threagile
Моделирует угрозы на основании ранее приготовленного [yaml файла](https://github.com/Threagile/github-integration-example/blob/main/threagile.yaml). 
Минус: 
- нет визуализации при построении модели. Только по итогу
https://github.com/Threagile/threagile
```
### create template model
docker run --rm -it -v "$(pwd)":/app/work threagile/threagile --create-example-model --output /app/work
### based on that change all that needs for your app and save it
### execute Threagile to perform threat modeling
docker run --rm -it -v "$(pwd)":/app/work threagile/threagile --verbose --model /app/work/threagile.yaml --output /app/work
```

### Windows threat tool
