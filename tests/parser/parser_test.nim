{.experimental: "codeReordering".}

import unittest

import macros
import strformat
import strutils
import sequtils

import lexer/lexer
import ast/ast
import parser/[parser]


proc TestLetStatements(input: string, expectedIdentifier: string, expectedValue: SupportedLiteral): void =

  var l = lexer.New(input)
  var p = parser.New(l)
  var program = p.ParseProgram()    
  
  # 1
  check(len(program.Statements) == 1) 

  # 2
  var s = program.Statements[0]
  try:
    testLetStatement(s, expectedIdentifier)
  except ValueError as e:
    echo e.msg
    check(false)

  # 3
  var letStmt = cast[ast.LetStatement](s)
  var value = letStmt.Value
  try:
    testLiteralExpression(value, expectedValue)
  except ValueError as e:
    echo e.msg
    check(false)

macro testLiteralExpression(ve, exp : typed): untyped =
  result = nnkStmtList.newTree()
  var typeString = $exp.getTypeInst()

  if typeString in ["int", "int32", "int64"]:
    #testIntegerLiteral(value, cast[int64](expectedValue))
    var castStmt = nnkCast.newTree()
    castStmt.add(newIdentNode("int64"), newIdentNode("expectedValue"))
    result.add newCall("testIntegerLiteral", newIdentNode("value"), castStmt)
  elif typeString == "bool":
    #testBooleanLiteral(value, expectedValue)
    result.add newCall("testBooleanLiteral", newIdentNode("value"), newIdentNode("expectedValue"))
  elif typeString == "string":
    #testIdentifier(e, exp)
    result.add newCall("testIdentifier", newIdentNode("value"), newIdentNode("expectedValue"))
  else: 
    #raise newException(ValueError, "type of exp not handled. got={typeof(exp)}")
    #result.add newCall(newIdentNode("newException"), newIdentNode("ValueError"), newLit("type of exp not handled. got={typeof(exp)}")) 
    result = nnkRaiseStmt.newTree()
    result.add newCall(newIdentNode("newException"), newIdentNode("ValueError"), newLit("type of exp not handled. got={typeof(exp)}")) 

proc testIntegerLiteral( il: ast.Expression, value: int64): void =
  
  var integ : ast.IntegerLiteral
  if il of ast.IntegerLiteral:
    integ = cast[ast.IntegerLiteral](il)
  else:
    raise newException(ValueError, &"il not *ast.IntegerLiteral. got={$typeof(il)}" )

  if integ.Value != value:
    raise newException(ValueError, &"integ.Value not {value}. got={integ.Value}")

  if integ.TokenLiteral() != &"{value}":
    raise newException(ValueError, &"integ.TokenLiteral not {value}. got={integ.Value}")

proc testBooleanLiteral(exp: ast.Expression, value: bool): void=

  if exp == nil:
    raise newException(ValueError, &"exp is nil")
  
  var bo : ast.Boolean
  if exp of ast.Boolean:
    bo = cast[ast.Boolean](exp)
  else: 
    raise newException(ValueError, &"exp not *ast.Boolean. got={$typeof(exp)}")

  if bo.Value != value:
    raise newException(ValueError, &"bo.Value not {value}. got={bo.Value}")

  if bo.TokenLiteral() != &"{value}":
    raise newException(ValueError, &"bo.TokenLiteral not {value}. got={bo.TokenLiteral()}")

proc testIdentifier(exp: ast.Expression, value: string): void = 
 
  var ident : ast.Identifier
  
  if  exp of ast.Identifier:
    ident = cast[ast.Identifier](exp)
  else:
    raise newException(ValueError, "exp not *ast.Identifier. got={$typeof(exp)}")

  if ident.Value != value:
    raise newException(ValueError, "ident.Value not {value}. got={ident.Value}")

  if ident.TokenLiteral() != value:
    raise newException(ValueError, "ident.TokenLiteral not {value}. got={ident.TokenLiteral()}")


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



suite "TestLetStatments":
  test "test":
    
    TestLetStatements("let x = 5;", "x", 5)
    TestLetStatements("let y = true;", "y", true)
    TestLetStatements("let foobar = y;", "foobar", "y")