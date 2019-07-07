//
//  main.swift
//  Taste
//
//  Created by Michael Griebling on 8Aug2017.
//  Copyright © 2017 Solinst Canada. All rights reserved.
//

import Foundation

let inputs = CommandLine.arguments
/* check on correct parameter usage */
if inputs.count < 2 {
    print("No input file specified")
} else {
    /* open the source file (Scanner.S_src)  */
    let srcName = inputs[1]
    let input = InputStream(fileAtPath: srcName)!
    let scanner = Scanner(s: input)
    
    print("Parsing")
    let parser = Parser(scanner: scanner)
    parser.tab = SymbolTable(parser)
    parser.gen = CodeGenerator()
    parser.Parse()
    
    if parser.errors.count > 0 {
        print("Compilation with Errors")
    } else {
        print("Parsed correctly")
        parser.gen.Decode()
        parser.gen.Interpret("Taste.IN")
    }
}
