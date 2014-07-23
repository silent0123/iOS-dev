// Playground - noun: a place where people can play

import Cocoa

//----------简单值----------
var str = "Hello, playground"
let mystr = "Luca"
let explicitnum : Float = 4
let printstr = str + " " + mystr + "\(explicitnum)"
//变量和常量分别用var和let声明，可以拼接，注意类型转换

var shoplist = ["coffe", "food", "clock"]
shoplist[1]
var shopdict = ["first": "coffe", "second": "food", "last": "clock"]
shopdict["first"]
//声明数组或字典的时候直接赋值

var emptylist = String[]()
var emptydict = Dictionary<String, String>()
//直接调用初始化函数来声明空数组和字典

var emptylist2 = []
var emptydict2 = [:]
//两种更为传统和简单的方式
emptydict2 = ["first": "1"]

//----------控制流----------
let individualScores = [100, 85, 73, 60, 95, 35, 27, 99, 82]
var teamScore = 0
for score in individualScores {
    if score > 50 {
        teamScore += 3
    }
    else {
        teamScore += 1
    }
    
}
teamScore
//和python一样，条件不用用括号括起来，但是和python不同的是，循环体需要用大括号来区分

var optionalString: String? = "Hello"
optionalString == nil

var optionalName: String? = nil
var greeting = "Hello!"
if let name = optionalName {
    greeting = "Hello, \(name)"
} else {
    greeting = "Hello, I'm in else"
}
//可选值更像是给变量一个初值或者空值，当可选值为nil的时候，若其在if判断条件中，那么就认为是false；如果不为nil，那么会将可选值赋值给判断条件，然后进行判断
//swift只有可选值类型支持nil，所以说当你要创建一个"可以为空"的变量时，你就必须要用:Type?，它的意思是"Type or nil"

let vegetable = "red pepper"
switch vegetable {
case "celery":
    let vegetableComment = "Celery yoyo~"
case "cucumber", "watercress":
    let vegetableComment = "A good tea sandwich."
case let x where x.hasSuffix("pepper"):
    let vegetableComment = "Is it a spicy \(x)?"
default:
    let vegetableComment = "Everything good."
}
//switch可以脱离常见的整型判断，可以进行更丰富的判断方法

let interestingNums = [
    "A": [1, 2, 3, 4, 5],
    "B": [1, 1, 2, 7],
    "C": [8, 9]
]
var largest = 0
var index : String = ""
for (name, numbers) in interestingNums {
    for num in numbers {
        if num > largest {
            largest = num
            index = name
        }
    }
}
largest
index
//使用for循环来遍历字典，遍历方式和python很类似，注意形参的使用

var n = 2
while n < 100 {
    n = n * 2
}
n
var m = 2
do {
    m = m * 2

}while m < 100
m
//while没有什么区别，注意do while至少执行一次

var firstloop = 0
for i in 0..5 {
    firstloop++
}
firstloop
var secondloop = 0
for var i = 0; i < 5; i++ {
    secondloop++
}
secondloop
//上面两种写法，一种类似python，一种类似C，其实都是可以的. 注意..表示<，...表示<=


//----------函数和闭包----------
func greet(name: String, day: String) -> String {
    return "Hello \(name), today is \(day), Good day for us!"
}
greet("Luca", "08/08/2008")
//简单的函数声明和调用，在定义形参的时候注意指明类型，后面用 -> 来指定函数的返回值类型

func sumOf(numbers: Int...) -> Int {
    var sum = 0
    for number in numbers {
        sum += number
    }
    return sum
}
sumOf()
sumOf(1,2,3,4)
//在形参里面使用...来表示可以输入多个, 以数组的形式传参

func getGasPrices() -> (Double, Double, Double) {
    return (3.59, 3.69, 3.79)
}
getGasPrices()
//可以返回多个值，但是注意要用“元组”的形式进行返回

func returnTen() -> Int {
    var x = 10
    func add5(){
        x+=5
    }
    add5()
    return x
}
returnTen()
//函数的嵌套，被嵌套的函数可以访问外侧函数的变量，但是注意，嵌套函数一定要先声明再调用

func makeIncrementer() -> (Int -> Int) {
    func add1(number: Int) -> Int {
        return number + 1
    }
    return add1
}
var increment = makeIncrementer()
increment(7)
//函数可以作为函数的返回值（很绕），相当于返回一个函数的实例回来，然后这个实例可以再作为函数使用。

