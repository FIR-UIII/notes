# Minikube

Разворачивает мастер и ноды на одном хосте и в одной ноде. 

### Настройка
```sh
sudo apt install bash-completion
source /etc/bash_completion
source <(minikube completion bash)
```

### Основные команды
```shell
minikube start --driver=virtualbox
minikube start --driver=docker
minikube start --kubernetes-version=v1.27.10 \
  --driver=podman --profile minipod
minikube start --nodes=2 --kubernetes-version=v1.28.1 \
  --driver=docker --profile doubledocker

minikube stop
minikube delete

minikube status
    minikube
    type: Control Plane
    host: Running
    kubelet: Running
    apiserver: Running
    kubeconfig: Configured

minikube profile list
|----------|-----------|---------|--------------|------|---------|--------|-------|----------------|--------------------|
| Profile  | VM Driver | Runtime |      IP      | Port | Version | Status | Nodes | Active Profile | Active Kubecontext |
|----------|-----------|---------|--------------|------|---------|--------|-------|----------------|--------------------|
| minikube | docker    | docker  | 192.168.49.2 | 8443 | v1.32.0 | OK     |     1 | *              | *                  |
|----------|-----------|---------|--------------|------|---------|--------|-------|----------------|--------------------|
```

##### Управление через kubectl
```sh
kubectl config view
kubectl cluster-info
```

##### Управление через dashboard
```sh
$ minikube dashboard | grep dashboard
PS> minikube addons list | findstr "dashboard"

minikube addons enable metrics-server
minikube addons enable dashboard
minikube addons list
minikube dashboard --url
```

##### Управление через API
```sh
kubectl proxy # It locks the terminal for as long as the proxy is running, unless we run it in the background (with kubectl proxy &).
  > Starting to serve on 127.0.0.1:8001
curl http://localhost:8001/
```

### Namespace
```sh
kubectl get namespaces
kubectl create namespace new-namespace-nam
```