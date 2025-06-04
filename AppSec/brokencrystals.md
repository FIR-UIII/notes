```
https://github.com/NeuraLegion/brokencrystals

## Собрать быстро образ через докер
docker compose --file=compose.local.yml up -d


## Собрать локально образ
Disable prepare script (husky)
run: npm pkg delete scripts.prepare

Install dependencies
run: npm ci --no-audit

Check format
run: npm run format

Lint
run: npm run lint

Build
run: npm run build

Test
run: npm run test

```