https://owasp.org/www-project-top-10-ci-cd-security-risks/
https://cheatsheetseries.owasp.org/cheatsheets/CI_CD_Security_Cheat_Sheet.html

### Risks 
```
CICD-SEC-1: Insufficient Flow Control Mechanisms
CICD-SEC-2: Inadequate Identity and Access Management
CICD-SEC-3: Dependency Chain Abuse
CICD-SEC-4: Poisoned Pipeline Execution (PPE)
CICD-SEC-5: Insufficient PBAC (Pipeline-Based Access Controls)
CICD-SEC-6: Insufficient Credential Hygiene
CICD-SEC-7: Insecure System Configuration
CICD-SEC-8: Ungoverned Usage of Third-Party Services
CICD-SEC-9: Improper Artifact Integrity Validation
CICD-SEC-10: Insufficient Logging and Visibility
```

---

# CI/CD Pipeline Security Review (GitLab)

Ниже — полноценный **CI/CD Pipeline Security Review** для GitLab. Я ориентировался не только на документацию GitLab, но и на практику AppSec-аудитов. Цель чек-листа — ответить на вопрос:

> **Можно ли обойти проверки безопасности и доставить код в production?**

---

# CI/CD Pipeline Security Review (GitLab)

## 1. Pipeline Architecture

### Что проверить

* [ ] Используется единый `.gitlab-ci.yml`
* [ ] Pipeline использует централизованные шаблоны (`include`)
* [ ] Security jobs вынесены в отдельный template
* [ ] Security template находится в отдельном репозитории
* [ ] Template защищен CODEOWNERS
* [ ] Pipeline разбит на логические stages


---

# 2. Pipeline Trigger

Проверить все способы запуска.

| Trigger         | Проверить |
| --------------- | --------- |
| push            | ✓         |
| merge_request   | ✓         |
| tag             | ✓         |
| schedule        | ✓         |
| api             | ✓         |
| child pipeline  | ✓         |
| parent pipeline | ✓         |
| trigger token   | ✓         |

Вопросы:

* запускается ли SAST при push?
* запускается ли SAST при MR?
* запускается ли при tag?
* запускается ли через API?

Очень часто scanner работает только для Merge Request.

---

# 3. Stage Ordering

Проверить

```
Security Scan
↓
Build
↓
Deploy
```

Нельзя

```
Deploy
↓
Security Scan
```

---

# 4. Job Dependency Review

Проверить

```
needs:
```

Например

```
deploy

needs:
- sast
- sca
```

Если

```
deploy

needs:
- build
```

то deploy может не зависеть от security.

---

# 5. Security Job Mandatory

Для каждого scanner

Проверить

```
allow_failure
```

Должно быть

```
allow_failure: false
```

или вообще отсутствовать.

---

Плохо

```yaml
sast:
  allow_failure: true
```

---

Также проверить

```
when:
```

Не должно быть

```yaml
when: manual
```

для обязательных scanner.

---

# 6. Rules Review

Проверить

```
rules:
```

Например

```yaml
rules:
- if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
```

Тогда

```
git push main
```

может вообще не запускать scanner.

---

Проверить

```
only
except
rules
workflow
```

---

# 7. Workflow Review

Очень частая проблема

```yaml
workflow:

 rules:

 - if: ...
```

Например

```
workflow

↓

pipeline skipped
```

Проверить

можно ли полностью отключить pipeline.

---

# 8. Include Review

Проверить

```
include:
```

Все виды

```
project

remote

template

local
```

Вопросы

Можно ли заменить

```
security.yml
```

на свой?

Можно ли изменить branch include?

Например

```
ref: feature
```

вместо

```
ref: main
```

---

# 9. Scanner Integrity

Для каждого scanner проверить

* используется официальный image
* image закреплен по digest
* image не берется из Docker Hub без проверки
* версия фиксирована

Плохо

```yaml
image:

registry.gitlab.com/security-products/sast:latest
```

Лучше

```
sha256:...
```

---

# 10. Variable Review

Проверить

```
variables:
```

Особенно

```
SAST_DISABLED

SCAN_DISABLED

SECURE_ANALYZERS_PREFIX

SAST_EXCLUDED_PATHS

CS_DISABLE_LANGUAGE_VULNERABILITY_SCAN
```

Можно ли их изменить?

---

# 11. Path Exclusion

Проверить

```
SAST_EXCLUDED_PATHS
```

Можно ли написать

```
src/
```

и исключить весь проект.

---

# 12. Report Validation

После scanner

проверить

```
artifacts:
 reports:
```

Например

```
gl-sast-report.json
```

существует?

или job просто делает

```
exit 0
```

---

# 13. Exit Code Validation

Очень важно.

scanner должен

```
exit 1
```

при критических ошибках.

Проверить

не используется ли

```bash
scanner || true
```

или

```bash
scanner

exit 0
```

---

# 14. Artifact Dependency

Deploy должен зависеть

не только от build

но и от scanner report.

---

# 15. Quality Gate

Проверить