func hasMatches(list: Int[], condition: Int -> Bool) -> Bool {
    for item in list {
        if condition(item){
            return true
        }
    }
    return false
}
func lessThan5(number: Int) -> Bool {
    if number < 5 {
        return true
    } else {
        return false
    }
}
var numbers = [4, 7, 3, 9, 10]
hasMatches(numbers, lessThan5)
//把函数作为另一个函数的形参， 在形参声明的时候注意告诉函数（输入值类型 -> 返回值类型）


//函数是一种特殊的闭包，闭包可以理解为函数a将其内部的函数b作为返回值返回，而被函数a外部的某个变量c调用。(var c = a())，而这个c调用到的其实是函数b，然后函数b又会使用函数a的内部成员变量，这就形成了一个闭包。其很大的意义在于只有通过b，才可以访问a的内部成员变量，同时即使a执行完毕内存被清理之后，内存中仍然保留有成员变量number的内存空间，每次使用c，i都会根据b进行一定的运算。

numbers.map({(number: Int) -> Int in
    let result = 3 * number
    return result
})
//使用{}创建匿名闭包，使用in来将形参、返回值类型与函数体进行分割。这个闭包其实像是一个函数作为形参，作为map函数的参数


numbers.map({(number: Int) -> Int in
    if number % 2 != 0 {
        return 0
    } else {
        return 1
    }
})
//简单的练习，奇数返回0

sort([1,3,2,9,7]) {$0>$1}
//单个语句闭包会把它的执行值自动作为返回值，而如果这个闭包类型已知，可以直接跟在函数后面，而不需要指明其返回值和参数类型。（有点像最基本的函数）
numbers.map(){(number: Int) -> Int in
    let result = 3 * number
    return result
}
//当一个闭包作为最后一个参数传进函数的形参的时候，可以直接将其跟在括号后面。这个例子注意和上面的相同例子区分

//现在感觉闭包其实就是一段函数体，可以匿名，可以不匿名＝ ＝，可以作为返回值，也可以作为形参。

//----------对象和类----------
class Shape{
    var numberOfSides = 0
    func simpleDescription() -> String {
        return "A shape with \(numberOfSides) sides."
    }
}
//使用class创建类，类中成员变量和常量、方法的声明都和普通的声明一样，但是注意其上下文是这个类。

class Shape2{
    let author: String = "Luca"
    var numberOfSides = 0
    func simpleDescription() -> String {
        return "A shape with \(numberOfSides) sides, belongs to \(author)."
    }
    func getp(sides: Int) -> String{
        numberOfSides = sides
        return "numberOfSides has been changed to \(numberOfSides)"
    }
}

var instance2 = Shape2()
instance2.numberOfSides = 7
instance2.getp(8)
instance2.simpleDescription()
//通过var 变量名 ＝ 类名()来创建类的实例，使用点语法来访问每个成员变量和方法，但是这个函数仍然缺少了一些很重要的东西

class Shape3{
    let author: String = "Luca"
    var numberOfSides = 0
    var name: String
    init(name:String, number: Int) {
        self.name = name
        numberOfSides = number
    }
    func simpleDescription() -> String {
        return "A shape with \(numberOfSides) sides, belongs to \(author)."
    }
    func getp(sides: Int) -> String{
        numberOfSides = sides
        return "numberOfSides has been changed to \(numberOfSides)"
    }
}

var instance3 = Shape3(name: "SUPERMAN", number: 3)
instance3.name
instance3.getp(8)
instance3.simpleDescription()
//通过self来区别实例变量，self.xxx为类的内部变量。使用init来创建构造器，构造器接收在创建类的实例的时候所传入的参数（如上面的name, number）
//当你创建类的实例的时候，像函数传参一样为构造器传参(但是记得要加上形参的label，函数不用)。类的每个属性都需要被赋值，无论是通过声明(像numberOfSide)，还是通过构造器(像name,number)。如果在删除对象之前进行清理，要调用deinit来析构

class Rectangle: Shape3 {
    var sideLength: Int[] = []
    
    init(sideLength: Int[] ,name: String, number: Int){
        self.sideLength =  sideLength
        super.init(name: name, number: number)
    }
    
    func area() -> Int {
        return sideLength[0] * sideLength[1]
    }
    override func simpleDescription() -> String {
        return "This is a rectangle, area is \(area())"
    }
}
let test = Rectangle(sideLength: [3,4], name: "Myrectangle", number: 4)
test.area()
test.simpleDescription()
//子类继承父类的所有变量和方法，同时子类的构造函数可以获取参数，但是同时要在构造函数内使用super.来为父类的构造函数传值，使所有出现的变量都有值。
//使用override来重构父类的方法，如果不用override会报错，override的时候编译器会自动检查父类中是否存在同名函数

