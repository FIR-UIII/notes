### unsafe.Pointer

В обычном Go у тебя есть безопасность типов. unsafe ломает это и дает почти C-подобный контроль.
```go
var x int32 = 10 // в x типа int32 размер: 4 байта в памяти 0x1000 или [0A 00 00 00]
ptr := unsafe.Pointer(&x) // Тип исчез. “вот адрес — больше никакой информации”
y := (*int64)(ptr) // Ты говоришь компилятору: “по этому адресу лежит int64” НО: int64 = 8 байт а x = 4 байта
val := *y // Go попробует прочитать: [0A 00 00 00 ?? ?? ?? ??]
```

Когда видишь unsafe, всегда проходи по шагам:
Шаг 1 — откуда пришел pointer? `ptr := unsafe.Pointer(&buf[0])` - какой размер у исходных данных?
Шаг 2 — в какую структуру его хотят положить (кастить)? `(*MyStruct)(ptr)` - “по адресу ptr 0x1000 лежит MyStruct” и если MyStruct больше размера - то ООB, вопрос какой размер у входных данных?
Шаг 3 — есть ли арифметика? `ptr = unsafe.Pointer(uintptr(ptr) + 8)` - это риск выхода за размер стека или кучи
Размер читаемого типа ≤ размер доступной памяти

```go
// Небезопасно
func parse(buf []byte) uint64 { // нет проверки len(buf) >= 8 если buf приходит из сети: атакующий может передать короткий буфер и читать память процесса
    return *(*uint64)(unsafe.Pointer(&buf[0]))
}
// Безопасно
func ReadUint64(buf []byte) (uint64, error) {
    if len(buf) < 8 {
        return 0, fmt.Errorf("buffer too small")
    }
    return binary.LittleEndian.Uint64(buf), nil
}

// ==============
// Небезопасно
type Header struct {
    Size uint32
    Type uint32
}

func Parse(buf []byte) *Header {
    return (*Header)(unsafe.Pointer(&buf[0]))
}
// Безопасно
func Parse(buf []byte) (*Header, error) {
    if len(buf) < 8 {
        return nil, fmt.Errorf("buffer too small")
    }

    h := &Header{
        Size: binary.LittleEndian.Uint32(buf[0:4]),
        Type: binary.LittleEndian.Uint32(buf[4:8]),
    }

    return h, nil
}
// ==============
// Небезопасно
func ReadAtOffset(buf []byte, offset int) uint32 { // offset может быть любым
    ptr := unsafe.Pointer(&buf[0])
    ptr = unsafe.Pointer(uintptr(ptr) + uintptr(offset))
    return *(*uint32)(ptr)
}

// Безопасно
func ReadAtOffset(buf []byte, offset int) (uint32, error) {
    if offset < 0 || offset+4 > len(buf) {
        return 0, fmt.Errorf("invalid offset")
    }

    return binary.LittleEndian.Uint32(buf[offset:offset+4]), nil // проверка границ
}
// ==============
// Небезопасно
// Безопасно
```
