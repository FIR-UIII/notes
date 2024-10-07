https://xakep.ru/2016/12/08/reversing-malware-tutorial-part1/
https://challenges.re/
https://rbmj.github.io/iwg/exploit/walkthrough/
https://samsclass.info/127/ED_WASTC22.shtml
https://cocomelonc.github.io/tutorial/2021/09/04/welcome-to-cybersec-path.html

Инструменты: 
student@nix-bow:~$ echo 'set disassembly-flavor intel' > ~/.gdbinit

Linux
```
student@nix-bow:~$ gdb -q bow32

Dump of assembler code for function main:
   Адрес     Смещение Инструкция Операнд
   памяти
   0x00000582 <+0>: 	lea        0x4(%esp),%ecx
   0x00000586 <+4>: 	and        $0xfffffff0,%esp
   0x00000589 <+7>: 	pushl      -0x4(%ecx)
   0x0000058c <+10>:	push       %ebp
   0x0000058d <+11>:	mov        %esp,%ebp
   0x0000058f <+13>:	push       %ebx
   0x00000590 <+14>:	push       %ecx
   0x00000591 <+15>:	call       0x450 <__x86.get_pc_thunk.bx>
   0x00000596 <+20>:	add        $0x1a3e,%ebx
   0x0000059c <+26>:	mov        %ecx,%eax
```
