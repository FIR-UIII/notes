# Безопасность модели и inference runtime

Область: файлы моделей (веса, токенизатор, chat template, конфиги), их получение и загрузка, inference-серверы (llama.cpp / llama-server, vLLM, SGLang, Ollama, TGI, Triton, TensorRT-LLM), GPU-хостинг и API инференса.
Связанные файлы: [MLSecOps & AIBOM](MLSecOps%20&%20AIBOM.md) (registry, подпись, CI gates), [Fine-tuning & LoRA](Fine-tuning%20&%20LoRA%20Security.md) (адаптеры), [Self-host LLM](Self-host%20LLM.md) (примеры развёртывания).

Обозначения: `MUST` — обязательно, `SHOULD` — рекомендуется, отступление нужно обосновать.

---

## Угрозы и реальные примеры

| Угроза | Суть | Примеры |
|---|---|---|
| Модель = исполняемый код | Pickle-форматы (`.bin`, `.pt`, `.pth`, `.ckpt`, `.pkl`, joblib) выполняют код при загрузке. Keras `Lambda`-слои, `trust_remote_code=True` в transformers — тоже код | вредоносные модели на Hugging Face (JFrog, ReversingLabs «nullifAI», 2024–2025); CVE-2025-32434 — RCE в `torch.load` даже с `weights_only=True` (PyTorch ≤ 2.5.1); CVE-2025-1550 — обход `safe_mode` в Keras |
| Chat template / метаданные | Jinja2-шаблон из GGUF/`tokenizer_config.json` рендерится на сервере | CVE-2024-34359 «Llama Drama» — SSTI→RCE в llama-cpp-python |
| Баги парсеров форматов | Переполнения при разборе GGUF и др. | серия CVE в llama.cpp (GGUF parsing, 2024) |
| Открытый API инференса | Ollama не имеет встроенной аутентификации; llama-server и vLLM без `--api-key` открыты; тысячи экземпляров в Shodan | CVE-2024-37032 «Probllama» — path traversal→RCE в Ollama через `/api/pull` |
| Небезопасный обмен внутри кластера | pickle-десериализация поверх ZeroMQ/NCCL между воркерами | «ShadowMQ» (2025) — один и тот же паттерн `recv_pyobj` в vLLM, SGLang, TensorRT-LLM и др.; CVE-2025-32444 (vLLM + Mooncake) |
| Управляющие эндпоинты | загрузка/удаление моделей и адаптеров, `/slots`, `/props`, `/metrics`, Ray dashboard | ShadowRay (CVE-2023-48022) — неаутентифицированный RCE через Ray Jobs API; цепочка уязвимостей в Triton (Wiz, 2025) |
| Побег из GPU-контейнера | NVIDIA Container Toolkit монтирует хостовые ресурсы | CVE-2024-0132, CVE-2025-23266 «NVIDIAScape» |
| Утечки между тенантами на GPU | остаточная память GPU, общий prefix/KV-cache (timing side-channel) | LeftoverLocals (CVE-2023-4969); исследования утечки промптов через prefix caching |
| Кража модели | прямой доступ к весам или extraction/distillation через API | — |
| Unbounded consumption | DoS, denial of wallet, длинные контексты, параллельные запросы | — |

---

## Требования

