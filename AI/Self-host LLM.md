> ⚠️ Примеры ниже — для быстрого локального запуска. Они публикуют сервер на `0.0.0.0` без аутентификации, а systemd-вариант работает под `root`. Для любого общего или серверного окружения используйте раздел [Безопасная конфигурация](#безопасная-конфигурация) и требования из [Model & Runtime Security](Model%20&%20Runtime%20Security.md).

### Docker (как одиночный сервис)
```sh
docker run -p 8080:8080 -v /path/to/models:/models --gpus all \
    ghcr.io/ggml-org/llama.cpp:server-cuda -m models/phi-4.Q4_K_M.gguf \
    -c 512 --host 0.0.0.0 --port 8080 --n-gpu-layers 999
```

### Docker compose
```docker-compose.yml
version: '3'

services:
  phi:
    image: ghcr.io/ggml-org/llama.cpp:server-cuda
    environment:
      - LLAMA_ARG_N_GPU_LAYERS=999
      - LLAMA_ARG_MODEL=/models/phi-4.Q4_K_M.gguf
    ports:
      - "8000:8080"
    volumes:
      - ./models:/models
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
```

Затем поднимаем докер
```
/models
  phi-4.Q4_K_M.gguf
$ docker compose up
```

# Systemd (служба)
```
$ git clone https://github.com/ggml-org/llama.cpp
$ cmake -B build -DGGML_CUDA=ON
$ cmake --build build --config Release

$ sudo vi /etc/systemd/system/llama-server-gemma3.service
# ------ START
[Unit]
Description=Llama Server: Gemma3 27B
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/home/deploy/llama.cpp
Environment="CUDA_VISIBLE_DEVICES=0"
ExecStart=/home/deploy/llama.cpp/build/bin/llama-server \
  --model /home/deploy/llama.cpp/models/gemma-3-27b-it-qat-q4_0-gguf \
  -ngl 999 --host 0.0.0.0 --port 8080
Restart=on-failure
RestartSec=5s
StandardOutput=file:/home/deploy/llama.cpp/logs/llama-server-gemma3.stdout.log
StandardError=file:/home/deploy/llama.cpp/logs/llama-server-gemma3.stderr.log

[Install]
WantedBy=multi-user.target
# ------ END

$ systemctl daemon-reload
$ systemctl start llama-server-gemma3
```

### Ollama
```
$ curl -fsSL https://ollama.com/install.sh | sh
$ ollama pull <model-name>
```

---

# Безопасная конфигурация

### llama.cpp в Docker Compose
```yaml
services:
  llm:
    # закрепить по digest, а не по тегу
    image: ghcr.io/ggml-org/llama.cpp:server-cuda@sha256:<digest>
    user: "10001:10001"
    read_only: true
    cap_drop: [ALL]
    security_opt: [no-new-privileges:true]
    tmpfs: [/tmp:rw,noexec,nosuid,size=64m]
    command: >
      -m /models/phi-4.Q4_K_M.gguf
      --host 0.0.0.0 --port 8080
      --api-key-file /run/secrets/llm_api_key
      --no-slots
      -ngl 999 -c 8192 --parallel 4
    secrets: [llm_api_key]
    volumes:
      - ./models:/models:ro            # модели только на чтение
    networks: [llm_internal]           # портов наружу нет
    deploy:
      resources:
        limits: { memory: 32g, pids: 256 }
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]

  proxy:                               # единственная точка входа: TLS + аутентификация (OIDC/mTLS) + rate limit
    image: nginx@sha256:<digest>
    read_only: true
    cap_drop: [ALL]
    security_opt: [no-new-privileges:true]
    volumes:
      - ./proxy/nginx.conf:/etc/nginx/nginx.conf:ro
    ports:
      - "127.0.0.1:8443:8443"          # или IP внутреннего интерфейса; не 0.0.0.0 без необходимости
    networks: [llm_internal, edge]

networks:
  llm_internal:
    internal: true                     # нет выхода в интернет у llm
  edge: {}

secrets:
  llm_api_key:
    file: ./secrets/llm_api_key.txt    # chmod 600, не в git
```
`--host 0.0.0.0` здесь относится к интерфейсу внутри контейнера в `internal`-сети. Достучаться до него можно только через `proxy`. Для сервиса, подключённого только к `internal`-сети, публикация портов с хоста не работает, поэтому нужен прокси в обеих сетях.
Не включать `--props` (POST /props меняет настройки) и `--metrics` без закрытой сети мониторинга.

### llama.cpp как systemd-служба
```ini
# /etc/systemd/system/llama-server-gemma3.service
[Unit]
Description=Llama Server: Gemma3 27B
After=network.target

[Service]
Type=simple
User=llama
Group=llama
WorkingDirectory=/opt/llama.cpp
Environment="CUDA_VISIBLE_DEVICES=0"
ExecStart=/opt/llama.cpp/build/bin/llama-server \
  --model /srv/models/gemma-3-27b-it-qat-q4_0.gguf \
  -ngl 999 --host 127.0.0.1 --port 8080 \
  --api-key-file %d/api_key --no-slots
LoadCredential=api_key:/etc/llama/api_key
Restart=on-failure
RestartSec=5s

# Hardening
NoNewPrivileges=yes
ProtectSystem=strict
ProtectHome=yes
PrivateTmp=yes
ReadOnlyPaths=/srv/models
ProtectKernelTunables=yes
ProtectKernelModules=yes
ProtectControlGroups=yes
RestrictSUIDSGID=yes
LockPersonality=yes
CapabilityBoundingSet=
AmbientCapabilities=
# логи — в journald, а не в файлы в рабочем каталоге
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```
```sh
sudo useradd -r -s /usr/sbin/nologin llama
sudo usermod -aG video llama        # доступ к /dev/nvidia* (зависит от дистрибутива)
systemd-analyze security llama-server-gemma3   # оценка hardening
```
`PrivateDevices` не включать: он скрывает `/dev/nvidia*`.

### Ollama
- Нативная установка слушает `127.0.0.1:11434` по умолчанию, а Docker-образ слушает `0.0.0.0`. Публиковать только как `127.0.0.1:11434:11434`.
- Встроенной аутентификации нет. Доступ для других пользователей открывать только через reverse proxy с аутентификацией, разрешив `/api/chat`, `/api/generate`, `/api/embed`, `/v1/*` и закрыв `/api/pull|push|create|copy|delete`.
- `OLLAMA_ORIGINS` не ставить в `*`.