class EquilateralTriangle: Shape3 {
    var sideLength: Int[] = []
    
    init(sideLength: Int[] ,name: String){
        self.sideLength =  sideLength
        super.init(name: name, number: 3)
    }
    var perimeter: Int {
    get{
        return 3 * sideLength[0]
    }
    set{
        sideLength[0] =  10
    }
    }
    override func simpleDescription() -> String {
        return "This is a Triangle, side of length is \(sideLength[0])"
    }
}
var test2 = EquilateralTriangle(sideLength: [8], name: "ETriagnle")
test2.perimeter
test2.perimeter = 20
test2.simpleDescription()
//getter的调用时间是在只调用所属变量(perimeter)的时候，setter的调用时间是在要调用所属变量(perimeter)进行赋值的时候。相当于是在初始化之后，使用getter获取成员的值，用setter对类的成员进行第二次修改
//??? 有待进一步确定

class TriangleAndSquare {
    var triangle: EquilateralTriangle {
    willSet{
        square.sideLength = newValue.sideLength
    }
    }
    var square: Rectangle{
    willSet{
        triangle.sideLength =  newValue.sideLength
    }
    }
    init(size: Int[], name: String){
        square = Rectangle(sideLength: size, name: name, number: 4)
        triangle = EquilateralTriangle(sideLength: size, name: name)
    }
}
var triangleAndSquare = TriangleAndSquare(size: [3], name: "test 1 shape")
triangleAndSquare.square.sideLength
//这个感觉很复杂，当你不需要计算某些值，但是在获得新值之前仍然需要运行一些代码的时候，调用willSet或didSet。
//上面这个程序保证的是三角形和正方形的边长始终相等，在构造器中赋值一次即可
//??? 仍然不太清楚，之后要查资料

class Counter {
    var count: Int = 0
    func incrementBy(amount: Int, numberOfTimes: Int){
        for i in 0..numberOfTimes {
            count += amount
        }
    }
}
var counter =  Counter()
counter.incrementBy(3, numberOfTimes: 100)
//函数和类的方法大体一致，但是要注意的是，类的方法在被调用的时候，参数名需要显式说明（第一个不可以显式），默认情况下，其名字和内部名字一样，也可以取其他名字。
//test(1,2,3)为函数, some.test(1, second: 2, third: 3)为方法调用

let optionalRectangle: Rectangle? = Rectangle(sideLength: [3,4], name: "Optional Rect", number: 4)
let sideLength = optionalRectangle?.sideLength
//使用?创建一个可以为空的变量，即是可选值，如果?前的参数为nil，那整个表达式就是nil，如果不为nil，那么会正常进行运算，但是结果仍然是一个可选值。

//----------枚举和结构体----------
enum Rank: Int {
    case Ace = 1
    case Two, Three, Four, Five, Six, Seven, Eight, Nine, Ten
    case Jack, Queen, King
    func simpleDescription() -> String {
        switch self {
        case .Ace:
            return "ace"
        case .Jack:
            return "jack"
        case .Queen:
            return "queen"
        case .King:
            return "king"
        default:
            return String(self.toRaw())
        }
    }
}
let five = Rank.Five
let aceRawValue = five.simpleDescription()
let king =  Rank.King
let kingRawValue = king.simpleDescription()
//枚举类型使用case在枚举内部进行成员声明，每个成员都有一个名字作为标识符，但是实际上其值的类型是为枚举声明时所确定的类型（比如这里Rank的类型为Int，那么其成员都是Int类型），swift没有默认原始值。
//枚举类型和类一样可以有其自己的方法。区别是实例化的时候不用传参的，直接使用点语句来访问其成员
//当成员类型可知的时候（如在enum内部），可以缩写enum的名字，像switch里一样，如.Jack。但是当成员类型未知的时候，如在下面进行实例化的时候，需要使用全名，如Rank.Five

func CompareRank(number1: Rank, number2: Rank) -> String{
    if((number1.toRaw()) > (number2.toRaw())){
        return "\(number1) > \(number2)"
    } else {
        return "\(number1) < \(number2)"
    }
}
var compareResult = CompareRank(Rank.Queen, Rank.Six)
//练习，比较两个枚举变量的原始值. 形参声明的时候类型为Rank，但是传实参的时候注意要传的是Rank的某一个成员
//使用toRaw()来获取枚举成员的原始值

