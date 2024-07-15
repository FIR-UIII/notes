# Основные команды
```BASH
git init
git remote add origin {GIT_URL}
git remote -v
touch .gitignore
git add <file or .> 
git commit -m <type>:<task_num>:<description>
git status 
  * 'Untracked files' ='untracked' новый файл который не добавили к индексации через 'add'
  * 'Changes to be committed' = 'staged' файл был проиндексирован через add
  * 'Changes not staged for commit' = 'modified' изменен но не добавили к индексации через 'add'
git push (-u origin main)*
  * только для первого раза
  > insert access token OR via Git_agent. Password does't works anymore
```
# Исправление ошибок после commit до push
### добавить новый файл в последний коммит (HEAD)
```
git commit --amend --no-edit
  * --no-edit сообщение коммита не будет меняться
git tag -a v1.0 -m "version 1.0" | git tag -d v1.0
```
### Убрать файл из коммита
```
git restore --staged <file or .>
```
##### «Откатить» файл который не был добавлен к индексации 'add'
```
git restore <file>
```
##### «Откатить» коммит
```
git reset --hard <commit hash>
  * commit hash можно найти в 'git log'
```
# Ветвление
```
Git branch -v > выводит список веток с указанием * текущей
Git checkout main > переключает на ветку main
Git merge <branchname>
```
# получение данных из репозитория
```
Git fetch <shortname> скачивает разницу но не сливает информацию
Git pull <shortname> скачивает разницу и сливает (merge) информацию
Git clone <url> скачивает весь проект целиком
```
# История работы git
```git log --oneline
  > HEAD указывает на коммит, который сделан последним
```
# Проверить изменения
```
git diff {--staged} <hash_commitA> <hash_commitB>
 a/ исходная версия файла
 b/ измененная версия файла
 @@ -1,10 +1,10 - с первой строки было изменено 10 строк
 - красным - удалено
 + зеленым - добавлено
```
