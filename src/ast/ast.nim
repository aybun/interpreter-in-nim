{.experimental: "codeReordering".}
import strutils
import streams
import options

import token/[token]


## Use dynamic dispatch : proc -> method
type
  Node = ref object of RootObj

method TokenLiteral*(self: Node): string {.base.} = "..."
method String*(self: Node): string {.base.} = "..."

type
  Statement* = ref object of Node

method statementNode*(s: Statement): void {.base.}= return
method TokenLiteral*(s:Statement): string = " "
method String*(s:Statement): string = "statement"


type
  Expression* = ref object of Node
method expressionNode*(pe: Expression): void {.base.} = return 
method TokenLiteral*(e:Expression): string = " "
method String*(e : Expression): string = "Expression"

type
  Program* = ref object of Node
    Statements* : seq[Statement]

method TokenLiteral*(p: Program): string =
  if len(p.Statements) > 0:
    return p.Statements[0].TokenLiteral()
  else:
    return ""
method String*(p: Program): string =

  var ss = newStringStream()

  for st in p.Statements:
    ss.write(st.String())
  
  ss.setPosition(0)
  let out_str = ss.readAll()
  ss.close()
  return out_str

type
  Identifier* = ref object of Expression
    Token*: token.Token
    Value*: string

method expressionNode*(i: Identifier):void = return

method TokenLiteral*(i: Identifier): string = return i.Token.Literal

method String*(i: Identifier): string = return i.Value

type
  LetStatement* = ref object of Statement
    Token*: token.Token
    Name* : Identifier
    Value*: Expression

method statementNode*(ls: LetStatement): void = return
method TokenLiteral*(ls: LetStatement): string = return ls.Token.Literal
method String*(ls: LetStatement): string =
  var ss = newStringStream()

  ss.write(ls.TokenLiteral() & " ")
  ss.write(ls.Name.String())
  ss.write( " = " )

  if ls.Value != nil:
    ss.write(ls.Value.String())

  ss.write(";")

  ss.setPosition(0)
  let out_str = ss.readAll()

  ss.close()
  return out_str

type
  ReturnStatement* = ref object of Statement
    Token*: token.Token
    ReturnValue*: Expression

method statementNode*(rs: ReturnStatement): void = return
method TokenLiteral*(rs: ReturnStatement): string = return rs.Token.Literal
method String*(rs: ReturnStatement): string =

  var ss = newStringStream()

  ss.write(rs.TokenLiteral() & " ")

  if rs.ReturnValue != nil:
    ss.write(rs.ReturnValue.String())

  ss.write(";")

  ss.setPosition(0)
  let out_str = ss.readAll()
  ss.close()
  return out_str

type
  ExpressionStatement* = ref object of Statement
    Token*: token.Token
    Expression*: Expression


method statementNode*(es: ExpressionStatement): void=return
method TokenLiteral*(es: ExpressionStatement): string = return es.Token.Literal
method String*(es: ExpressionStatement): string=
  if es != nil:
    return es.Expression.String()
  else:
    return ""

type
  BlockStatement* = ref object of Statement
    Token*: token.Token
    Statements*: seq[Statement]

method statementNode*(bs: BlockStatement): void = return
method TokenLiteral*(bs: BlockStatement): string = return bs.Token.Literal
method String*(bs: BlockStatement): string =

  var ss = newStringStream()

  for bs in bs.Statements:
    ss.write(ss)

  ss.setPosition(0)
  let out_str = ss.readAll()
  ss.close()
  return out_str



type
  Boolean* = ref object of Expression
    Token*: token.Token
    Value*: bool

method expressionNode*(b: Boolean): void = return
method TokenLiteral*(b: Boolean): string = return b.Token.Literal
method String*(b: Boolean): string = return b.Token.Literal

type
  IntegerLiteral* = ref object of Expression
    Token*: token.Token
    Value*: int64
method expressionNode*(il: IntegerLiteral): void = return
method TokenLiteral*(il: IntegerLiteral): string = return il.Token.Literal
method String*(il: IntegerLiteral): string = return il.Token.Literal

type
  PrefixExpression* = ref object of Expression
    Token*: token.Token
    Operator*: string
    Right*: Expression

method expressionNode*(pe: PrefixExpression): void = return
method TokenLiteral*(pe: PrefixExpression): string = return pe.Token.Literal
method String*(pe: PrefixExpression): string=
  var ss = newStringStream()

  ss.write("(")
  ss.write(pe.Operator)
  ss.write(pe.Right.String())
  ss.write(")")

  ss.setPosition(0)
  let out_str = ss.readAll()
  ss.close()
  return out_str


type
  InfixExpression* = ref object of Expression
    Token*: token.Token
    Left*: Expression
    Operator*: string
    Right*: Expression

method expressionNode*(ie: InfixExpression): void = return
method TokenLiteral*(ie: InfixExpression): string = return ie.Token.Literal
method String*(ie: InfixExpression): string=

  var ss = newStringStream()
  ss.write("(")
  ss.write(ie.Left.String())
  ss.write(" " & ie.Operator & " ")
  ss.write(ie.Right.String())
  ss.write(")")

  ss.setPosition(0)
  let out_str = ss.readAll()
  ss.close()
  return out_str

type
  IfExpression* = ref object of Expression
    Token*: token.Token
    Condition*: Expression
    Consequence*: BlockStatement
    Alternative*: BlockStatement

method expressionNode*(ie: IfExpression): void = return
method TokenLiteral*(ie: IfExpression): string = return ie.Token.Literal
method String*(ie: IfExpression): string=
  var ss = newStringStream()

  ss.write("if")
  ss.write(ie.Condition.String())
  ss.write(" ")
  ss.write(ie.Consequence.String())

  if ie.Alternative != nil:
    ss.write("else ")
    ss.write(ie.Alternative.String())


  ss.setPosition(0)
  let out_str = ss.readAll()
  ss.close()
  return out_str

type
  FunctionLiteral* = ref object of Expression
    Token*: token.Token
    Parameters*: seq[Identifier]
    Body*: BlockStatement

method expressionNode*(fl: FunctionLiteral): void = return
method TokenLiteral*(fl: FunctionLiteral): string = return fl.Token.Literal
method String*(fl: FunctionLiteral): string=
  var ss = newStringStream()

  var params = newSeq[string]()

  for p in fl.Parameters:
    params.add(p.String())

  ss.write(fl.TokenLiteral())
  ss.write("(")
  ss.write(params.join(", "))
  ss.write(") ")
  ss.write(fl.Body.String())

  ss.setPosition(0)
  let out_str = ss.readAll()
  ss.close()
  return out_str


type
  CallExpression* = ref object of Expression
    Token*: token.Token
    Function*: Expression
    Arguments*: seq[Expression]

method expressionNode*(ce: CallExpression): void = return
method TokenLiteral*(ce: CallExpression): string = return ce.Token.Literal
method String*(ce: CallExpression): string=
  var ss = newStringStream()

  var args = newSeq[string]()

  for a in ce.Arguments:
    args.add(a.String())

  ss.write(ce.Function.String())
  ss.write("(")
  ss.write(args.join(", "))
  ss.write(")")

  ss.setPosition(0)
  let out_str = ss.readAll()
  ss.close()
  return out_str


# Special Config
# Now we assume that all integers will be converted to int64
type
  SupportedLiteral* = bool | int | int32 | int64 | string

# type 
#   suportedExpression = 