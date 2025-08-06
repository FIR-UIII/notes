### SSH key
```
# Создание SSH-ключа
$ ssh-keygen -C "$(whoami)@$(uname -n)-$(date -I)" -t rsa
$ cat ~/.ssh/id_rsa.pub

# аутентификация на удаленном хосте по открытому ключу ssh (id_rsa.pub)
$ ssh-copy-id username@remote_host
# аналог если cody-id нет 
$ cat ~/.ssh/id_rsa.pub | ssh username@remote_host "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"

remote_host$ cat /root/.ssh/authorized_keys
# если authorized_keys не создан
remote_host$ mkdir ~/.ssh
remote_host$ chmod 700 ~/.ssh
remote_host$ touch ~/.ssh/authorized_keys
remote_host$ chmod 600 ~/.ssh/authorized_keys
```

### SCP
```
# download: remote -> local
scp user@remote_host:remote_file local_file

# upload: local -> remote
scp local_file user@remote_host:remote_file
```
