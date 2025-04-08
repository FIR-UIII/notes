### Основные команды
```bash
$ go env [-json] [var ...] # GOROOT (расположение исполняемого go) и GOPATH (местоположение рабочего пространства проекта)
tree $GOPATH
	|_ bin - содержит скомпилированные и установленные исполняемые файлы Go
	|_ pkg - содержит пакеты, включая сторонние зависимости Go
	|_ src - содержит весь исходный код, который мы создаем

# Set the appropriate GOPATH
$ export GOPATH=/path/to/your/go/projects
# Add your GOPATH bin directory to your PATH
$ export PATH=$PATH:$GOPATH/bin
# Go into your GOPATH
$ cd $GOPATH
# Create the proper directory structure
$ mkdir -p src/gitlab.com/awkwardferny
# Clone application which we will be scanning
$ git clone git@gitlab.com:awkwardferny/insecure-microservice.git src/gitlab.com/awkwardferny/insecure-microservice
# Go into the application root
$ cd src/gitlab.com/awkwardferny/insecure-microservice

$ go run [main.go] # запустить программу (компилирует и выполняет основной пакет в $GOPATH/src)
$ go build [main.go] # скомпилировать программу
$ go build -ldflags "-w -s" [main.go] # убрать отладочную информацию и таблицу символов при сборке - сократить размер на 30% размер файла

$ go install github.com/stacktitan/ldapauth # скачать внешний пакет в $GOPATH/src pip install
$ go doc fmt.Println # документация по пакетам

$ go fmt /path/to/your/package # форматирование под синтаксис и стилистику go
$ golint
$ go vet

# Кросскомпиляция (под разные архитектуры и ОС)
$ GOOS="linux" GOARCH="amd64" go build hello.go # скомпилировать ранее собранную программу для amd64 linux
$ ls
hello hello.go
$ file hello
hello: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, not stripped
```
### Основны
```
Сильная типизация
Нет ООП
Функции высшего порядка. В Go функции рассматриваются как значения и могут передаваться в другие функции, возвращаясь в виде результата.
Замыкания. Go позволяет определять и использовать функции, которые ссылаются на переменные своей родительской функции.
Чистые функции. В Go можно определять функции, которые зависят только от входящих аргументов и не влияют на глобальное состояние.
Рекурсия. Как и в большинстве языков, в Go можно применять рекурсивные вызовы функций.
Ленивые вычисления. В Go нет поддержки ленивых (отложенных) вычислений.
Иммутабельность переменных. В Go переменные могут изменять своё значение, поэтому иммутабельность (неизменяемость) переменных отсутствует.
```
### Переменные
```go
// способ 1. обьявление с указанием типа и присвоением
var i = int(3) // ИЛИ
var i, j int = 1, 2

// способ 2. обьявление переменной и типа без присвоения
var i uint32 // используй ручное объявление типа там где нужна производительность

// способ 3. автоматическое объявление с присвоением
i := 4 // наиболее частый случай использования
i, j := 1, "2"

// способ 4. множественное присваивание и объявление
var ( 
	<name> <type>     = <value>
	ToBe   bool       = false
	MaxInt uint64     = 1<<64 - 1
)

const Pi = 3.14 // константы (неизменяемые переменные) обьявляются через =. Используй где нужна защита от мутаций и изменений.

// видимость и экспортируемость переменных
const Email = "support@example.com" // глобальная экспортируемая константа
var support string // глобальная неэкспортируемая переменная
func SetSupport(s string) { // экспортируемая функция
    support = s
}
```

### Типы переменных
```go
bool
string
int  int8  int16  int32  int64
uint uint8 uint16 uint32 uint64 uintptr
byte // alias for uint8
rune // alias for int32
     // represents a Unicode code point
float32 float64
complex64 complex128
```

### Типы данных
```go
fmt.Println(reflect.TypeOf(42)) // вывести тип данных

var stringFormattedVar string
// следующие выражения равнозначны 
stringFormattedVar = "Hello,\nworld!\n\n\t\t\"quote!\""
stringFormattedVar = `Hello,
world!

        "quote!"`

// Массив (array) - коллекция фиксированного размера. USE: всегда фиксированная длина. 
// НАЗВАНИЕ := [ДЛИНА]ТИП{АРГ, АРГ ...}
arr := [4]int{3, 2, 5, 4} // массив из четырех целых значений. Нет ссылок, но можно использовать указатели. Присвоение = создаст новую ячейку в памяти

// Срез (slice) - последовательность элементов одного типа переменной длины. USE: добавить или из которой удалить элементы, не знаем размер, нужно часто менять
// PY: список string = [0]
// НАЗВАНИЕ := []ТИП{АРГ, АРГ ...}
var slice1 = []int{6, 1, 2} // длина всегда пустая 
var slice2 = make([]string, 0)
slice3 := []int{6, 1, 2} 

// Карты (map) - ассоциативный массив или хеш-таблица. USE: обработка неструктурированных данных. PY: словарь dict = {}
// НАЗВАНИЕ := map[ТИП_КЛЮЧА]ТИП_ЗНАЧЕНИЙ{"КЛЮЧ": "ЗНАЧЕНИЕ", ...}
ages := make(map[string]int)

ages := map[string]int{
    "Alice": 25, 
    "Bob":   30,
    "John":   60,
}

// Произвольный тип
type Person struct { // определяет новую структуру, содержащую два поля: string с именем Name и int с именем Age и функцию SayHello. Важно! Person - публичный тип, person закрытий тип может использоваться только внутри пакета
	Name string
	Age int
	SayHello() //обьявленеи функции внутри типа охначает, что любой тип, реализующий метод Sayhello(), будет считаться Friend. Friend фактически не реализует эту функцию — он просто говорит, что если вы Friend, то должны уметь SayHello()
}

func Greet (f Friend) { // Greet() получает интерфейс Friend в качестве ввода и выполняет приветствие в соответствующей Friend форме
	f.SayHello()
}

func main() {
	var guy = new(Person) // new ключевое слово для инициализации
	guy.Name = "Dave"
	Greet(guy)
}
```

