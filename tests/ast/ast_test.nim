import unittest

import std/strformat
import sequtils

import lexer/lexer
import ast/ast
import token/token


var letStatement = ast.LetStatement(
  Token: token.Token(Type:token.LET, Literal:"let" ),
  Name: ast.Identifier(Token: token.Token(Type :token.IDENT, Literal:"myVar"),
                   Value: "myVar",
  ),
  Value: ast.Identifier(Token: token.Token(Type:token.IDENT, Literal:"anotherVar"),
                    Value: "anotherVar",
  ),
)
var statements: seq[ast.Statement] = @[]
statements.add(letStatement)

var program = ast.Program(
  Statements : statements
)

suite "ast":
  test "ast":
    var program_string = program.String()

    check(program_string == "let myVar = anotherVar;")
    
