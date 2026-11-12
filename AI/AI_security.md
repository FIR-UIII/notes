# Требования к безопасности AI-систем

Сводный каталог требований по безопасности AI, разбитый на домены. Каждый домен вынесен в свой файл и устроен одинаково: область → угрозы с реальными примерами → требования с ID → проверка → источники.

**Формат требований:** `- [ ] **ID** MUST|SHOULD текст`
- `MUST` — обязательно, без исключений или с формально принятым риском;
- `SHOULD` — рекомендуется, отступление обосновывается;
- чекбокс удобно использовать при оценке конкретной системы.

---

## Карта доменов

| Домен | Файл | Префикс | Что покрывает |
|---|---|---|---|
| Governance и данные | этот файл | `GOV`, `DATA` | инвентарь, политика, риск-классификация, поставщики, регуляторика, данные и приватность |
| LLM-приложения | [LLM Application Security](LLM%20Application%20Security.md) | `LA` | prompt injection, обработка вывода, системный промпт, guardrails, misinformation |
| Модель и runtime | [Model & Runtime Security](Model%20&%20Runtime%20Security.md) | `MR` | форматы моделей, pickle, chat template, llama.cpp/vLLM/Ollama/Triton, GPU, API, кража модели |
| Агенты | [Agent Security](Agent%20Security.md) | `AG` | NHI, делегирование, capability-авторизация, HITL, песочницы, память, multi-agent |
| MCP | [MCP Security](MCP%20Security.md) | `MCP` | tool poisoning, rug pull, OAuth для MCP, token passthrough, hardening сервера |
| Skills | [Skill_security](Skill_security.md) | `SK` | происхождение и подпись skills, манифест и enforcement, инъекции, песочница |
| RAG | [RAG Security](RAG%20Security.md) | `RAG` | ingestion, ACL при поиске, векторные БД, отравление, удаление данных |
| Fine-tuning и LoRA | [Fine-tuning & LoRA Security](Fine-tuning%20&%20LoRA%20Security.md) | `FT` | датасеты, backdoor, деградация safety, адаптеры, multi-LoRA, merge |
| MLSecOps и AIBOM | [MLSecOps & AIBOM](MLSecOps%20&%20AIBOM.md) | `OPS` | реестр активов, AIBOM, подпись, CI gates, ML-платформа, мониторинг, IR |
| AI-ассистенты разработки | [AI Coding Assistants Security](AI%20Coding%20Assistants%20Security.md) | `DEV` | Claude Code / Cursor / Copilot: разрешения, доверие к репо, rules-файлы, AI в CI |
| Развёртывание (практика) | [Self-host LLM](Self-host%20LLM.md) | — | примеры запуска llama.cpp/Ollama, включая hardened-вариант |

### Какие домены применять
```
Используете сторонний LLM API в продукте ........ GOV, DATA, LA
+ своя модель / self-hosted inference ........... + MR, OPS
+ база знаний / поиск по документам ............. + RAG
+ дообучение / LoRA ............................. + FT
+ инструменты, автономные действия .............. + AG, MCP, SK
Разработчики используют AI-ассистентов .......... DEV (+ MCP, SK)
```

---

## Сквозные принципы

1. **LLM не является границей безопасности.** Всё, что попало в контекст, может управлять моделью. Авторизация, лимиты и валидация реализуются детерминированно вне модели. Guardrails снижают риск, но не являются контролем доступа.
2. **Вывод модели — недоверенные данные.** К нему применяются те же правила, что к пользовательскому вводу (экранирование, валидация, параметризация).
3. **Модель, адаптер, skill, MCP-сервер, промпт — это код.** Для них нужны supply chain-контроли: происхождение, закрепление версий, хеш и подпись, ревью, SCA, AIBOM.
4. **Least privilege и least agency.** Минимум инструментов, прав, данных в контексте и автономии. Права даются на конкретные возможности (capabilities), а не на ресурсы.
5. **Lethal trifecta / Rule of Two.** Нельзя без человека совмещать в одной сессии недоверенный ввод, доступ к чувствительным данным и возможность действовать вовне.
6. **Человек подтверждает необратимое**, и видит при этом фактические параметры действия, а не пересказ модели.
7. **Наблюдаемость и обратимость.** Каждое действие трассируется до человека-принципала. Есть kill switch, откат модели или промпта и отзыв токенов.
8. **Непрерывное тестирование.** Red teaming при каждой смене модели, промпта, инструментов или корпуса, а не только один раз перед релизом.

