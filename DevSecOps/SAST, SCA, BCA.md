# 1. SAST – статический анализ

### 1.1. Проверка на секреты Gitleaks 
https://github.com/gitleaks/gitleaks
docker pull zricethezav/gitleaks:latest
docker run -v $PATH:/repo zricethezav/gitleaks:latest detect --source=/repo –v
запуск с конфигурацией (toml)

Пример вывода при наличии секретов
<img width="756" height="244" alt="image" src="https://github.com/user-attachments/assets/755af64d-9d72-4333-b943-088ff565051d" />

### 1.2 Проверка конфигураций через Kics
https://github.com/Checkmarx/kics
docker pull checkmarx/kics:latest
docker run -t -v $PATH:/repo checkmarx/kics scan -p /repo -o "/repo/"
Пример вывода:
<img width="769" height="233" alt="image" src="https://github.com/user-attachments/assets/bdc2b88f-e374-4202-a3b4-82b7808be1e4" />

### 1.3. Статический анализ кода - Semgrep
https://github.com/semgrep/semgrep
Важно, semgrep по умолчанию при запуске просит использовать токен от своей облачной платформы. 
В таком случае Ваш код будет загружен на платформу, что настоятельно не рекомендуем. 
git clone https://github.com/semgrep/semgrep-rules.git # скачиваем правила
docker pull semgrep/semgrep:latest
docker run --rm -v "$PATH:/src" semgrep/semgrep semgrep scan --config semgrep-rules/{lang} # lang меняем на нужный стек
<img width="767" height="233" alt="image" src="https://github.com/user-attachments/assets/f177407e-acd5-4a93-a011-fd0bafa134af" />

# 2. композиционный анализ SCA
https://github.com/anchore/syft
https://github.com/anchore/grype
docker pull anchore/syft:latest
docker run --rm -v $PATH:/repo anchore/syft /repo -o cyclonedx-json=/repo/sbom.cdx.json # формируем SBOM где видим зависимости проекта
обязательно проверить что зависимости верно определены (на рис ниже использован форматтер json, поэтому представление может отличаться)
<img width="535" height="351" alt="image" src="https://github.com/user-attachments/assets/7fae7a59-e37b-407e-8565-c87724df268c" />

Сканируем SBOM файл с описанием зависимостей на уязвимости
docker run --rm -v $PATH:/repo anchore/grype sbom:/repo/sbom.cdx.json --output json --file /repo/result.json
ИЛИ через trivy
docker run --rm -v $PATH:/repo aquasec/trivy:latest sbom /repo/ sbom.cdx.json
<img width="843" height="207" alt="image" src="https://github.com/user-attachments/assets/0f86411f-58ee-4d4d-8b15-7ae78809c17c" />

```
# если в findings нет версии - вероятно есть дубликат где сканер смог найти
  Проверить наличие semgrepignore kicks.config exclude.path
  Версия с исправлением
  Последствия
  Наличие PoC exploit
  Проверить историю прошлых разметок (новая, ссылка)              
  Уязвимая функция из описания CVE 
  Используется ли в коде? Постоение дерева зависимости
  Путь вызова (call grapg, если удалось определить)   
  Контекст вызова: среда разработки, продуктивная среда, тесты/билд-утилитах
  Первичная оценка после разметки
  Приоритет для устранения
  Комментарий от разработки
  Комментарий от сопровождения и DEVOPS

# опционально запустить сканер повторно, т.к. в его результате есть анализ достижимости и указывается верная версия для исправления, и путь транзитивных зависимостей, и наличие PoC/exploit
depscan --profile research -t java -i . --reports-dir .\reports\reachebility --explain # с анализом достижимости
depscan --src $PWD --reports-dir $PWD/reports # простой анализ

# Maven 
mvn dependency:tree > mvn_deps.txt

# pnpm (pnpm-lock.yaml)
pnpm install
pnpm audit > pnpm_audit.txt
pnpm list > pnpm_deps.txt
pnpm list --depth Infinity > pnpm_deps_all.txt # выводит все дерево
pnpm why <package> # для понимания точечного импорта пакета, и построения его графа 
```
