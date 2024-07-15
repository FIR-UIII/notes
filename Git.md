# Основные команды
```BASH
git init
git remote add origin {GIT_URL}
git remote -v
touch .gitignore
git add <file or .>
git status 
  * 'Untracked files' ='untracked' новый файл который не добавили к индексации через 'add'
  * 'Changes to be committed' = 'staged' файл был проиндексирован через add
  * 'Changes not staged for commit' = 'modified' изменен но не добавили к индексации через 'add'
git commit -m <type>:<task_num>:<description>
git push (-u origin main)*
  * только для первого раза или когда даннной ветки нет в удал.репозитории
  > insert access token OR via Git_agent. Password does't works anymore
git pull скачать изменения в репозитории
```
# Pull request. После создания новой ветки проекта
```
Pull request > new > from-to > create > merge pull request
```
# Ветвление
```
git branch -v > выводит список веток с указанием * текущей
git branch {new_branch} создать новую ветку
git checkout main > переключает на ветку main
```
### Слияние merge
```
git checkout main перейти в ветку в которую будет проводится слияние
git merge <branch_new> слияние ветки branch_new в main
 > CONFLICT: конфликт одного файла - вручную проверить и выбрать эталонную версию
git branch -в <branch_new> удаление ветки <branch_new>
```
# Получение данных из репозитория
```
git fetch <shortname> скачивает разницу но не сливает информацию
git pull <shortname> скачивает разницу
git clone <url> скачивает весь проект целиком
```
# История работы git
```git log --oneline
  > HEAD указывает на коммит, который сделан последним
```
# Проверить изменения
```
git diff {--staged} <hash_commitA> <hash_commitB> сравнение комиитов и файлоа
 a/ исходная версия файла
 b/ измененная версия файла
 @@ -1,10 +1,10 - с первой строки было изменено 10 строк
 - красным - удалено
 + зеленым - добавлено

git diff <branch1>{~1} <branch2> сравнение веток
  {~1} версия N коммитов назад
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
### «Откатить» файл который не был добавлен к индексации 'add'
```
git restore <file>
```
### «Откатить» коммит
```
git reset --hard <commit hash>
  * commit hash можно найти в 'git log'
```
