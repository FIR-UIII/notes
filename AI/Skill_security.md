# Безопасность Agent Skills

Область: skills (папки с `SKILL.md`, скриптами и ресурсами), которые агент подгружает в контекст и исполняет (Claude Skills, Codex/Gemini skills, OpenClaw/ClawHub и т.п.), а также подобные артефакты-инструкции (`memory.md`, `AGENTS.md`, rules-файлы).
Skill — это одновременно **промпт** (текст попадает в контекст и может нести prompt injection) и **код** (скрипты исполняются с правами агента).
Связанные файлы: [Agent Security](Agent%20Security.md), [MCP Security](MCP%20Security.md), [AI Coding Assistants](AI%20Coding%20Assistants%20Security.md).

## Угрозы — OWASP Agentic Skills Top 10 (AST10, draft)
Проект в статусе черновика, названия пунктов менялись. Сверяться с https://owasp.org/www-project-agentic-skills-top-10/

| ID | Риск | Суть |
|---|---|---|
| AST01 | Malicious Skills | skill изначально вредоносный: эксфильтрация, бэкдор, скрытые инструкции |
| AST02 | Supply Chain Compromise | компрометация автора, реестра, обновления (rug pull), typosquatting |
| AST03 | Over-Privileged Skills | skill получает больше инструментов, сети и FS, чем нужно |
| AST04 | Insecure Metadata | ложные или вредоносные метаданные, атаки на парсеры YAML/JSON frontmatter |
| AST05 | Untrusted External Instructions | skill подтягивает инструкции из внешних URL во время работы |
| … | … | см. оригинал |
| AST10 | Cross-Platform Reuse | один skill переносится между платформами с разной моделью разрешений |

В публичных реестрах skills уже наблюдались массовые кампании с вредоносными skills (2026). Исследование Snyk ToxicSkills показало, что вредоносные skills обычно сочетают prompt injection в тексте и вредоносный код в скриптах.

---

## Требования

### SK-A. Происхождение и целостность
- [ ] **SK-01** `MUST` Skills устанавливаются только из утверждённого внутреннего реестра или репозитория. Автоматическая установка из публичных маркетплейсов отключена.
- [ ] **SK-02** `MUST` Skill закреплён по хешу содержимого всей папки (или по commit SHA). Хеш проверяется перед каждой загрузкой, а любое изменение требует повторного ревью (защита от rug pull).
- [ ] **SK-03** `MUST` Skills подписаны издателем. Публичный ключ берётся из trust store по identity издателя и **никогда из самого skill** (иначе атакующий подпишет своим ключом). Отозванные ключи отклоняются.
- [ ] **SK-04** `SHOULD` Инвентарь skills: владелец, версия, хеш, где используется, дата последнего ревью.

### SK-B. Манифест и минимальные привилегии
- [ ] **SK-05** `MUST` У каждого skill декларированы: назначение, `allowed-tools`, сетевой доступ (домены), доступ к FS, необходимые секреты, уровень риска.
- [ ] **SK-06** `MUST` Платформа **принудительно** применяет декларацию (skill не может вызвать инструмент вне `allowed-tools`). Декларация без enforcement — только документация.
- [ ] **SK-07** `MUST` Декларированные разрешения сверяются с фактическим поведением в песочнице перед публикацией.
- [ ] **SK-08** `MUST` Skills не содержат секретов и не просят пользователя или агента вставлять их в текст.

