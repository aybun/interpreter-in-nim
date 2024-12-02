{.experimental: "codeReordering".}
import strutils
import streams
import options

import token/[token]

type
  Node = ref object of RootObj

func TokenLiteral(self: Node): string=
  return ""

type
  Statement* = ref object of Node

func statementNode(s: Statement): void=
  return

func String(s:Statement): string=
  return ""



type
  Expression* = ref object of Node
proc String*(e : Expression): string
#func statementExpression(e : Expression): void

type
  Program* = ref object of Node
    Statements* : seq[Statement]

func TokenLiteral(p: Program): string =
  if len(p.Statements) > 0:
    return p.Statements[0].TokenLiteral()
  else:
    return ""

proc String*(p: Program): string =

  var ss = newStringStream()

  for st in p.Statements:
    ss.write(st.String())

  let out_str = ss.readAll()
  ss.close()

  return out_str

type
  Identifier* = ref object of Node
    Token*: token.Token
    Value*: string

func expressionNode(i: Identifier):void =
  return

func TokenLiteral(i: Identifier): string=
  return i.Token.Literal

func String(i: Identifier): string=
  return i.Value

type
  LetStatement* = ref object of Statement
    Token*: token.Token
    Name* : Identifier
    Value*: Expression

func statementNode(ls: LetStatement): void =
  return

func TokenLiteral(ls: LetStatement): string =
  return ls.Token.Literal

proc String(ls: LetStatement): string =
  var ss = newStringStream()

  ss.write(ls.TokenLiteral() & " ")
  ss.write(ls.Name.String())

  if ls.Value != nil:
    ss.write(ls.Value.String())

  ss.write(";")

  let out_str = ss.readAll()
  ss.close()

  return out_str

type
  ReturnStatement = ref object of Statement
    Token: token.Token
    ReturnValue: Expression

func statementNode(rs: ReturnStatement): void =
  return

func TokenLiteral(rs: ReturnStatement): string =
  return rs.Token.Literal

proc String(rs: ReturnStatement): string =

  var ss = newStringStream()

  ss.write(rs.TokenLiteral() & " ")

  if rs.ReturnValue != nil:
    ss.write(rs.ReturnValue.String())

  ss.write(";")

  let out_str = ss.readAll()
  ss.close()
  return out_str


type
  ExpressionStatement = ref object of Statement
    Token: token.Token
    Expression: Expression


func statementNode(es: ExpressionStatement): void=
  return

func TokenLiteral(es: ExpressionStatement): string=
  return es.Token.Literal

proc String(es: ExpressionStatement): string=
  if es != nil:
    return es.Expression.String()
  else:
    return ""


type
  BlockStatement = ref object of Statement
    Token: token.Token
    Statements: seq[Statement]

func statementNode(bs: BlockStatement): void=
  return

func TokenLiteral(bs: BlockStatement): string=
  return bs.Token.Literal

proc String(bs: BlockStatement): string=

  var ss = newStringStream()

  for bs in bs.Statements:
    ss.write(ss)

  let out_str = ss.readAll()
  ss.close()
  return out_str



type
  Boolean = ref object of Expression
    Token: token.Token
    Value: bool

func expressionNode(b: Boolean): void=
  return

func TokenLiteral(b: Boolean): string=
  return b.Token.Literal

func String(b: Boolean): string=
  return b.Token.Literal

type
  IntegerLiteral = ref object of Expression
    Token: token.Token
    Value: int64
func expressionNode(il: IntegerLiteral): void=
  return
func TokenLiteral(il: IntegerLiteral): string=
  return il.Token.Literal
func String(il: IntegerLiteral): string=
  return il.Token.Literal

type
  PrefixExpression = ref object of Expression
    Token: token.Token
    Operator: string
    Right: Expression

func expressionNode(pe: PrefixExpression): void=
  return
func TokenLiteral(pe: PrefixExpression): string=
  return pe.Token.Literal