### Packages amd import
```go
package main

import "fmt"
// Or multiple 
import (
	"fmt"
	"time"
	"math/rand" // импортируется файл с package rand внутри библиотеки math
)

// функция НАЗВАНИЕ(АРГ1_вход, АРГ2_вход, ... ТИП_вход) ТИП_выхода {тело функции}
func add(x, y int) int {
	return x + y
}

// функция НАЗВАНИЕ(АРГ_вход ТИП_вход) (АРГ1_выход, АРГ2_выход ТИП_выхода) {тело функции}
func split(sum int) (x, y int) {
	x = sum * 4 / 9
	y = sum - x
	return // допускается пустой возврат если вначале указывается аргумент и тип выхода
}

// метод для структуры (типа)
func (ПЕРЕМЕННАЯ ТИП) НАЗВАНИЕ (параметры типы_параметров) (типы_возвращаемых_значений) {
    тело_метода
}

// точка входа в программу - обязательный параметр
func main() {
	fmt.Println(add(42, 13))
	fmt.Println(split(17)) // https://pkg.go.dev/fmt
	fmt.Printf("%v", s)
}
```

### Iteration
```go
var s, sep string // обьявление переменных, до выполнения итерации
for i := 0; i < 10; i += 1 { // for УСЛОВИЕ_CТАРТА; УСЛОВИЕ_вначале_каждого_цикла - обязательно; УСЛОВИЕ_в_конце_каждого_цикла  
	sum += i // делать на каждой итерации
}

nums := []int{2,4,6,8} // инициализируем срез целых чисел nums
for idx, val := range nums { // перебора среза по длине (range) по индексу(idx) и значению(val). Если idx не нужно - можно заменить на _
	fmt.Println(idx, val)
}
```

### Condition
```go
IF / ELSE
if a == 1 {
    // сценарий, если условие if выполнено
} else if a == 2 {
    // сценарий, если условие else if выполнено
} else {
    // сценарий, если условие else if не выполнено
}

// SWITCH
switch x { // инструкция switch сравнивает содержимое переменной x с различными значениями — foo и bar
	case "foo": // case - "в случае"
	fmt.Println("Found foo")
	case "bar":
	fmt.Println("Found bar")
	default:
	fmt.Println("Default case")
}

// FOR (while нет)
for i := 0; i < 10; i++ { // инициаизация ; условное выражение ; оператор увеличения
	fmt.Println(i) // перебор чисел от 0 до 9 и вывод каждого в stdout
}
```

### Методы и интерфейсы
В Go нет классов и ООП. Но есть методы и интерфейсы
```go
func (t Type) methodName(parameter list) { ... } // создает метод methodName для структуры Type, называть следует глаголом

// Пример
type Creature struct { // создает свой тип данных Creature
	Name     string
	Greeting string
}

func (c Creature) Greet() { // создаем функцию которая принимает наш тип и расширяем его методом Greet() 
	fmt.Printf("%s says %s", c.Name, c.Greeting) // который будет выводить на экран значения
}

func main() { // применяем нам метод
	sammy := Creature{ // создаем экземпляр sammy типа Creature
		Name:     "Sammy",
		Greeting: "Hello!",
	}
	Creature.Greet(sammy) // используем метод Greet типа Creature куда передаем наш экземпляр sammy
}

// Интерфейс
/*
Интерфейс опредяет каким набором методов можно работать, т.е. это работает в сочетании с type struct и методами к нему.
Чем меньше методов - тем лучше
*/
type Stringer interface {
	String() int // метод 
}

type Book struct {
    Title  string
    Author string
}

func (b Book) String() string {
    return fmt.Sprintf("Book: %s - %s", b.Title, b.Author)
}
```

### Многопоточность
```go
func f() {
	fmt.Println("f function")
}

func main() {
	go f()
	time.Sleep(1 * time.Second)
	fmt.Println("main function")
}
```

### Обработка ошибок
```go
import "log"
...
name, err := somefunc()
if err != nil {
	log.Fatal("Fatal error: ", err)
}

// в Go нет паттерна обработки ошибок через try/catch/finally
type error interface { // interface - это встроенный тип ошибок
	Error() string
}

/* defer — выполняет блоки кода при выходе из функции, например, чтобы закрывать файлы по завершении работы с ними.
Можно рассматривать defer как замену with из Python
*/
```

### Указатели
```go
var count = int(42)
ptr := &count // c помощью оператора & создается указатель, например ptr = 0xc000010070
fmt.Println(*ptr) // вызов значения из адреса памяти ptr, вернет значение 42
*ptr = 100 // перезапишет значение в адресе на новое, т.е. count = 100
fmt.Println(count)
```

### Обработка структурированных данных
JSON XML
```go
type Foo struct {
Bar string
Baz string
}

func main() {
	f := Foo{"Joe Junior", "Hello Shabado"}
	b, _ := json.Marshal (f)
	fmt.Println(string(b))
	json.Unmarshal(b, &f)
}
```
