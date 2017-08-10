//
//  SymTab.swift
//  Taste
//
//  Created by Michael Griebling on 8Aug2017.
//  Copyright © 2017 Solinst Canada. All rights reserved.
//

import Foundation

public class Obj {

    var name : String    /* name of the object */
    var type : Int       /* type of the object (undef for procs) */
    var next : Obj?      /* to next object in same scope */
    
    var kind : Int
    var adr  : Int       /* address in memory or start of proc */
    var level : Int      /* nesting level of declaration */
    
    var locals : Obj?    /* to locally declared objects */
    var nextAdr : Int    /* next free address in this scope */
    
    init() {
        name = ""
        type = 0
        next = nil
        
        kind = 0
        adr = 0
        level = 0
        locals = nil
        nextAdr = 0
    }
}

public class SymbolTable {
    
    // types
    let undef = 0; let integer = 1; let boolean = 2
    
    // object kinds
    let variable = 0; let proc = 1; let scope = 2
    
    var undefObj : Obj? /* object node for erroneous symbols */
    var curLevel : Int  /* nesting level of current scope */
    var topScope : Obj? /* topmost procedure scope */
    
    var parser : Parser
    
    public init (_ parser: Parser) {
        self.parser = parser
        topScope = nil
        curLevel = -1
        undefObj = Obj()
        undefObj!.name = "undef"; undefObj!.type = undef; undefObj!.kind = variable
        undefObj!.adr = 0; undefObj!.level = 0; undefObj!.next = nil
    }
    
    public func OpenScope() {
        let scop = Obj()
        scop.name = ""; scop.kind = scope
        scop.locals = nil; scop.nextAdr = 0
        scop.next = topScope; topScope = scop
        curLevel += 1
    }
    
    public func CloseScope() {
        topScope = topScope?.next
        curLevel -= 1
    }
    
    public func NewObj (_ name: String, _ kind: Int, _ type: Int) -> Obj {
        let obj = Obj()
        var last : Obj?
        obj.name = name; obj.type = type; obj.kind = kind
        obj.level = curLevel
        
        var p = topScope?.locals
        while p != nil {
            if p!.name == name { parser.SemErr("name declared twice") }
            last = p; p = p?.next
        }
        if last == nil { topScope?.locals = obj }
        else { last?.next = obj }
        if kind == variable {
            obj.adr = topScope!.nextAdr
            topScope!.nextAdr += 1
        }
        return obj
    }
    
    public func Find(_ name: String) -> Obj {
        var scope = topScope
        while scope != nil {
            var obj = scope!.locals
            while obj != nil {
                if obj!.name == name { return obj! }
                obj = obj!.next
            }
            scope = scope!.next
        }
        parser.SemErr(name + " is undeclared")
        return undefObj!
    }

}
