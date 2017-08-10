# Taste
Coco/R Taste example attributed grammar for use by my Swift-based Coco tool.

My version of the Taste compiler uses a Swift-like syntax and the attributed grammar file works with my Swift Coco tool.

The compiler tool produces machine code for a virtual machine that also runs in an included virtual simulator.
Both tools were converted from the C# version available from the Coco/R repository at http://www.ssw.uni-linz.ac.at/Coco/

The included attributed grammar file _taste.atg_ and the framework files are included.  
New source files for the Taste language can be produced using these files and the Swift-based Coco tool.

The following example compiles and runs successfully using the Taste compiler/simulator:

```swift
// This is a test program which can be compiled by the Taste-compiler.
// It reads a sequence of numbers and computes the sum of all integers 
// up to these numbers.

program Test {
  var i: Int

  func Foo() {
    var a: Int; var b: Int; var max: Int
    read a; read b
    if a > b { max = a } else { max = b }
    write max
  }

  func SumUp() {
    var sum: Int
    sum = 0
    while i > 0 { sum = sum + i; i = i - 1 }
    write sum
  }

  func Main() {
    read i
    while i > 0 {
      SumUp()
      read i
    }
  }
}

```
And here's the generated output:

```
Parsing
Parsed correctly
  1: ENTER 3
  4: READ 
  5: STO 0
  8: READ 
  9: STO 1
 12: LOAD 0
 15: LOAD 1
 18: GTR 
 19: FJMP 31
 22: LOAD 0
 25: STO 2
 28: JMP 37
 31: LOAD 1
 34: STO 2
 37: LOAD 2
 40: WRITE 
 41: LEAVE 
 42: RET 
 43: ENTER 1
 46: CONST 0
 49: STO 0
 52: LOADG 0
 55: CONST 0
 58: GTR 
 59: FJMP 85
 62: LOAD 0
 65: LOADG 0
 68: ADD 
 69: STO 0
 72: LOADG 0
 75: CONST 1
 78: SUB 
 79: STOG 0
 82: JMP 52
 85: LOAD 0
 88: WRITE 
 89: LEAVE 
 90: RET 
 91: ENTER 0
 94: READ 
 95: STOG 0
 98: LOADG 0
101: CONST 0
104: GTR 
105: FJMP 118
108: CALL 43
111: READ 
112: STOG 0
115: JMP 98
118: LEAVE 
119: RET 

6
15
5050
```
