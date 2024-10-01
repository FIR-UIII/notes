https://rextester.com/l/nasm_online_compiler > LINUX
https://ideone.com/


```ASM hello.asm
global _start           ; делаем метку метку _start видимой извне
 
section .text           ; объявление секции кода
_start:                 ; объявление метки _start - точки входа в программу
    mov rax, 60         ; 60 - номер системного вызова exit 
    mov rdi, 22         ; произвольный код возврата - 22 работы (число выбрано случайно)
    syscall             ; выполняем системный вызов exit
```
```bash
root@Eugene:~/asm# nasm -f elf64 hello.asm -o hello.o
root@Eugene:~/asm# ld -o hello hello.o
root@Eugene:~/asm# ./hello
root@Eugene:~/asm# echo $?
```

### Инструкция MOV. Копирование данных
```
mov destination, source
mov rax, 5
mov rbx, rax   ; rbx=rax=5
```

### Сложение и вычитание
```
add operand1, operand2  ; operand1 = operand1 + operand2
mov rdi, 22
mov rsi, 11
add rdi, rsi    ; rdi = rdi + rsi = 22 + 11 = 33
```