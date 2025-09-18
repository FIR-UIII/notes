https://kubernetes.io/docs/tasks/configure-pod-container/security-context/

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
Предоставление привилегированного статуса контейнеру опасно и обычно используется как более простой способ получения определенных разрешений

### Linux kernel capabilities
Вы можете управлять Capabilities через KubernetessecurityContext. Отдельные сapabilities или список, разделенный запятыми, могут быть представлены в виде массива строк. Кроме того, вы можете использовать сокращение -all для добавления или удаления всех capabilities
```pod.yaml
securityContext:
      capabilities:
        drop:
          - all
        add: ["MKNOD"]
```