---

## GOV. Governance

- [ ] **GOV-01** `MUST` Политика использования AI: разрешённые сервисы и модели, допустимые классы данных для каждого из них, запрещённые сценарии, ответственность.
- [ ] **GOV-02** `MUST` Реестр AI-систем и активов с владельцами (детализация в OPS-01/OPS-02), включая выявление shadow AI.
- [ ] **GOV-03** `MUST` Классификация AI-систем по риску (влияние решений, данные, автономия, внешняя экспозиция). От уровня риска зависит набор обязательных требований и глубина тестирования.
- [ ] **GOV-04** `MUST` Модель угроз для каждой AI-системы среднего и высокого риска (STRIDE + MITRE ATLAS, для агентов — CSA MAESTRO). Пересматривается при изменении архитектуры.
- [ ] **GOV-05** `MUST` Оценка поставщиков AI (LLM API, AI-SaaS, модели): retention и использование данных для обучения, регион обработки, сертификации, AIBOM и model card, реакция на уязвимости, договорные гарантии.
- [ ] **GOV-06** `MUST` Процесс реагирования на AI-инциденты интегрирован в общий IR (см. OPS-22). Есть канал приёма сообщений об уязвимостях AI-систем (в т.ч. jailbreak и prompt injection).
- [ ] **GOV-07** `SHOULD` Система менеджмента AI по ISO/IEC 42001 и/или процесс NIST AI RMF (Govern–Map–Measure–Manage).
- [ ] **GOV-08** `MUST` Учёт регуляторных требований юрисдикции (см. ниже). Ответственный за соответствие назначен.
- [ ] **GOV-09** `SHOULD` Обучение разработчиков и пользователей: prompt injection, утечки данных в публичные LLM, риски AI-ассистентов.

## DATA. Данные и приватность

- [ ] **DATA-01** `MUST` Для каждого класса данных определено, можно ли передавать его в: (а) внешний LLM API, (б) self-hosted модель, (в) обучение и дообучение, (г) RAG-индекс, (д) логи промптов.
- [ ] **DATA-02** `MUST` DLP на исходящем трафике к публичным AI-сервисам, блокировка неутверждённых сервисов на прокси.
- [ ] **DATA-03** `MUST` Логи промптов и ответов содержат чувствительные данные: маскирование PII и секретов, ограниченный retention, отдельный доступ, шифрование.
- [ ] **DATA-04** `MUST` Персональные данные в AI-системах обрабатываются на правовом основании (152-ФЗ / GDPR). Удаление по запросу субъекта распространяется на RAG-индексы, память агентов, кеши и логи (для обученных весов — оценка и документирование ограничений).
- [ ] **DATA-05** `MUST` Для внешних API используются корпоративные условия без обучения на данных клиента. Настройки zero/limited retention подтверждены договором.
- [ ] **DATA-06** `SHOULD` Эмбеддинги, чекпоинты и адаптеры, обученные на чувствительных данных, классифицируются по уровню исходных данных.

---

## Маппинг на OWASP

