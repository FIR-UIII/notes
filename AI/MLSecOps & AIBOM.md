# MLSecOps и AIBOM

Область: безопасность жизненного цикла AI-систем. Охватывает этапы `данные → обучение/дообучение → оценка → registry → развёртывание → эксплуатация → вывод из эксплуатации`, а также инвентаризацию и прозрачность компонентов (AI/ML-BOM).
Связанные файлы: [Model & Runtime](Model%20&%20Runtime%20Security.md), [Fine-tuning & LoRA](Fine-tuning%20&%20LoRA%20Security.md), [MCP Security](MCP%20Security.md) (CI-пример для SCA/SBOM), [DevSecOps](../DevSecOps/).

```
 Data ──► Train / Fine-tune ──► Evaluate ──► Registry ──► Deploy ──► Operate ──► Retire
  │            │                   │            │            │           │
  hash,        isolated env,       red team,    sign,        verify      monitor, IR,
  PII scan,    provenance          safety gate  AIBOM,       signature,  drift, abuse,
  license      attestation                      approvals    admission   kill switch
```

---

## OPS-A. Инвентаризация
- [ ] **OPS-01** `MUST` Единый реестр AI-активов: модели (свои и сторонние API), адаптеры, датасеты, эмбеддинг-модели, векторные БД, системные промпты, агенты, MCP-серверы, skills. У каждого есть владелец, назначение, классификация данных, уровень риска и окружения.
- [ ] **OPS-02** `MUST` Выявление shadow AI: обращения к публичным LLM API на прокси и DLP, неучтённые inference-серверы в сети (сканирование портов 11434, 8000, 8080, 8265, 5000, 6333, 19530), ключи LLM-провайдеров в репозиториях.

## OPS-B. AIBOM
- [ ] **OPS-03** `MUST` На каждый релиз AI-системы генерируется AIBOM в формате **CycloneDX ≥ 1.6** (ML-BOM, `modelCard`, `data`) или **SPDX 3.0** (профили AI и Dataset).
- [ ] **OPS-04** `MUST` Минимальное содержание AIBOM:
  - модель: имя, версия/revision, поставщик, **хеши всех файлов**, формат, квантизация, лицензия;
  - происхождение: базовая модель (цепочка lineage), адаптеры и их привязка к базовой модели, merge-родители;
  - данные: датасеты обучения и дообучения с версиями, хешами, лицензиями, классификацией;
  - токенизатор и chat template (хеш);
  - программный стек: runtime (vLLM/llama.cpp/…), фреймворки, CUDA/драйверы — через обычный SBOM;
  - оценка: результаты safety/security-тестов, известные ограничения, назначение (intended use);
  - внешние зависимости во время работы: LLM API, MCP-серверы, инструменты, векторные БД.
- [ ] **OPS-05** `MUST` AIBOM подписан и хранится рядом с артефактом в registry. По хешу модели в prod можно найти её AIBOM.
- [ ] **OPS-06** `SHOULD` От поставщиков сторонних моделей и AI-SaaS запрашивается AIBOM / model card и сведения об обработке данных (retention, обучение на данных клиента, регион).
- [ ] **OPS-07** `SHOULD` Уязвимости и инциденты сторонних моделей и компонентов сопоставляются с AIBOM (как SBOM + VEX для ПО).

## OPS-C. Registry и подпись
- [ ] **OPS-08** `MUST` Model registry (MLflow, HF Enterprise, Artifactory ML, свой) с RBAC, неизменяемыми версиями и стадиями продвижения (`staging → prod`) с утверждением.
- [ ] **OPS-09** `MUST` Артефакты моделей подписываются при регистрации (OpenSSF Model Signing / Sigstore / cosign для OCI-артефактов).
- [ ] **OPS-10** `MUST` Подпись и хеш проверяются при развёртывании: admission policy (Kyverno/Gatekeeper) или init-контейнер, который не даёт запустить inference с неподписанной моделью.
- [ ] **OPS-11** `SHOULD` Provenance-аттестации (in-toto / SLSA) для пайплайнов обучения и сборки.

