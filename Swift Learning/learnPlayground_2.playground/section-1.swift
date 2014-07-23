import Foundation


var hello = "Hello world"
println(hello + "Swift")

var a:Int[]=[1]
a+=2
a.insert(8, atIndex: 0)
a.removeLast()
a


var b:Dictionary<String,String> = ["1":"one", "2":"two"]
b["3"]="three"
b["2"]="twoo"
b.updateValue("two", forKey: "2")
b.updateValue("four", forKey: "4")
b

var tempj = 0
for i in 1...5 {
    switch i{
    case 1...5:
        continue
    default:
        tempj++
    }
}
tempj

tempj = 0
for i in 1...5 {
    switch i{
    case 1...5:
        fallthrough
    default:
        tempj++
    }
}
tempj

func test(first1 first:String, second2 second:String) -> String{
    return "hello, \(first), \(second)"
}
test(first1: "HI", second2: "HIHI")

var testfun: (String, String) -> String = test
testfun("heii","heiii")

struct Resolution {
    var width: Int = 0
    var height: Int = 0
}
class Video {
    init (aa a: Resolution, b:Bool, c:Double, d:String){
        resolution = a
        interlaced = b
        frameRate = c
        name = d
    }
    var resolution = Resolution()
    var interlaced = false
    var frameRate = 0.0
    var name: String?
}

var tempresolution = Resolution()
tempresolution.width = 1024
tempresolution.height = 768
let videoinstance = Video(aa: tempresolution, b: true, c: 30, d: "KING")

let resolutioninstance = Resolution(width: 2880, height: 1800)

var mydic = ["1": 1, "2": 2,"3": 3]
mydic.count


class StepCounter {
    var totleStep:Int = 0 {
        willSet {
            println("About to set value as \(newValue)")
        }
        didSet {
            if totleStep > oldValue{
                println("Added \(totleStep - oldValue)")
            }
        }
    }//totleStep的属性监视器，使用willSet, didSet可以监视属性值的变化。其中willSet自带newValue来获得参数，didSet自带oldValue获得参数

}
let Scounter = StepCounter()
Scounter.totleStep = 200
Scounter.totleStep = 421

