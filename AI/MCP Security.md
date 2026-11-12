# Безопасность MCP (Model Context Protocol)

Область: MCP-серверы (локальные stdio и удалённые Streamable HTTP), MCP-клиенты и хосты (IDE, агенты), реестры серверов.
Связанные файлы: [Agent Security](Agent%20Security.md), [Skill_security](Skill_security.md), [AI Coding Assistants](AI%20Coding%20Assistants%20Security.md).
Спецификация авторизации: https://modelcontextprotocol.io/specification/latest/basic/authorization · Security Best Practices: https://modelcontextprotocol.io/specification/latest/basic/security_best_practices

## Угрозы уровня протокола

| Угроза | Суть / пример |
|---|---|
| Tool poisoning | скрытые инструкции в описании инструмента или схеме параметров (модель их читает, пользователь нет) — Invariant Labs, 2025 |
| Rug pull | описание инструмента меняется после того, как пользователь одобрил сервер |
| Tool shadowing / коллизия имён | вредоносный сервер переопределяет или влияет на поведение инструментов другого сервера |
| Toxic flow | связка «чтение недоверенного» + «доступ к приватному» + «запись наружу» через инструменты разных серверов (GitHub MCP, 2025) |
| Вредоносный сервер | `postmark-mcp` (2025): npm-пакет MCP-сервера тайно копировал все письма атакующему |
| Command injection в клиенте или прокси | CVE-2025-6514 (`mcp-remote`): RCE через подставной OAuth endpoint |
| Открытый локальный сервер / DNS rebinding | CVE-2025-49596 (MCP Inspector): bind `0.0.0.0` без аутентификации |
| Confused deputy | MCP-прокси со статическим client_id к стороннему API позволяет получить токен без согласия пользователя |
| Token passthrough | сервер принимает токен, выданный не для него, и пробрасывает его дальше |
| Session hijacking | угадываемые или переиспользуемые `Mcp-Session-Id` |

## Требования уровня протокола

### MCP-A. Допуск серверов
- [ ] **MCP-01** `MUST` Allowlist MCP-серверов на уровне организации. Серверы берутся из утверждённого реестра, закреплены по версии и хешу, а не через `npx -y pkg@latest` / `uvx pkg`.
- [ ] **MCP-02** `MUST` Описания инструментов, схемы и промпты сервера проходят ревью при допуске. Хеш определений инструментов фиксируется, любое изменение блокирует сервер до повторного одобрения (защита от rug pull). Инструмент: `mcp-scan`.
- [ ] **MCP-03** `MUST` Инструменты разных серверов разделены по namespace. Коллизии имён блокируются.
- [ ] **MCP-04** `MUST` Клиент показывает пользователю, какой сервер и инструмент с какими параметрами вызывается. Чувствительные инструменты требуют подтверждения (см. AG-11/AG-12).

### MCP-B. Авторизация (HTTP-транспорт)
- [ ] **MCP-05** `MUST` Удалённый MCP-сервер = OAuth 2.1 resource server. Без аутентификации нельзя. Клиенты используют PKCE. Сервер публикует Protected Resource Metadata (RFC 9728).
- [ ] **MCP-06** `MUST` Токены audience-bound: клиент передаёт `resource` (RFC 8707), сервер проверяет `aud` и отклоняет токены, выданные другому ресурсу.
- [ ] **MCP-07** `MUST` **Token passthrough запрещён.** Для вызовов downstream API сервер получает собственный токен (token exchange / client credentials), а не пересылает клиентский.
- [ ] **MCP-08** `MUST` MCP-прокси к сторонним API со статическим client_id получает согласие пользователя для каждого клиента (защита от confused deputy).
- [ ] **MCP-09** `MUST` Session ID криптографически случайный, не используется для аутентификации и привязан к пользователю.
- [ ] **MCP-10** `MUST` Минимальные scope с постепенным повышением (step-up), а не «всё сразу».

### MCP-C. Сервер
- [ ] **MCP-11** `MUST` Streamable HTTP-сервер проверяет заголовок `Origin` (защита от DNS rebinding). Локальные серверы слушают `127.0.0.1`.
- [ ] **MCP-12** `MUST` Аргументы инструментов валидируются как недоверенный ввод: нет shell-интерполяции, есть параметризация, проверка путей и SSRF-защита для URL.
- [ ] **MCP-13** `MUST` Ответы инструментов не содержат секретов. Контент из внешних источников помечается как недоверенный.
- [ ] **MCP-14** `MUST` Локальные stdio-серверы запускаются в песочнице (контейнер или OS sandbox) с доступом только к нужным каталогам и доменам.
- [ ] **MCP-15** `MUST` Аудит: каждый вызов инструмента логируется (кто, какой инструмент, параметры, результат, решение об авторизации).

---

# Инфраструктурное усиление MCP-сервера

```
NETWORK LAYER
  ├── Unrestricted inbound connections      → Direct attack from unauthorized hosts
  └── Unrestricted egress                   → Exfiltration channel if injected

PROCESS LAYER
  ├── Root process execution                → Full host compromise if process escapes
  └── Excess Linux capabilities             → Privilege escalation paths

CONTAINER LAYER
  ├── Writable root filesystem              → Persistence for injected payloads
  └── No seccomp profile                    → Kernel attack surface exposed

DEPENDENCY LAYER
  ├── Unpinned package versions             → Supply chain substitution attacks
  └── Known-CVE dependencies                → Direct exploitation of known vulns

SECRETS LAYER
  ├── Credentials in env vars               → Exposed in crash dumps / logs
  └── Long-lived static secrets             → No rotation = persistent access after breach

RUNTIME LAYER
  ├── No behavioral baseline                → Anomalous activity undetected
  └── No infrastructure monitoring          → Process / network anomalies invisible
```