## OPS-D. CI/CD security gates
- [ ] **OPS-12** `MUST` Сканирование файлов моделей (ModelScan, ModelAudit, fickling) — блокировка pickle и подозрительных операторов.
- [ ] **OPS-13** `MUST` SCA для ML-стека: torch, transformers, vLLM, llama.cpp, langchain и пр. Блокировка на high/critical. Версии закреплены, lock-файлы обязательны.
- [ ] **OPS-14** `MUST` SAST с правилами для AI-кода: `pickle.load`/`torch.load` без `weights_only`, `trust_remote_code=True`, `yaml.load`, `eval`/`exec` на выводе модели, вывод LLM в SQL/HTML/shell, секреты в промптах. (Semgrep-правила, CodeQL.)
- [ ] **OPS-15** `MUST` Сканирование секретов включает Jupyter-ноутбуки (с outputs). `nbstripout` в pre-commit.
- [ ] **OPS-16** `MUST` LLM security eval как gate: garak / PyRIT / promptfoo / DeepTeam / Inspect. Запуск при смене модели, промпта, инструментов или RAG-корпуса, пороги прохождения заданы.
- [ ] **OPS-17** `MUST` Промпты, конфиги агентов, описания инструментов и skills хранятся в Git и проходят ревью как код.

## OPS-E. ML-платформа
- [ ] **OPS-18** `MUST` Jupyter, MLflow, Ray dashboard, Kubeflow, TensorBoard, Label Studio не доступны без аутентификации и не публикуются в интернет. У этих компонентов много RCE и path traversal CVE, а аутентификация часто выключена по умолчанию.
- [ ] **OPS-19** `MUST` Окружения research / dev / prod разделены. Prod-данные в research только по утверждённому процессу.
- [ ] **OPS-20** `MUST` GPU-кластер: hardening k8s / Slurm, обновлённые драйверы и Container Toolkit, NetworkPolicy, отдельные ноды для недоверенных нагрузок.

## OPS-F. Эксплуатация
- [ ] **OPS-21** `MUST` Телеметрия по OpenTelemetry GenAI semantic conventions → SIEM. Метрики: срабатывания guardrails, jailbreak-попытки, отказы авторизации инструментов, стоимость, аномалии вызовов.
- [ ] **OPS-22** `MUST` Playbook реагирования на AI-инциденты: откат модели или промпта, kill switch агента, отзыв токенов агента, очистка памяти и индекса RAG, уведомление владельцев данных.
- [ ] **OPS-23** `SHOULD` Регулярный (не только при релизе) red teaming и мониторинг дрейфа поведения модели.
- [ ] **OPS-24** `MUST` Вывод из эксплуатации: удаление весов и адаптеров, отзыв identity агентов, удаление индексов и памяти, обновление реестра.

---

## Инструменты (ориентир)
| Задача | Open source |
|---|---|
| Сканирование моделей | ModelScan, ModelAudit, fickling, picklescan |
| Подпись моделей | sigstore/model-transparency (`model_signing`), cosign |
| AIBOM | CycloneDX (`cyclonedx-py`, ML-BOM), OWASP AIBOM Generator, SPDX 3.0 tools |
| LLM red teaming | garak, PyRIT, promptfoo, DeepTeam, Inspect (UK AISI) |
| MCP/skills сканирование | mcp-scan, NVIDIA SkillSpector |
| Политики развёртывания | Kyverno, OPA Gatekeeper |
| Наблюдаемость | OpenTelemetry GenAI, OpenLLMetry, Langfuse, Phoenix |

## Источники
- CycloneDX ML-BOM — https://cyclonedx.org/capabilities/mlbom/
- SPDX 3.0 AI profile — https://spdx.dev/
- OWASP AIBOM project — https://genai.owasp.org/
- OpenSSF Model Signing — https://github.com/sigstore/model-transparency
- Google SAIF — https://saif.google/
- CSA AI Controls Matrix (AICM) — https://cloudsecurityalliance.org/artifacts/ai-controls-matrix
- OpenTelemetry GenAI semconv — https://opentelemetry.io/docs/specs/semconv/gen-ai/