if let convertFromRank = Rank.fromRaw(11) {
    convertFromRank.simpleDescription()
}
//使用fromRaw()来获取枚举成员的标识符，但是注意的是，由于fromRaw获取的值可能为空，所以返回值是一个可选值(Rank?)，故要使用if来进行判断。

struct Card {
    var rank: Rank
    
    func simpleDescription() -> String{
        return "The \(rank.simpleDescription()) is here~"
    }
}
var myCard = Card(rank: .Queen)
myCard = Card(rank: Rank.Three)
myCard.simpleDescription()
//一个枚举成员的实例(如myCard)可以有实例值，相同的枚举成员实例可以有不同的值，在创建实例的时候传入值即可.(如上面，先给myCard一个实例值，再修改它)。

enum ServerResponse{
    case Result(String, String)
    case Error(String)
}
var success: ServerResponse = ServerResponse.Result("6:00 a.m", "8:09 a.m")
let failure = ServerResponse.Error("Something wrong...")
switch success{
case let .Result(sunrise, sunset):
    let serverResponse = "Sunrise is at \(sunrise), Sunset is at \(sunset)."
case let .Error(error):
    let serverResponse = "Failure... \(error)"
}
//enum的时候没有赋予原始值，只是简单的定义，因为枚举不一定需要原始值。
//这里switch那里故意指定了success，而success在上面是属于Result这个成员的实例，所以判断的时候会跳入result的case。一个枚举的不同成员可以关联不同的值。
//基本结果：success是一个实例值，其值是.Result("6:00 a.m", "8:09 a.m")的实例元组值；我们也可以使用success = .Error("xxxx")，来将success的值修改为.Error的实例字符串值。
//所以switch里面，第一个case可以理解为，当success的实例值为.Result的实例元组值，那么就执行第一局，如果是.Error的实例字符串值，那么就执行第二句。
//当你开始在你的代码中定义枚举的时候原始值是被预先填充的值。对于一个特定的枚举成员，它的原始值始终是相同的。实例值是当你在创建一个基于枚举成员的新常量或变量时才会被设置，并且每次当你这么做得时候，它的值可以是不同的。

//----------协议和扩展----------
protocol ExampleProtocol {
    var simpleDescription: String { get }
    mutating func Adjust()
}
//使用protocol来声明函数，协议是一个很抽象的父类，不用任何实现，只用一系列的简单声明，具体的方法实现交给子类去完成。

//类、枚举、结构都可以实现协议
class SimpleClass: ExampleProtocol {
    var simpleDescription: String = "A very simple class"
    var anotherProperty: Int = 2014
    func Adjust() {
        simpleDescription += " Now 100% adjusted"
    }
}
var simpleinstance = SimpleClass()
simpleinstance.Adjust()
let aDescription = simpleinstance.simpleDescription

//enum SimpleEnum: ExampleProtocol {
//    case simpleDescription
//    mutating func Adjust(){
//    }
//}
//枚举实现协议，待完善

extension Int: ExampleProtocol {
    var simpleDescription: String {
        return "The Int number is \(self)"
    }
    mutating func Adjust(){
        self += 42
    }
}
var testInt: Int =  8
testInt.Adjust()
testInt.simpleDescription
//使用extension可以为任意类扩展功能，比如成员或者方法。甚至是外部库或者框架库

extension Double {
    var absoluteValue : Double {
        if self >= 0 {
        return self
        } else {
        return -(self)
        }
    }
}
let testDouble: Double = -3.0
testDouble.absoluteValue
//为Double引入了一个求绝对值功能

func repeat<ItemType> (item:ItemType, times: Int) -> ItemType[]{
    var result = ItemType[]()
    for i in 0..times {
        result += item
    }
    return result
}
repeat("knock", 4)
//使用<>来创建一个泛型，泛型是一种特殊的类型，它把指定的工作推迟到实例化类或者实例化方法的时候进行。比如这里的ItemType，是实例化的时候才决定的

enum OptionalValue<T> {
    case None
    case Some(T)
}
var possibleInt: OptionalValue<Int> = .None
possibleInt = .Some(100)
//可以创建泛型类、枚举和结构。这里的泛型T，也是实例化的时候才决定的

//在类型名后面使用where来指定需求列表，例如要实现的一个协议，要限定两个类型相同，或者强制要求有某个父类
//func anyCommonElements <T, U where T: Sequence, U: Sequence, T.GeneratorType.Element: Equatable, T.GeneratorType.Element == U.GeneratorType.Element> (lhs: T, rhs: U) -> Bool { ... }
