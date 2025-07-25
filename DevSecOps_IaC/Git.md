# Основные команды
<img src="https://cloudstudio.com.au/wp-content/uploads/2021/06/GitWorkflow-4.png"  width="auth" height="300">

```BASH
echo "# Vault_FastAPI" >> README.md
touch .gitignore
git init
git add README.md
git commit -m "1.0"
git tag -a <tag_name> -m "Message for tag"
git branch -M main
git remote add origin https://github.com/FIR-UIII/Vault_FastAPI.git # Удалить: git remote remove origin
git push -u origin main

git status 
  * 'Untracked files' ='untracked' новый файл который не добавили к индексации через 'add'
  * 'Changes to be committed' = 'staged' файл был проиндексирован через add
  * 'Changes not staged for commit' = 'modified' изменен но не добавили к индексации через 'add'

git push (-u origin main)* сохранить в удаленный репозиторий
  * только для первого раза или когда даннной ветки нет в удал.репозитории
  ** insert access token OR via Git_agent. Password does't works anymore
  *** git remote set-url origin https://YOUR_TOKEN@github.com/USERNAME/REPOSITORY.git
  *** git pull --rebase origin main
  > rejected (non-fast-forward):
    >> push --force: удалит коммиты отличные от fast-forward и перезатрет посление отличия
  > You have divergent branches
    >> git pull --no-rebase
```
# Моя быстрая конфигурация для работы
```
git config --global user.name "FIR_UIII"
git config --global user.email @gmail.com
git config --global core.editor nano
git config --global alias.ch checkout 
git config --global alias.br branch
git config --global alias.com commit
git config --global alias.st status
git config --global alias.sw switch
git config --global alias.lol 'log --oneline --decorate --graph --all'
git config --list
```
# Начало работы и обновление локального репозитория
```
git checkout feature && git pull {--rebase | --merge}
   rebase - поставить локальные правки после remote
   merge - по умолчанию
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
# Ветвление и слияние
```
git branch -v -a > выводит список веток с указанием * текущей
git switch -c DEV создать новую ветку DEV (git branch DEV)
git switch DEV > только перейти в ветку DEV
git checkout main > переключает на ветку main. но с копирование файлов из прошлой (текущей ветки)
git branch -d branch-to-delete > удалить ветку которая была успешно слита
git push origin --delete branch-to-delete > удалить ветку из удаленного репозитория
```
### Слияние
1. Слияние через merge (для команды, полная история коммитов)

<img src="https://wac-cdn.atlassian.com/dam/jcr:4639eeb8-e417-434a-a3f8-a972277fc66a/02%20Merging%20main%20into%20the%20feature%20branh.svg?cdnVersion=1968"  width="300" height="auto">

```
git checkout feature перейти в ветку в которую будет проводится слияние
git merge main feature вливаем main => featur git commit коммит слияния 
```
2.Слияние через rebase (для одного,краткая история коммитов) 

<img src="https://wac-cdn.atlassian.com/dam/jcr:3bafddf5-fd55-4320-9310-3d28f4fca3af/03%20Rebasing%20the%20feature%20branch%20into%20main.svg?cdnVersion=1968"  width="300" height="auto">

```
git checkout feature
git rebase main помещаем feature вперёд main
git checkout main
git merge experiment сливаем в одну
```
### Конфликты
```
 > CONFLICT: конфликт одного файла - вручную проверить и выбрать эталонную версию. Удалить маркеры конфликта <<<<<<
 > Fast-forward: состояние где одна ветка стала продолжением другой влив в себя коммиты прошлой. Отлючить: `--no-ff`
 > Non-fast-forward: состония где хронология коммитов разошлась
git log --graph --oneline проверить что история коммитов не нарушена
git branch -в <branch_new> удаление ветки <branch_new>

<<<<<<< HEAD — начало конфликта. 
Текущее состояние
======= — разделитель между двумя версиями.
>>>>>>> NEW — окончание конфликта. 
Здесь новые изменения из другой ветки или коммита
```
# Получение данных из репозитория
```
git fetch <shortname> скачивает разницу но не сливает информацию
git pull <shortname> скачивает разницу и делает merge
git clone <url> скачивает весь проект целиком
git cherry pick <hash> скачать из другой ветки конкретный кормит в свою ветку
```
# История работы git
```
git log --oneline --decorate --graph --all
  > HEAD указывает на коммит, который сделан последним
```
# Исправление репозитория
### добавить новый файл в последний коммит (HEAD)
```
git commit --amend --no-edit
  * --no-edit сообщение коммита не будет меняться. без флага можно исправить текст комментария
git tag -a v1.0 -m "version 1.0" | git tag -d v1.0
```
### Изменить состояние репозитория
```
# После MODIFIED до ADD
git restore <file> удалить изменения в файле
git ch -- . вернуть в изначальное состояние ветки без удаление новых неиндексированных файлов

# После ADD до COMMIT
git restore --staged <file or .>
git checkout [Branch SHA] переключается между ветками
git checkout -f отменить все локальные незакоммиченные изменения
git checkout -- [имя файла] отменить отдельный незакоммиченный файл

# После COMMIT до  PUSH. не используй RESET после PUSH
git reset [SHA] переключить HEAD на последний коммит, все изменения, добавленные после, будут доступны в качестве неотслеживаемых (untracked)
git reset --soft [SHA] переключить HEAD на последний коммит, изменения, добавленные после остаются с пометкой staged.
fet reset --hard [SHA] переключите HEAD на последний коммит и уничтожите изменения, сделанные после него.

# После PUSH
git revert [SHA] добавит новый коммит который вернёт состояние всего локреп до состояния указанного хеша с сохранением всей истории
git revert HEAD~[num-of-commits-back] аналогично по количеству шагов назад

git clean -n очистка неотслеживаемых файлов из репозитория
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
# Тегирование коммитов
```
git tag <tag_name> <commit_hash or None>
git show <tag_name> display detailed information about a specific Git tag.
git tag -a v1.0 -m "Initial release of MyProject v1.0"
git push origin <tag_name> отправить метку в удаленный репозиторий
git push origin --tags     отправить все метки в удаленный репозиторий
```

# Примеры задач:
1. Обновить из другого удаленного репозитория по тегу
```sh
# скачиваем целевой репозиторий. И добавляем новый удаленный репозиторий (target_repo) откуда хотим взять изменения
git clone https://your_origin_repo.git # Или git pull
git remote add target_repo https://target_repo.git
# создаем новую ветку где будет делать слияние
git br -M 1.19.5 
# скачать конкретную версию из удаленного репозитория по тегу
git fetch target_repo refs/tags/v1.19.5
# сделать слияние в текущую ветку по тегу
git merge v1.19.5 --allow-unrelated-histories
Проверить что произошло, удалить лишние файлы и т.п.
# чтобы оставить только их (из скачанного репозитория) изменения во всех файлах:
git checkout --theirs .
# Добавляем все разрешённые файлы в индекс:
git add .
# Делаем коммит:
git commit -m "обновление до версии 1.19.5 и решение merge conflict"
```

2. Удалить все теги кроме определенных
```sh
# вывести информацию какие теги будут удалены
git tag | grep -v 'v1\.19\.5\|1.19.0-GA'
# удалить теги
git tag | grep -v 'v1\.19\.5\|1.19.0-GA' | xargs git tag -d 
```
