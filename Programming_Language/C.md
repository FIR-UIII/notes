Указатель в Си/Си++— это просто адрес какого-либо места в памяти. Тип указателя в Си/Си++нужен только для проверки типов на стадии компиляции. в скомпилированном коде, никакой информации о типах указателей нет вообще.


https://godbolt.org/

scanf()
вывод информации пользователю - небезопасно
```
#include <stdio.h>
int main()
{
    int x;
    printf ("Enter X:\n");
    scanf ("%d", &x);
    printf ("You entered %d...\n", x);
    return 0;
};
```

```
lea     rdx, QWORD PTR x$[rsp]      ; помещает в регистр EAX результат суммы значения в регистре EBP и макроса x$.
lea     rcx, OFFSET FLAT:$SG7823    ; адрес переменной x.
call    scanf
```