при каких условиях deploy разрешен.

Например

```
Critical = 0

High < 3

Secrets = 0

License = pass
```

или

```
Pipeline Green
```

---

# 16. Merge Gate

Проверить

Можно ли сделать Merge если

* scanner failed
* scanner skipped
* scanner timeout
* scanner canceled

Ответ должен быть

```
Нет
```

---

# 17. Retry Behavior

Проверить

если scanner упал

```
network error

↓

retry

↓

pass
```

не пропускается ли Quality Gate.

---

# 18. Manual Jobs

Проверить

```
when: manual
```

Есть ли

```
deploy

manual
```

без проверки scanner.

---

# 19. Child Pipeline

Если используются

```
trigger:
```

или

```
child pipeline
```

Проверить

передаются ли результаты scanner.

---

# 20. Dynamic Pipeline

Проверить

```
include:
 generated.yml
```

Можно ли сгенерировать pipeline

без scanner.

---

# 21. Conditional Execution

Проверить

```
changes:
```

Например

```yaml
changes:
 - "*.go"
```

Что произойдет

если изменить

```
Dockerfile
```

или

```
helm/
```

---

# 22. Environment Protection

Deploy Production

должен иметь

```
Protected Environment
```

и approval.

---

# 23. Runner Trust

Job security

должен запускаться

только на доверенных runner.

Проверить

```
tags
```

и

```
protected runner
```

---

# 24. Image Provenance

Каждый job

использует

```
image:
```

Проверить

* image подписан
* image из доверенного registry
* запрещены произвольные образы

---

# 25. Bypass Scenarios (обязательно протестировать)

Это практические сценарии, которые стоит выполнить в тестовом проекте и убедиться, что защита срабатывает.

| Попытка обхода                                             | Ожидаемый результат                                            |
| ---------------------------------------------------------- | -------------------------------------------------------------- |
| Удалить `sast` job                                         | Pipeline не проходит или изменения блокируются политикой       |
| Добавить `allow_failure: true`                             | Merge запрещен                                                 |
| Изменить `when: manual`                                    | Merge запрещен                                                 |
| Изменить `rules` так, чтобы scanner не запускался          | Pipeline блокируется                                           |
| Изменить `needs` и убрать зависимость `deploy → security`  | Deploy невозможен                                              |
| Использовать `workflow: rules` для пропуска pipeline       | Merge запрещен                                                 |
| Добавить `SAST_DISABLED=true`                              | Политика запрещает изменение или scanner все равно запускается |
| Исключить весь проект через `SAST_EXCLUDED_PATHS`          | Изменение обнаруживается на ревью или запрещается политикой    |
| Подменить образ scanner на собственный                     | Использование недоверенного образа блокируется                 |
| Подменить отчет `gl-sast-report.json`                      | Отчет валидируется, подмена обнаруживается                     |
| Запустить только `build` и пропустить `security`           | Deploy невозможен                                              |
| Повторно использовать артефакты старого успешного pipeline | Используются только артефакты текущего pipeline                |
| Запустить pipeline через API                               | Все обязательные проверки выполняются                          |
| Создать pipeline по тегу                                   | Выполняются те же security jobs, что и при обычной сборке      |

---

# Подключение Security Scanner

Для каждого продукта:

SAST

```
✓ всегда запускается
✓ нельзя выключить переменной
✓ нельзя удалить include
✓ используется последняя версия
✓ обновляются правила
✓ результаты публикуются
```

SCA

```
✓ запускается всегда
✓ анализирует lock-файлы
✓ анализирует transitive dependencies
✓ анализирует licenses
```

Secrets

```
✓ проверяет git history
✓ проверяет merge request
✓ проверяет default branch
```

Container Scan

```
✓ анализирует итоговый image
✓ не только Dockerfile
```

IaC

```
✓ Terraform
✓ Helm
✓ Kubernetes
✓ Dockerfile
```

DAST

```
✓ запускается после deploy
✓ проверяет staging
```

---

# 3. Проверка Quality Gates

Это самая интересная часть.

Нужно ответить:

> Можно ли попасть в production если scanner сломан?

Например

```
SAST failed

↓

Pipeline зеленый?

ДА ← плохо

НЕТ ← хорошо
```

Проверяем:

```
allow_failure
when: manual
rules
needs
dependencies
only
except
workflow
```

---

Например

```yaml
sast:
  allow_failure: true
```

Это уже потенциальный bypass.

---

# 4. Проверка MR Protection

Можно ли сделать Merge если

```
SAST failed

или

SAST skipped

или

job deleted
```

Проверяем

```
Require pipeline success

Merge approvals

Code owners

Status checks
```

---

# 5. Проверка GitLab Security Policies

Если используется GitLab Ultimate

Проверяем

```
Scan Execution Policies

Scan Result Policies
```

Очень часто они вообще не настроены.

---

# 6. Проверка Runner

Очень важный раздел.

Проверяем

```
Shared Runner

Privileged mode

Docker socket

Kubernetes executor

Shell executor
```

