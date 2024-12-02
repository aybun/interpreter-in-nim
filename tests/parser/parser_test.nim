import unittest

import strformat
import strutils
import sequtils

import lexer/lexer
import ast/ast
import parser/[parser]

suite "TestLetStatments":
    test "test":
        let tests : seq[tuple[input: string, expectedIdentifier: string ]] = @[
            
            ("let x = 5;", "x"),
            ("let y = true;", "y"),
            ("let foobar = y;", "foobar"),

        ]

        let expectedValues = (
            5,
            true,
            "y"
        )

        for index, tt in tests.pairs:
            var l = lexer.New(input: tt.input)
            var p = parser.New(l: l)
            var program = p.ParseProgram()    
            
            # 1
            check(len(program.Statements) == 1) 

            # 2
            var s = program.Statements[0]
            try:
                testLetStatement(s:s, tt.expectedIdentifier)
            except ValueError as e:
                echo e.msg
                check(false)
            # 3
            var letStmt = cast[ast.LetStatement](s)
            var value = letStmt.Value
            check(value == expectedValues[i]) 

proc testLetStatement(s: ast.Statement, name: string): void =

    var letStmt : ast.LetStatement

    if s of ast.LetStatement:
        letStmt = cast[ast.LetStatement](s)
    else:
        var msg = &"s not *ast.LetStatement. got={s.TokenLiteral}"
        raise newException(ValueError, msg)

    if letStmt.TokenLiteral() != "let" :
        var msg = &"letStmt.TokenLiteral not 'let'. got={letStmt.TokenLiteral()}"
        raise newException(ValueError, msg)

    if letStmt.Name.Value != name: 
        var msg =  &"letStmt.Name.Value not '{name}'. got={letStmt.Name.Value}"
        raise newException(ValueError, msg)
    
    if letStmt.Name.TokenLiteral() != name :
        var msg = &"letStmt.Name.TokenLiteral() not '{name}'. got={letStmt.Name.TokenLiteral}"
        raise newException(ValueError, msg)