### SK-C. Содержимое и инъекции
- [ ] **SK-09** `MUST` Skill не загружает инструкции из внешних источников во время работы («скачай актуальные правила с URL»). Внешний контент — только данные.
- [ ] **SK-10** `MUST` Статический анализ `SKILL.md` и метаданных: невидимые Unicode (Tag, zero-width, bidi), base64 и иные закодированные блоки, HTML-комментарии с инструкциями, указания игнорировать предыдущие правила, обращения к секретам и сети, несоответствие описания реальному содержимому.
- [ ] **SK-11** `MUST` Безопасный разбор метаданных: `yaml.safe_load` (не `yaml.load`/`UnsafeLoader`, иначе `!!python/object/apply:os.system [...]` = RCE), валидация по JSON Schema / Pydantic, allowlist ключей, отказ при неизвестных полях.
- [ ] **SK-12** `MUST` Разбор skill-файлов и установка их зависимостей (`requirements.txt`, `package.json`, `pyproject.toml`) идут в изолированном процессе с минимальными привилегиями. Зависимости — недоверенный код.
- [ ] **SK-13** `SHOULD` Поведенческие сканеры, оценивающие намерение, а не только сигнатуры (например, [NVIDIA SkillSpector](https://github.com/NVIDIA/SkillSpector): быстрые статические проверки + опциональный LLM-анализ семантики). Проверка соответствия skill его заявленной семантике.

### SK-D. Исполнение
- [ ] **SK-14** `MUST` Скрипты skills исполняются в песочнице: без сети по умолчанию, read-only FS, non-root, `cap-drop ALL`, `no-new-privileges`, лимиты CPU/RAM/PID/времени, образ закреплён по digest.
- [ ] **SK-15** `MUST` Исполняются только файлы из утверждённого корня (защита от path traversal и symlink).
- [ ] **SK-16** `SHOULD` Защита от подмены бренда: проверка имён на сходство с известными skills (typosquatting), отображение издателя, ключа и даты публикации в UI реестра.

---

## Примеры реализации

### Проверка подписи (Ed25519, PyNaCl) с trust store
```py
import nacl.encoding
from nacl.signing import VerifyKey
from nacl.exceptions import BadSignatureError


def verify_skill_signature(skill_content: bytes, signature: str, public_key: str) -> bool:
    """Verify Ed25519 signature of skill content using PyNaCl
    (the 'ed25519' PyPI package is unmaintained)."""
    try:
        verify_key = VerifyKey(public_key, encoder=nacl.encoding.HexEncoder)
        verify_key.verify(skill_content, bytes.fromhex(signature))
        return True
    except BadSignatureError:
        return False


# Pubkey is resolved from a trust store keyed by publisher identity,
# never accepted from the skill payload itself, so a self-signed attacker key
# cannot pass verification.
def install_skill(skill_path: str, signature: str, publisher_id: str):
    trusted_key = TRUST_STORE.get_active_key(publisher_id)  # raises if unknown or revoked
    with open(skill_path, "rb") as f:
        content = f.read()
    if not verify_skill_signature(content, signature, trusted_key):
        raise ValueError("Invalid skill signature")
    # Proceed with installation
```
> Подписывать стоит не только `SKILL.md`, но и всю папку (манифест хешей всех файлов): скрипты тоже часть skill.

### Проверка хеша при загрузке из внешнего источника
```py
import hashlib
import hmac


def verify_skill_file(file_path: str, expected_hash: str) -> bool:
    """Verify integrity of SKILL.md"""
    h = hashlib.sha256()
    with open(file_path, "rb") as f:
        for chunk in iter(lambda: f.read(65536), b""):
            h.update(chunk)
    return hmac.compare_digest(h.hexdigest(), expected_hash.lower())
```

### Исполнение скрипта skill в песочнице
```py
import subprocess
import uuid
from pathlib import Path

ALLOWED_ROOT = Path("/srv/approved-skills").resolve()
IMAGE = "alpine@sha256:<approved-digest>"


def run_skill_in_sandbox(skill_script: str, timeout: int = 30):
    """Run an approved regular file in a locked-down, digest-pinned container."""
    # is_relative_to() requires Python 3.9+
    script = Path(skill_script).resolve(strict=True)
    if not script.is_file() or not script.is_relative_to(ALLOWED_ROOT):
        raise ValueError("Skill script is outside the approved root")

    name = f"skill-{uuid.uuid4().hex}"
    cmd = [
        "docker", "run", "--rm", "--name", name, "--init",
        "--network=none", "--read-only", "--user=65532:65532",
        "--cap-drop=ALL", "--security-opt=no-new-privileges",
        "--pids-limit=64", "--memory=128m", "--cpus=0.5",
        "--tmpfs=/tmp:rw,noexec,nosuid,size=16m",
        "--env=SANDBOX=1",
        "--mount", f"type=bind,src={script},dst=/skill.sh,readonly",
        IMAGE, "sh", "/skill.sh",
    ]
    try:
        result = subprocess.run(
            cmd, capture_output=True, timeout=timeout,
            stdin=subprocess.DEVNULL, check=False,
        )
    except subprocess.TimeoutExpired:
        subprocess.run(["docker", "rm", "-f", name],
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        raise
    return result.returncode, result.stdout, result.stderr
```

### Поиск невидимых символов
```sh
# Unicode Tags, zero-width, bidi controls
grep -rnP '[\x{E0000}-\x{E007F}\x{200B}-\x{200F}\x{202A}-\x{202E}\x{2060}-\x{2064}\x{FEFF}]' skills/
```

### Манифест skill
Можно использовать формат OWASP: https://owasp.org/www-project-agentic-skills-top-10/universal-skill-format.html

Или frontmatter в `SKILL.md`:
```yaml
---
name: weather-helper
description: Получает погоду для указанного города. Используйте, когда пользователь спрашивает "какая погода в...".
allowed-tools: ["Bash(curl:https://api.weather.example/*)"]
argument-hint: [city]
---
# Инструкции для ИИ
...
```

Или отдельный манифест:
```
my-agent-skills/
└── weather-helper/
    ├── manifest.json   <-- техническое описание и разрешения
    ├── SKILL.md        <-- инструкции для модели
    └── scripts/        <-- (опционально) скрипты, которые агент запускает
```

```json
{
  "manifestVersion": "1.0",
  "skillId": "weather-helper",
  "version": "2.1.0",
  "publisher": "team-appsec",
  "description": "Получение текущей погоды для города.",
  "riskTier": "low",
  "permissions": {
    "tools": ["http_get"],
    "network": ["api.weather.example"],
    "filesystem": [],
    "secrets": []
  },
  "actions": [
    {
      "name": "get_current_weather",
      "parameters": {
        "type": "object",
        "properties": {
          "city":  { "type": "string", "maxLength": 100 },
          "units": { "type": "string", "enum": ["celsius", "fahrenheit"], "default": "celsius" }
        },
        "required": ["city"],
        "additionalProperties": false
      }
    }
  ],
  "integrity": { "files": { "SKILL.md": "sha256:...", "scripts/get.sh": "sha256:..." } }
}
```

## Источники
- OWASP Agentic Skills Top 10 — https://owasp.org/www-project-agentic-skills-top-10/
- NVIDIA SkillSpector — https://github.com/NVIDIA/SkillSpector
- Snyk, ToxicSkills research (2026)
