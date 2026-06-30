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
