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

### Auth
[] OAuth 2.1 for HTTP transport. If your server speaks HTTP, no-auth is not an option. Implement OAuth 2.1 with PKCE. Bind tokens to specific audiences.

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
