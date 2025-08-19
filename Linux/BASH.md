```sh
# очистить историю
cat /dev/null > ~/.bash_history && history -c && exit
```

&& - И
|| - ИЛИ
| - вывод результата на вход в следующую команду


```
tty # вывод названия текущего виртуального терминала.
/dev/pts/0 -> название и номер сессии
```
### Управление выводом потока
`<` ввод
`>` вывод
`>>` добавление в файл
`0` - стандартный ввод (клавиатура)
`1` - стандартный вывод (экран)
`2` - ошибки (экран)
```
rm test.txt 2> /dev/null # вывод в файл «пустое устройство»
rm test.txt 2> /dev/pts/2 # вывод в терминал пользов
cat<<END > text.txt # посимвольный ввод. Завершение по ключевой фразе "END"
```
🌀 Шпаргалка по циклам в Bash

Чтобы не держать в голове всю синтаксическую магию, собрали удобные примеры: for, while, until, диапазоны, чтение файлов и даже управление потоком с break и continue.
```
Цикл for в Bash:
for i in /etc/*; do
  echo $i
done

# То же самое (альтернативный синтаксис), также работает с другими видами циклов
for i in /etc/*
do
  echo $i
done

Цикл for, как в C:
for ((i = 0; i < 100; i++)); do
  echo $i
done

# альтернативный синтаксис
for ((i = 0; i < 100; i++))
do
  echo $i
done

Цикл for с диапазонами:
for i in {1..10}; do
  echo "Number: $i"
done

# С шагом
# ⇒ {НАЧАЛО..КОНЕЦ..ШАГ}
for i in {5..50..5}; do
  echo "Number: $i"
done

Цикл while в Bash:
# увеличение значения
i=1
while [[ $i -lt 4 ]]; do
  echo "Number: $i"
  ((i++))
done

# уменьшение значения
i=3
while [[ $i -gt 0 ]]; do
  echo "Number: $i"
  ((i--))
done

Цикл while true:
# длинная форма while true
while true; do
  # TODO
  # TODO
done

# или короткая запись
while :; do
  # TODO
  # TODO
done

Чтение файлов:
# использование пайпов
cat file.txt | while read line
do
  echo $line
done

# ИЛИ использование перенаправления ввода
while read line; do
  echo $line
done < "/path/to/txt/file"

Оператор continue:
# команда seq может использоваться для генерации диапазонов
for number in $(seq 1 3); do
  if [[ $number == 2 ]]; then
    continue
  fi
  echo "$number"
done

Оператор break:
for number in $(seq 1 3); do
  if [[ $number == 2 ]]; then
    # Пропустить оставшуюся часть цикла или выйти из цикла
    break
  fi
  # Здесь выведется только 1
  echo "$number"
done

Цикл until:
# увеличение значения
count=0
until [ $count -gt 10 ]; do
  echo "$count"
  ((count++))
done

# уменьшение значения
count=10
until [ $count -eq 0 ]; do
  echo "$count"
  ((count--))
done
```

