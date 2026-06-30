https://kubernetes.io/docs/tasks/configure-pod-container/security-context/

### Фильтрация Syscalls -> Seccomp
Атаки чаще происходят через syscall - bpf(), ptrace(). Решение: написать политику фильтрации системных запросов через Seccomp. Проблема в том что это сложно настраивать.
Понять какие вызовы приложению нужны можно через strace, tracee, kubectl-trace, seccomp-notifier, inspektor gadget. Проблема в том что при попытке понять какие вызовы нужны мы получим около 100 вызовов, в докере это будет больше 1000. Плюс с новым релизом приложения - профиль может сильно изменяться. Плюс приложению могут быть нужны небезопасные вызовы для своей работы например СУБД. Seccomp можно обойти.
Решение: <br>
* Использовать https://github.com/antitree/seccompute для оценки профиля Seccomp и составлению модели угроз для контейнера и приложения
* Понять какие вызовы статичны - какие динамичны
* Хорошее решение если вендор выпускает сразу и профиль seccomp для своего приложения, проверить или запросить его.

### runAsNonRoot
Команда USER, делает node пользователем по умолчанию внутри любого контейнера, запущенного с этого образа.
```dockerfile
FROM node:slim
COPY --chown=node . /home/node/app/   # <--- Copy app into the home directory with right ownership
USER node                             # <--- Switch active user to “node”. Если не выставлено то дальше все операции делает root
WORKDIR /home/node/app                # <--- Switch current directory to app
ENTRYPOINT ["npm", "start"]           # <--- This will now exec as the “node” user instead of root
```

### runAsUser / runAsGroup
Образы контейнеров могут иметь определенного пользователя и/или группу, настроенную для запуска процесса. Это можно изменить с помощью параметров runAsUser и runAsGroup. 
```pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: security-context-demo
spec:
  securityContext:
    runAsUser: 1000
    runAsGroup: 3000
    fsGroup: 2000
    supplementalGroups: [4000]
  volumes:
  - name: sec-ctx-vol
    emptyDir: {}
  containers:
  - name: sec-ctx-demo
    image: busybox:1.28
    command: [ "sh", "-c", "sleep 1h" ]
    volumeMounts:
    - name: sec-ctx-vol
      mountPath: /data/demo
    securityContext:
      allowPrivilegeEscalation: false
```

### Избегайте Privileged Containers / Escalations 
Предоставление привилегированного статуса контейнеру опасно и обычно используется как более простой способ получения определенных разрешений.
Дает все привилегии контейнеру, отключает seccomp AppArmor SELinux, отключает CGroup.

### Linux kernel capabilities
Вы можете управлять Capabilities через KubernetessecurityContext. Отдельные сapabilities или список, разделенный запятыми, могут быть представлены в виде массива строк. Кроме того, вы можете использовать сокращение -all для добавления или удаления всех capabilities
```pod.yaml
securityContext:
      capabilities:
        drop:
          - all
        add: ["MKNOD"]
```
