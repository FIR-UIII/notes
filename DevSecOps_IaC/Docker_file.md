`docker init` Быстро сделать .dockerignore Dockerfile compose.yaml README.Docker.md

`FROM` создает базовый слой

`MKDIR` новый слой с директорией

`COPY` новый слой с копированиев файлов из рабочего каталого в контейнер

`RUN apt update && apt -y install apache2` новый слой который выполняет команду в процессе собрания образа. Желательно не делать много слоев этой командой, а соединять в одну. Запускается в режиме shell (/bin/bash -c) удобно для написания скриптов
`RUN <<EOF
apt-get update;
apt-get install -y apache2;
rm -rf /var/lib/apt/lists/*;
EOF`

`RUN ["apt-get", "update"]` выполняет команду в режиме direct command execution

`CMD` выполнить команду после сборки образа и запуска контейнера. Желательно использовать для сокращения параметров передаваемых на запуск контейнера `docker run ...` но также могут быть переопределены этой же командой

`ENTRYPOINT` Схож с CMD, но не могут быть переписаны docker run. Определяет запуск контейнера по умолчанию и не могут быть изменены


# Info
```
$ docker pull node:latest
latest: Pulling from library/ubuntu
952132ac251a: Pull complete # <--- это один слой
82659f8f1b76: Pull complete
c19118ca682d: Pull complete
Слой может иметь несколько файлов в себе и шариться между образами
```

# multi-stage builds
```
FROM golang:1.22.1-alpine AS base        <<---- Stage 0
WORKDIR /src
COPY go.mod go.sum .
RUN go mod download
COPY . .

FROM base AS build-client                <<---- Stage 1
RUN go build -o /bin/client ./cmd/client

FROM base AS build-server                <<---- Stage 2
RUN go build -o /bin/server ./cmd/server

FROM scratch AS prod                     <<---- Stage 3
COPY --from=build-client /bin/client /bin/
COPY --from=build-server /bin/server /bin/
ENTRYPOINT [ "/bin/server" ]
```