Например

```
privileged=true
```

дает возможность делать Docker-in-Docker атаки.

---

# 7. Проверка переменных

```
Protected

Masked

Environment scoped

Hidden

File variables
```

Можно ли

```
echo $SECRET
```

в pipeline?

---

# 8. Проверка артефактов

Иногда отчеты просто теряются.

Проверяем

```
artifacts:
reports:
```

Сохраняются ли

```
SAST report

SCA report

SBOM

Coverage

JUnit
```

---

# 9. Проверка Pipeline Templates

Если используется

```
include:
```

проверяем

```
remote include

project include

template include
```

Можно ли заменить include на свой.

---

# 10. Проверка веток

```
main

master

release/*

hotfix/*
```

Запускаются ли сканеры одинаково.

Очень часто

```
MR

↓

есть SAST

main

↓

нет SAST
```

или наоборот.

---

# 11. Проверка условий запуска

Например

```yaml
rules:
  - if: $CI_COMMIT_BRANCH == "main"
```

или

```yaml
only:
  - merge_requests
```

Тогда

```
git push tag
```

может полностью обходить проверки.

---

# 12. Проверка возможности отключить scanner

Например

```
SAST_DISABLED=true
```

или

```
SECURE_ANALYZERS_PREFIX
```

или

```
SCAN_DISABLED
```

или

```
EXCLUDED_PATHS
```

или

```
SAST_EXCLUDED_PATHS
```

Нужно проверить кто может менять эти переменные.

---

# 13. Проверка bypass pipeline

Очень важный раздел.

Можно ли сделать

```
rules:
  when: never
```

Можно ли

```
workflow:
 rules:
```

отключить pipeline.

Можно ли

```
needs: []
```

обойти зависимости.

Можно ли

```
allow_failure
```

обойти gate.

Можно ли

```
when: manual
```

не запускать scanner.

---

# 14. Проверка защищенности GitLab

Например

```
Protected branches

Protected tags

Protected variables

Push rules

Signed commits

Signed tags

Code owners

Approval rules
```

---

# 15. Проверка неизменности pipeline

Очень важно.

Кто может менять

```
.gitlab-ci.yml
```

Есть ли

```
CODEOWNERS
```

Например

```
.gitlab-ci.yml

Security Team
```

должен требовать approval Security.

---

# 16. Проверка цепочки поставки

Проверяем

```
SBOM

Image Signing

Attestation

Provenance

Cosign

SLSA
```

---

# 17. Проверка ложных Quality Gates

Иногда job есть.

Но внутри

```
echo "Run SAST"

exit 0
```

И pipeline зеленый.

Нужно проверить

```
действительно ли scanner запускался

или просто вернул 0
```

---

# 18. Проверка невозможности обхода

Я обычно использую такой список вопросов.

| Проверка                            | Что проверяем                          |
| ----------------------------------- | -------------------------------------- |
| Можно удалить job?                  | Pipeline должен упасть                 |
| Можно сделать allow_failure?        | Merge должен блокироваться             |
| Можно отключить include?            | Security policy должна вернуть job     |
| Можно изменить scanner image?       | Только доверенный registry             |
| Можно изменить variables?           | Только Maintainer                      |
| Можно отключить report?             | Merge должен блокироваться             |
| Можно изменить stage?               | Scanner должен оставаться обязательным |
| Можно пропустить pipeline?          | Merge запрещен                         |
| Можно использовать старый pipeline? | Нет                                    |
| Можно выполнить manual deploy?      | Только после успешных проверок         |

# Что используют зрелые компании

В крупных организациях (банки, облачные провайдеры, enterprise) обычно есть отдельный **DevSecOps CI/CD Hardening Checklist**, который объединяет требования из нескольких источников:

* **OWASP CI/CD Security Cheat Sheet** — базовые практики защиты пайплайнов.
* **OWASP Software Assurance Maturity Model (SAMM)** — требования к зрелости процесса разработки и DevSecOps.
* **NIST Secure Software Development Framework (SSDF, SP 800-218)** — контрольные требования к безопасной разработке и CI/CD.
* **SLSA (Supply-chain Levels for Software Artifacts)** — защита цепочки поставки и целостности сборок.
* **CIS Benchmarks для GitLab** (если используется GitLab Self-Managed) — безопасная конфигурация самой платформы.


1. **GitLab Security Configuration Review** — права, защищенные ветки, раннеры, переменные, политики, настройки проекта и группы.
2. **CI/CD Pipeline Security Review** — анализ `.gitlab-ci.yml`, шаблонов, условий запуска, зависимостей, защиты от обхода и корректности Quality Gates.
3. **DevSecOps Controls Validation** — практические проверки: попытки отключить сканеры, изменить пайплайн, обойти обязательные проверки, подменить отчеты или добиться успешного деплоя без прохождения контрольных этапов.

Такой подход покрывает не только наличие сканеров, но и доказывает, что их действительно **нельзя незаметно обойти**, что обычно и является основной целью зрелого DevSecOps-аудита.


