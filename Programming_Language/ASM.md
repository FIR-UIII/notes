MASM32 v11 download: https://masm32.com/download.htm
RadAsm IDE: http://www.assembly.com.br/
WinAsm Studio IDE: https://winasm.org/index.html
Online: https://www.tutorialspoint.com/compile_assembly_online.php 
        https://carlosrafaelgn.com.br/Asm86/
        https://yjdoc2.github.io/8086-emulator-web/compile 
        https://godbolt.org/

### Общее
| Level               |  Language             | Code                  |
| --------------------| --------------------  | --------------------  |
| High-level language | C++                   | sum = 5;              |
| Asssembly           | GNU Assembler         | movl $0x5, -0x8(%ebp) |
| Machine language    | IA-32                 | C745F805000000        |
| Digital logic       | Binary                | 1100 0111 0100 0101 1111 1000 0000 0101 0000 0000 0000 0000 0000 0000 |


### Синтаксис и Типы ассемблеров ASM
Есть два синтаксиса AT&T - UNIX, Intel - MASM Windows
Для каждой архитектуры процессовров свой асм. Нет кроссплатформенность но есть обратная совместимость для семейства архитектуры

##### GAS \ GCC
GNU Assembler или сокращенно GAS. Он поставляется как компонент набора компиляторов GCC.
GAS использует синтаксис, отличный от синтаксиса Intel (а именно синтаксис AT&T)
https://metanit.com/assembler/gas/1.4.php 
https://www.onlinegdb.com/online_gcc_assembler
https://godbolt.org/
https://www.jdoodle.com/compile-assembler-gcc-online

/usr/bin/as
```
.data
.globl greet
greet:
.string "Hello world!"
.text
.global main
main:
    pushq   %rbp
    movq    %rsp,       %rbp
```

##### MASM
Преимуществом MASM является то, что MASM использует для своих инструкций синтаксис Intel. Недостатком MASM является наличие официальной поддержки только для ОС Windows.
No online
```
.686
.model small
.stack 100h
.data
msg	db	'Hello world!$'
.code
start:
	mov	ah, 09h   ; Display the message
	lea	dx, msg
	int	21h
```

##### NASM
Netwide Assembler или NASM развивается как opensource-проект и использует синтаксис, который похож на синтаксис Intel. Является кросс-платформенным и работает почти на любой платформе.
https://www.mycompiler.io/new/asm-x86_64 
https://onecompiler.com/assembly/ 
```
section .data
    msg db "Hello world!", 0ah
section .text
    global _start
_start:
    mov rax, 1
```

### ARM64
iOS и Android, Raspberry Pi.
```
.global _start          // устанавливаем стартовый адрес программы
_start: mov X0, #1          // 1 = StdOut - поток вывода
 ldr X1, =hello             // строка для вывода на экран
 mov X2, #19                // длина строки
```

### Архитектуры
x86. Процессоры 8086 и 8088 были 16-битными, несмотря на 8-битную шину данных в 8088. Регистры в этих процессорах имели разрядность 16 бит, а набор инструкций работал с 16-битными данными. <br>

х64

х32

х16


### Создание программы
Для выполнения используются инструкции ISA. Связующее звено между железом и софтом
Компилятор > АСМ код > Ассемблер > Объектный код мнемоники
Линкер связывает объекты между собой в исполняемый файл (.exe)
Загрузчик загружает исполняемый файл в память CPU
Нет функций, циклов, ООП и проч.

# Основные понятия
1. Разрядность - размер регистров и машинного слова (16-бит реальных адресов, 32-бит защищенный режим, 86-бит long mode)
2. Регистры - ячейки памяти в ЦП для хранения данных (AX, BX, CX, DX ...) по 8 бит
  RAX, RBX, RCX, RDX - 64 bit
  EAX, EBX, ECX, EDX - 32 bit
  AX, BX, CX, DX - 16 bit
  AH, BH - 8bit high
  AL, BL - 8bit low

При выборе регистра важно учитывать размер принимаемых значений!
Так, CL - 8-разрядный и может принимать только 8-разрядные числа. Максимальное 8-разрядное положительное число - 255. Т.е. 256 в регистр не войдет и возникнет ошибка warning: byte data exceeds bounds [-w+number-overflow]

1 Bit  = 1 | 0
8 Bits = 1 Byte
Kilobyte: 1024 bytes
Megabyte: 1,048,576 bytes

3. Сегменты - при работе программы делиться на сегменты (сегмент кода CS, сегмент данных DS, сегмент стека SS). В зависимости от разрядности размер меняется для 16-битных макс. размер 64Кб, 16 байт минимально. Внутри сегмента пишется код асма. Сегменты можно группировать
  DS: var # DS - сегмент, var - смещение
  0x0051:0x0000 (по 16 бит)
4. Модель памяти. Сегменты присваиваются пространству в памяти (ОЗУ) 
  FLAT x86 - один сегмент
4. Соглашение о вызовах - 
5. Секции 