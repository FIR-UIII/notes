# Minikube

Разворачивает мастер и ноды на одном хосте и в одной ноде. 

Настройка
```sh
sudo apt install bash-completion
source /etc/bash_completion
source <(minikube completion bash)
```

Kubectl - управляющая CLI

```sh
minikube start --driver=virtualbox
minikube start --driver=docker
minikube start --kubernetes-version=v1.27.10 \
  --driver=podman --profile minipod
minikube start --nodes=2 --kubernetes-version=v1.28.1 \
  --driver=docker --profile doubledocker
minikube start --driver=virtualbox --nodes=3 --disk-size=10g \
  --cpus=2 --memory=6g --kubernetes-version=v1.27.12 --cni=calico \
  --container-runtime=cri-o -p multivbox
minikube start --driver=docker --cpus=6 --memory=8g \
  --kubernetes-version="1.27.12" -p largedock
minikube start --driver=virtualbox -n 3 --container-runtime=containerd \
  --cni=calico -p minibox

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
```