### MR-A. Происхождение и целостность модели
- [ ] **MR-01** `MUST` Модели загружаются только из одобренного источника: внутренний registry или зеркало (Artifactory/Nexus HF-proxy, свой MLflow/HF mirror). Прямые `from_pretrained("org/model")` из интернета в prod запрещены.
- [ ] **MR-02** `MUST` Версия модели фиксируется неизменяемым идентификатором (HF `revision=<commit sha>`, digest), а не тегом/веткой `main`.
- [ ] **MR-03** `MUST` Перед загрузкой проверяется SHA-256 каждого файла и/или подпись ([OpenSSF Model Signing](https://github.com/sigstore/model-transparency), Sigstore). Ключ/идентичность подписанта берутся из trust store, а не из самого артефакта.
- [ ] **MR-04** `MUST` Разрешены только безопасные форматы весов: `safetensors`, `GGUF`, ONNX (без custom ops из недоверенных источников). Pickle-форматы запрещены; если исключение неизбежно — сканирование (ModelScan, ModelAudit, fickling, picklescan) + загрузка в изолированной песочнице + конвертация в safetensors. Сканеры обходятся, поэтому они дополняют запрет, а не заменяют его.
- [ ] **MR-05** `MUST` `trust_remote_code=False` (transformers, vLLM `--trust-remote-code` не использовать). Если модели нужен кастомный код — он вендорится в свой репозиторий, ревьюится и пинится.
- [ ] **MR-06** `MUST` PyTorch ≥ 2.6 (по умолчанию `weights_only=True`); Keras — `safe_mode=True` и актуальная версия.
- [ ] **MR-07** `MUST` Chat template, `tokenizer_config.json`, `generation_config.json` и GGUF-метаданные — часть проверяемого артефакта: ревью при обновлении, хеш в AIBOM, рендер только в sandboxed Jinja-окружении.
- [ ] **MR-08** `MUST` Каждая модель имеет запись в инвентаре/AIBOM: источник, версия, хеш, лицензия, базовая модель, квантизация, владелец ([MLSecOps & AIBOM](MLSecOps%20&%20AIBOM.md)).
- [ ] **MR-09** `SHOULD` Новая модель перед допуском проходит поведенческую оценку: safety/jailbreak-регресс, поиск аномального поведения на триггерах (backdoor) ([Fine-tuning & LoRA](Fine-tuning%20&%20LoRA%20Security.md)).

### MR-B. Inference-сервер и API
- [ ] **MR-10** `MUST` Inference-сервер слушает `127.0.0.1` или внутренний интерфейс. Наружу он доступен только через API gateway / reverse proxy с аутентификацией (OIDC/JWT, mTLS) и TLS. Публикация `0.0.0.0` без прокси запрещена.
- [ ] **MR-11** `MUST` Аутентификация включена даже во внутренней сети: llama-server `--api-key-file`, vLLM `--api-key`. Учесть, что `--api-key` в vLLM защищает только `/v1/*`, остальные пути закрывать на прокси. У Ollama встроенной аутентификации нет, поэтому только прокси.
- [ ] **MR-12** `MUST` Управляющие и служебные эндпоинты недоступны клиентам:
  - Ollama: `/api/pull`, `/api/push`, `/api/create`, `/api/copy`, `/api/delete` — запрет на прокси, клиентам открыт только `/api/chat|generate|embed` или `/v1/*`;
  - llama-server: `--no-slots`, не включать `--props` (POST изменяет настройки), `--metrics` только во внутреннюю сеть мониторинга;
  - vLLM: не включать `VLLM_ALLOW_RUNTIME_LORA_UPDATING` в prod, `/metrics` только для мониторинга;
  - Triton: `--model-control-mode=none` (или `explicit` с закрытым repository API).
- [ ] **MR-13** `MUST` Межузловые каналы распределённого инференса (ZeroMQ, NCCL, torch.distributed, Ray, Mooncake/KV-transfer) работают только в изолированной сети или namespace с NetworkPolicy. Ray dashboard и Jobs API наружу не публикуются.
- [ ] **MR-14** `MUST` Runtime обновляется по SLA для критичных CVE: подписка на advisories vLLM, llama.cpp, Ollama, Triton, transformers, torch. Эти проекты выпускают security-фиксы часто.
- [ ] **MR-15** `MUST` Лимиты на уровне gateway: rate limit на identity, `max_tokens` и максимальная длина контекста, размер тела запроса, число параллельных запросов, таймауты, бюджет стоимости на клиента и тенанта с алертами.
- [ ] **MR-16** `SHOULD` Ограничить параметры, облегчающие extraction и утечки: `logprobs`/`top_logprobs`, `echo`, произвольные `stop`/`logit_bias`, если они не нужны клиенту.
- [ ] **MR-17** `SHOULD` В multi-tenant инференсе prefix/KV cache изолирован между тенантами (например, `cache_salt` в vLLM или отдельные инстансы), чтобы исключить timing side-channel.

### MR-C. Хостинг и изоляция
- [ ] **MR-18** `MUST` Контейнер: non-root UID, `readOnlyRootFilesystem`, `capabilities: drop [ALL]`, `allowPrivilegeEscalation: false`, seccomp `RuntimeDefault`, каталог моделей смонтирован `:ro`, образ закреплён по digest.
- [ ] **MR-19** `MUST` Egress inference-пода запрещён (default deny). Runtime не нужен интернет: `HF_HUB_OFFLINE=1`, `TRANSFORMERS_OFFLINE=1`, модели доставляются init-контейнером из registry.
- [ ] **MR-20** `MUST` NVIDIA Container Toolkit / GPU Operator / драйверы обновлены (container escape CVE). Недоверенные нагрузки не делят GPU-ноду с чувствительными.
- [ ] **MR-21** `SHOULD` GPU multi-tenancy через MIG или выделенные GPU, а не time-slicing. Для особо чувствительных весов и данных — confidential computing (H100/Blackwell CC, CVM).
- [ ] **MR-22** `SHOULD` systemd-развёртывание (без контейнера): отдельный пользователь, `NoNewPrivileges`, `ProtectSystem=strict`, `ProtectHome`, `PrivateTmp`, `ReadOnlyPaths` для моделей (пример в [Self-host LLM](Self-host%20LLM.md)).

### MR-D. Защита весов (model theft)
- [ ] **MR-23** `MUST` Хранилище весов: RBAC, шифрование at rest, аудит доступа, отсутствие публичных бакетов.
- [ ] **MR-24** `SHOULD` Мониторинг признаков extraction: большой объём систематических запросов, нетипичное распределение промптов, массовое использование `logprobs`.
- [ ] **MR-25** `SHOULD` Для собственных ценных моделей — fingerprinting/watermarking весов или выходов.

### MR-E. Логирование
- [ ] **MR-26** `MUST` В логах: identity клиента, модель и её версия/хеш, число токенов, латентность, статус, срабатывания фильтров. Тексты промптов и ответов логируются только по политике данных (маскирование PII и секретов, ограниченный retention, отдельный доступ) — [AI_security → DATA](AI_security.md#data-данные-и-приватность).
- [ ] **MR-27** `SHOULD` Логи llama-server/vLLM не пишутся в каталог, доступный процессу на запись, вне выделенного volume. Отправка идёт в централизованный SIEM.

---

## Проверка
```sh
# Что слушает и где
ss -tlnp | grep -E '8080|8000|11434|8265|5000'
# Ollama/llama-server/vLLM доступны без ключа?
curl -s http://HOST:11434/api/tags
curl -s http://HOST:8080/v1/models
curl -s http://HOST:8080/slots
# Pickle в каталоге моделей
find /models -regex '.*\.\(bin\|pt\|pth\|ckpt\|pkl\|joblib\)$'
modelscan -p /models
# Контейнер
docker inspect <id> --format '{{.Config.User}} {{.HostConfig.ReadonlyRootfs}} {{.HostConfig.CapDrop}}'
```
Инструменты: [ModelScan](https://github.com/protectai/modelscan), [ModelAudit](https://github.com/promptfoo/modelaudit), [fickling](https://github.com/trailofbits/fickling), [model-transparency / model_signing](https://github.com/sigstore/model-transparency), Trivy (образы), kube-bench / Kyverno (политики pod).

## Источники
- OWASP Top 10 for LLM Applications (2025 → 2026): Supply Chain, Unbounded Consumption — https://genai.owasp.org/
- MITRE ATLAS — https://atlas.mitre.org/
- NIST AI 100-2 E2025 (Adversarial ML taxonomy) — https://csrc.nist.gov/pubs/ai/100/2/e2025/final
- Hugging Face security (pickle, safetensors) — https://huggingface.co/docs/hub/security-pickle
- vLLM security — https://docs.vllm.ai/en/latest/usage/security.html
- llama.cpp server README — https://github.com/ggml-org/llama.cpp/tree/master/tools/server