### Network Isolation and Egress Control
[] Inbound connections restricted to authorized agent runtime IPs / pods only — AUTOMATED
[] All other inbound traffic denied by default at network policy layer — AUTOMATED
[] Egress restricted to declared tool backend services and DNS only — AUTOMATED
[] Verified: nmap scan from unauthorized host returns no open ports — VERIFY
[] Localhost binding by default. Bind STDIO and dev servers to 127.0.0.1. Binding to 0.0.0.0 is the CVE-2025-49596 pattern. Network exposure should be an explicit flag, never a default.

Example k8s NetworkPolicy
```
# mcp-server-netpol.yaml
# Deny all traffic by default, allow only agent runtimes inbound

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: mcp-server-isolation
  namespace: ai-agents
spec:
  podSelector:
    matchLabels:
      app: mcp-server
  policyTypes: [Ingress, Egress]
  
  ingress:
    # Allow ONLY from agent runtime pods
    - from:
        - podSelector:
            matchLabels:
              role: agent-runtime
      ports:
        - port: 8443
          protocol: TCP

  egress:
    # Allow only declared downstream tool targets
    - to:
        - podSelector:
            matchLabels:
              role: tool-backend
    # DNS only — no arbitrary external egress
    - to:
        - namespaceSelector: {}
      ports:
        - port: 53
          protocol: UDP
```

### Runtime
[] MCP server process runs as non-root UID — confirmed with ps aux in container — AUTOMATED
[] ALL Linux capabilities dropped — none added back — AUTOMATED
[] Root filesystem set to read-only — write attempts return EROFS — AUTOMATED
[] seccomp profile applied — RuntimeDefault or custom profile — AUTOMATED Privilege escalation disabled — Allow
[] PrivilegeEscalation: false — AUTOMATED

Kubernetes SecurityContext
```
securityContext:
  runAsNonRoot: true
  runAsUser: 10001              # mcpserver UID
  runAsGroup: 10001
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false
  capabilities:
    drop: ["ALL"]               # Drop every capability
    add: []                      # Add back none — MCP needs none
  seccompProfile:
    type: RuntimeDefault
```

Dockerfile
```
# Build on minimal distroless base
FROM gcr.io/distroless/nodejs20-debian12 AS base

# Create non-root service account in build stage
FROM node:20-alpine AS builder
RUN addgroup -S mcpserver && adduser -S -G mcpserver mcpserver

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .

# Production stage — non-root, read-only, no shell
FROM base
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /app /app

USER mcpserver
EXPOSE 8443
ENTRYPOINT ["/nodejs/bin/node", "/app/server.js"]
```

### Dependency and Supply Chain Security
[] All dependencies pinned to exact versions — no semver ranges in package.json — SETUP
[] SCA scan blocking on high/critical CVEs in CI pipeline — AUTOMATED
[] SBOM generated and stored at each build — CycloneDX or SPDX format — AUTOMATED
[] Package manager configured to prefer internal registry for org-namespaced packages — SETUP
[] Dependabot or equivalent configured for automated PR on new CVEs — AUTOMATED

```
# .github/workflows/mcp-security.yml

name: MCP Server Security Gate
on: [push, pull_request]

jobs:
  dependency-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      # Audit with npm — fail on high/critical
      - name: npm audit
        run: npm audit --audit-level=high
      
      # Snyk for deeper CVE detection + licensing
      - name: Snyk dependency scan
        uses: snyk/actions/node@master
        with:
          args: "--severity-threshold=high --fail-on=all"
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
      
      # Generate SBOM — store as build artifact
      - name: Generate SBOM
        run: npx @cyclonedx/cyclonedx-npm --output-file sbom.json
      
      - name: Store SBOM artifact
        uses: actions/upload-artifact@v4
        with:
          name: sbom-${{ github.sha }}
          path: sbom.json
```

### Runtime Secrets Injection and Zero-Persistence Credentials
[] No credentials in Dockerfile ENV, docker-compose environment, or .env files — SETUP
[] Image scanning confirms no secrets in image layers (Trivy secret scan) — AUTOMATED
[] All credentials fetched from secrets manager at runtime startup — SETUP
[] Credentials stored in module scope — never written to process.env or disk — SETUP
[] gitleaks or truffleHog pre-commit hook blocking secret commits to repository — AUTOMATED

```
// server-init.js — credentials fetched at startup, never stored

import vault from 'node-vault';

async function fetchMCPCredentials() {
  const client = vault({
    endpoint: process.env.VAULT_ADDR,  // Only Vault addr in env
    apiVersion: 'v1'
  });
  
  // Auth via Kubernetes service account — no static token
  await client.kubernetesLogin({
    role: 'mcp-server',
    jwt: readFileSync('/var/run/secrets/kubernetes.io/serviceaccount/token', 'utf8')
  });
  
  const { data } = await client.read('mcp/data/prod/credentials');
  
  // Return — caller stores in module scope, NOT process.env
  return {
    jwt_public_key: data.data.jwt_public_key,
    tool_api_keys: data.data.tool_api_keys,
    db_password: data.data.db_password
  };
}

// Used exactly once at startup — credentials bound to module scope
export const credentials = await fetchMCPCredentials();
```
