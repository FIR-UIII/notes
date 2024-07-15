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
git push (-u origin main)* сохранить в удаленный репозиторий
  * только для первого раза или когда даннной ветки нет в удал.репозитории
  ** insert access token OR via Git_agent. Password does't works anymore
  > rejected (non-fast-forward):
    >> push --force: удалит коммиты отличные от fast-forward и перезатрет посление отличия
```
# Начало работы и обновление локального репозитория
```
git checkout main && git pull && git merge feature/new
```
# Pull request. После создания новой ветки проекта
```
git push -u origin (main or HEAD)
  > Create pull request: https[:]// > create pull request > code rewie > merge pull request
или через сайт github:
  > Pull request > new > from-to > create > code rewie > merge pull request
code rewie:
  > File changed > rewie:
    >> request changes - на доработку
    >> approve - утвердить
```
# Ветвление
```
git branch -v > выводит список веток с указанием * текущей
git branch {feature/new} создать новую ветку
git checkout main > переключает на ветку main
```
### Слияние merge
```
git checkout main перейти в ветку в которую будет проводится слияние
git merge <branch_new> слияние ветки branch_new в main
 > CONFLICT: конфликт одного файла - вручную проверить и выбрать эталонную версию. Удалить маркеры конфликта <<<<<<
 > Fast-forward: состояние где одна ветка стала продолжением другой влив в себя коммиты прошлой. Отлючить: `--no-ff`
 > Non-fast-forward: состония где хронология коммитов разошлась
git log --graph --oneline проверить что история коммитов не нарушена
git branch -в <branch_new> удаление ветки <branch_new>
```
# Получение данных из репозитория
```
git fetch <shortname> скачивает разницу но не сливает информацию
git pull <shortname> скачивает разницу
git clone <url> скачивает весь проект целиком
```
# История работы git
```
git log --oneline
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
