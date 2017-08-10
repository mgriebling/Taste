//
//  CodeGen.swift
//  Taste
//
//  Created by Michael Griebling on 8Aug2017.
//  Copyright © 2017 Solinst Canada. All rights reserved.
//

import Foundation

/* opcodes */
public enum Op : Int {
    case ADD, SUB, MUL, DIV, EQU, LSS, GTR, NEG, LOAD, LOADG,
    STO, STOG, CONST, CALL, RET, ENTER, LEAVE, JMP, FJMP, READ, WRITE,
    UNDEF
}

public class CodeGenerator {
    
    private static let MEMSIZE = 15000
    
    var code = [UInt8](repeating:0, count:CodeGenerator.MEMSIZE)
    var stack = [Int](repeating:0, count:1000)
    var globals = [Int](repeating:0, count:1000)
    var top: Int = 0
    var bp: Int = 0
    
    public var progStart: Int  /* address of first instruction of main program */
    public var pc: Int         /* program counter */
    
    func Next() -> Int {
        let value = code[pc]; pc += 1
        return Int(value)
    }
    
    func Next2() -> Int {
        let x = Next()
        let y = Next()
        return x<<8 + y
    }
    
    func int(_ b: Bool) -> Int {
        return b ? 1 : 0
    }
    
    func Push(_ val: Int) {
        stack[top] = val; top += 1
    }
    
    func Pop() -> Int {
        top -= 1
        return stack[top]
    }
    
    func Up(_ level: Int) -> Int {
        var b = bp
        var level = level
        while level > 0 { b = stack[b]; level -= 1 }
        return b
    }

    public init() {
        pc = 1; progStart = -1
    }
    
    public func Put(_ x: Int) {
        code[pc] = UInt8(x); pc += 1
    }
    
    public func Emit(_ op: Op) {
        Put(op.rawValue)
    }
    
    public func Emit(_ op: Op, _ val: Int) {
        Emit(op); Put(val>>8); Put(val & 0xFF)
    }
    
    public func Patch( _ adr: Int, _ val: Int) {
        code[adr] = UInt8(val>>8); code[adr+1] = UInt8(val & 0xFF)
    }
    
    public func Decode() {
        let maxPc = pc
        pc = 1
        while pc < maxPc {
            let code = Op(rawValue: Next())!
            print(String(format: "%3d: \(code) ", pc-1), terminator: "")
            switch code {
            case .LOAD, .LOADG, .CONST, .STO, .STOG, .CALL, .ENTER, .JMP, .FJMP:
                print(Next2())
            case .ADD, .SUB, .MUL, .DIV, .NEG, .EQU, .LSS, .GTR, .RET, .LEAVE, .READ, .WRITE:
                print()
            case .UNDEF:
                print(" <- ERROR!")
            }
        }
    }
    
    private func ReadInt(_ s: InputStream) -> Int {
        var ch : Character
        var sign : Int
        
        func readByte() -> Character {
            var buf = [UInt8](repeating:0, count:2)
            if s.hasBytesAvailable {
                let len = s.read(&buf, maxLength: 1)
                if len == 1 { return Character(Int(buf[0])) }
            }
            return Character("\0")
        }
        
        repeat { ch = readByte() } while !(ch >= "0" && ch <= "9" || ch == "-")
        if ch == "-" { sign = -1; ch = readByte() } else { sign = 1 }
        var n = 0
        while ch >= "0" && ch <= "9" {
            n = 10 * n + (ch - "0")
            ch = readByte()
        }
        return n * sign
    }
    
    public func Interpret(_ data: String) {
        var val : Int

        if let s = InputStream(fileAtPath: data) {
            s.open()
            print()
            pc = progStart; stack[0] = 0; top = 1; bp = 0
            while true {
                switch Op(rawValue: Next())! {
                case .CONST: Push(Next2())
                case .LOAD:  Push(stack[bp+Next2()])
                case .LOADG: Push(globals[Next2()])
                case .STO:   stack[bp+Next2()] = Pop()
                case .STOG:  globals[Next2()] = Pop()
                case .ADD:   Push(Pop()+Pop())
                case .SUB:   Push(-Pop()+Pop())
                case .DIV:   val = Pop(); Push(Pop()/val)
                case .MUL:   Push(Pop()*Pop())
                case .NEG:   Push(-Pop())
                case .EQU:   Push(int(Pop()==Pop()))
                case .LSS:   Push(int(Pop()>Pop()))
                case .GTR:   Push(int(Pop()<Pop()))
                case .JMP:   pc = Next2()
                case .FJMP:  val = Next2(); if Pop() == 0 { pc = val }
                case .READ:  val = ReadInt(s); Push(val)
                case .WRITE: print(Pop())
                case .CALL:  Push(pc+2); pc = Next2()
                case .RET:   pc = Pop(); if pc == 0 { return }
                case .ENTER: Push(bp); bp = top; top = top + Next2()
                case .LEAVE: top = bp; bp = Pop()
                default: assertionFailure("illegal opcode")
                }
            }
        } else {
            print("--- Error accessing file \(data)")
        }
    }

}