| OWASP Top 10 for LLM Applications (2025/2026) | Где закрыто |
|---|---|
| Prompt Injection (в 2026 — включая кросс-модальную) | LA-A/B, AG-D, RAG-A, MCP-A, SK-C, DEV-C |
| Sensitive Information Disclosure | LA-04/05/14, DATA, RAG-B, FT-03/17 |
| Supply Chain | MR-A, OPS-B/C/D, FT-C, SK-A, MCP-01 |
| Data and Model Poisoning | FT-A/D, RAG-06/07, MR-09 |
| Improper Output Handling | LA-C |
| Excessive Agency | AG-B/C, MCP-A, SK-B, DEV-B |
| System Prompt Leakage → Hidden Context Exposure (2026) | LA-01/02 |
| Vector and Embedding Weaknesses | RAG |
| Misinformation | LA-D, DEV-12 |
| Unbounded Consumption | MR-15, LA-17, AG-28 |

> В редакции 2026 года (август 2026) пункты переупорядочены и частично переименованы. Номера `LLMxx` здесь намеренно не указаны, сверяйте с официальным документом.

OWASP Top 10 for Agentic Applications 2026 (ASI01–ASI10) размечен в [Agent Security](Agent%20Security.md). OWASP Agentic Skills Top 10 (AST) — в [Skill_security](Skill_security.md).

---

## Регуляторика и стандарты (статус на ноябрь 2026)

| Документ | Что это | Применимость |
|---|---|---|
| **EU AI Act** (Регламент 2024/1689) + AI Omnibus (2026) | закон ЕС, риск-ориентированный | Обязательства для GPAI действуют с 02.08.2025. По Omnibus обязательства для high-risk перенесены: Annex III — на 02.12.2027, Annex I — на 02.08.2028. Маркировка AI-контента — с 02.12.2026. Даты сверять с EUR-Lex |
| **Приказ ФСТЭК России № 117** (11.04.2025) | требования к защите информации в ГИС, вступил в силу 01.03.2026 | содержит отдельные требования к использованию ИИ в ГИС. Проверять по актуальному тексту |
| **ISO/IEC 42001:2023** | система менеджмента AI | сертифицируемый стандарт |
| **NIST AI RMF 1.0 + AI 600-1** (GenAI Profile) | фреймворк управления рисками | добровольный, хорошая структура |
| **NIST AI 100-2 E2025** | таксономия атак adversarial ML | терминология, классификация атак |
| **MITRE ATLAS** | матрица тактик и техник атак на AI | моделирование угроз, red teaming |
| **OWASP GenAI Security Project** | LLM Top 10, Agentic Top 10, AI Testing Guide, AIBOM, Agent Control Standard (2026) | практические требования для AppSec |
| **OWASP AI Exchange** | свод угроз и контролей, вклад в стандарты ЕС | справочник |
| **CSA AI Controls Matrix (AICM)** | матрица контролей для облачных AI | аудит поставщиков |
| **Google SAIF** | фреймворк безопасного AI | архитектурные принципы |
| **ETSI TS 104 223** | базовые требования к кибербезопасности AI | основан на UK AI Cyber Security Code of Practice |

## Источники
- MITRE ATLAS — https://atlas.mitre.org/matrices/ATLAS-matrix
- NIST AI 100-2 E2025 — https://csrc.nist.gov/pubs/ai/100/2/e2025/final
- NIST AI 600-1 — https://doi.org/10.6028/NIST.AI.600-1
- OWASP GenAI Security Project — https://genai.owasp.org/
- OWASP Top 10 for LLM Applications 2026 — https://genai.owasp.org/resource/owasp-genai-llm-top-10-2026/
- OWASP Agentic Security Initiative — https://genai.owasp.org/initiatives/agentic-security-initiative/
- OWASP Agentic Skills Top 10 — https://owasp.org/www-project-agentic-skills-top-10/
- OWASP AI Exchange — https://owaspai.org/
- CSA MAESTRO — https://cloudsecurityalliance.org/blog/2025/02/06/agentic-ai-threat-modeling-framework-maestro
- EU AI Act — https://eur-lex.europa.eu/eli/reg/2024/1689/oj