proc String(pe: PrefixExpression): string=
  var ss = newStringStream()

  ss.write("(")
  ss.write(pe.Operator)
  ss.write(pe.Right.String())
  ss.write(")")

  let out_str = ss.readAll()
  ss.close()
  return out_str


type
  InfixExpression = ref object of Expression
    Token: token.Token
    Left: Expression
    Operator: string
    Right: Expression

func expressionNode(ie: InfixExpression): void=
  return
func TokenLiteral(ie: InfixExpression): string=
  return ie.Token.Literal
proc String(ie: InfixExpression): string=

  var ss = newStringStream()
  ss.write("(")
  ss.write(ie.Left.String())
  ss.write(" " & ie.Operator & " ")
  ss.write(ie.Right.String())
  ss.write(")")

  let out_str = ss.readAll()
  ss.close()
  return out_str

type
  IfExpression = ref object of Expression
    Token: token.Token
    Condition: Expression
    Consequence: BlockStatement
    Alternative: BlockStatement

func expressionNode(ie: IfExpression): void=
  return

func TokenLiteral(ie: IfExpression): string=
  return ie.Token.Literal

proc String(ie: IfExpression): string=
  var ss = newStringStream()

  ss.write("if")
  ss.write(ie.Condition.String())
  ss.write(" ")
  ss.write(ie.Consequence.String())

  if ie.Alternative != nil:
    ss.write("else ")
    ss.write(ie.Alternative.String())

  let out_str = ss.readAll()
  ss.close()
  return out_str

type
  FunctionLiteral = ref object of Expression
    Token: token.Token
    Parameters: seq[Identifier]
    Body: BlockStatement

func expressionNode(fl: FunctionLiteral): void=
  return
func TokenLiteral(fl: FunctionLiteral): string=
  return fl.Token.Literal
proc String(fl: FunctionLiteral): string=
  var ss = newStringStream()

  var params = newSeq[string]()

  for p in fl.Parameters:
    params.add(p.String())

  ss.write(fl.TokenLiteral())
  ss.write("(")
  ss.write(params.join(", "))
  ss.write(") ")
  ss.write(fl.Body.String())

  let out_str = ss.readAll()
  ss.close()
  return out_str


type
  CallExpression = ref object of Expression
    Token: token.Token
    Function: Expression
    Arguments: seq[Expression]

func expressionNode(ce: CallExpression): void=
  return
func TokenLiteral(ce: CallExpression): string=
  return ce.Token.Literal

proc String(ce: CallExpression): string=
  var ss = newStringStream()

  var args = newSeq[string]()

  for a in ce.Arguments:
    args.add(a.String())

  ss.write(ce.Function.String())
  ss.write("(")
  ss.write(args.join(", "))
  ss.write(")")

  let out_str = ss.readAll()
  ss.close()
  return out_str


# This is a hacky solution!!!
proc String*(e : Expression): string =

  # let s = @[Boolean, IntegerLiteral, PrefixExpression, InfixExpression, IfExpression, FunctionLiteral, CallExpression  ]

  # for expressionType in s:
  #   if e of expressionType:
  #     var casted = cast[expressionType](e)
  #     return casted.String()

  if e of Boolean:
    var casted = cast[Boolean](e)
    return casted.String()
  elif e of IntegerLiteral:
    var casted = cast[IntegerLiteral](e)
    return casted.String()
  elif e of PrefixExpression:
    var casted = cast[PrefixExpression](e)
    return casted.String()
  elif e of InfixExpression:
    var casted = cast[InfixExpression](e)
    return casted.String()
  elif e of IfExpression:
    var casted = cast[IfExpression](e)
    return casted.String()
  elif e of FunctionLiteral:
    var casted = cast[FunctionLiteral](e)
    return casted.String()
  elif e of CallExpression:
    var casted = cast[CallExpression](e)
    return casted.String()


