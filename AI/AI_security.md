| Type | Threat | Target / Attack Surface | Input | Output |
|------|--------|--------------------------|-------|--------|
| Data-Based | Training Data Extraction | Training dataset (confidentiality) | Crafted prompts designed to trigger memorised content | Verbatim or near-verbatim training data (text, PII, secrets) |
| Data-Based | Membership Inference | Training dataset membership (privacy metadata) | Known candidate data sample already possessed by the attacker | Yes/no (or probability) decision indicating whether the sample was used in training |
| Data-Based | Prompt Leakage / System Prompt Exposure (LLM07:2025) | System prompt / developer instructions | Prompts asking the model to reveal or reflect on its instructions | Partial or full disclosure of hidden system or developer prompts |
| Model-Based | Weight Extraction (Model Stealing) | Model parameters (intellectual property) | Large volumes of carefully chosen API queries | A surrogate or distilled model replicating the original model's behaviour |
| Model-Based | Model Inversion | Model's internal representations | Unknown or partially known data, or model embeddings/outputs | New training data or attributes reconstructed from the model |
| System-Based | Context Window Poisoning (Prompt Injection) | LLM context window (instruction hierarchy) | Attacker-controlled text embedded in input or retrieved content | Altered behaviour, policy bypass, unintended actions |
| System-Based | Context Overflow / Unbounded Consumption (LLM10:2025) | Context window size and system resources | Excessively large prompts or documents | Truncated safeguards, degraded responses, or denial of service |
| System-Based | Stateful Conversation Manipulation (Memory Poisoning) | Persistent conversation memory | Malicious statements intended to be stored as long-term context | Persistent misinformation or corrupted future responses |
| User-Based | LLM-Powered Social Engineering | Human cognition and decision-making | Contextual or personal information used to craft persuasive output | Manipulated users (phishing success, fraud, coerced actions) |
| User-Based | Trust Exploitation / Misinformation (LLM09:2025) | User trust and judgment | Confident but incorrect or maliciously framed prompts | Users accepting false, unsafe, or harmful information |

### Источники
https://atlas.mitre.org/matrices/ATLAS-matrix
https://csrc.nist.gov/pubs/ai/100/2/e2025/final
https://genai.owasp.org/initiatives/agentic-security-initiative/

### Agent
* Не использовать долгоживущие ключи API непосредственно в конфигурации агентов или переменных среды
* Агент не должен наследовать токены или полные авторизационне права пользователя
* Агент не должен обладать привилегиями суперпользователя
* Агент должен использовать свою уникальную NHI (non-human identity)
* Авторизацию агентов строить на разрешениях, ограниченные определенными возможностями. Т.е. перестать рассматривать разрешения с точки зрения ресурсов и начать рассматривать их с точки зрения возможностей. Не `billing:write`, а `billing.refund.issue_under_50_usd`. Рекомендуется использовать ReBAC + ABAC.
* Когда агент поддержки обнаруживает, что операция превышает его автономный порог, его бэкэнд отправляет запрос CIBA +  Rich Authorization Requests (RAR) в IAM. Пользователь получает push-уведомление на свое зарегистрированное мобильное устройство через приложение Auth0 Guardian (также поддерживаются SMS или электронная почта), и агент запрашивает ответ. Если пользователь подтверждает действие, агент получает токен, привязанный к этому конкретному действию. Вместо общего запроса «подтвердить доступ к выставлению счетов?» пользователь видит что-то конкретное, например, «подтвердить возврат 2000 долларов США клиенту Джейн Доу по заказу № 12345».

### LLM
* Проверка модели
  - https://github.com/microsoft/PyRIT
  - https://github.com/NVIDIA/garak
  - https://github.com/promptfoo/promptfoo
* Проверка целостности модели манифеста, хеш-суммы и проч. supline chain

### RAG
