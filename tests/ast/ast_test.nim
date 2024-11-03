import std/strformat
import sequtils

import lexer/lexer
import ast/ast
import token/token


var letStatement = LetStatement(
  Token: token.Token(Type:Token.LET, Literal:"let" ),
  Name: Identifier(Token: token.Token(Type:Token.IDENT, Literal:"myVar"),
                   Value: "myVar",
  ),
  Value: Identifier(Token: token.Token(Type:token.IDENT, Literal:"anotherVar"),
                    Value: "anotherVar",
  ),

  )
var statements: seq[LetStatement] = @[letStatement]

var program = Program(
  Statements : statements
)



suite "ast":
  test "ast":
    var program_string = program.String()
    # if program_strinng != "let myVar = anotherVar;":
      # err_str = fmt"program.String() wrong. got={program_strinng}"

    check(program_string == "let myVar = anotherVar;")
