# {.reorder: on.}
import streams
import options

import token/[token]

type
  Node = ref object of RootObj

func TokenLiteral(self: Node): string=
  return ""

type
  Statement = ref object of Node

func statementNode(s: Statement): void
func String(s:Statement): string=
  return ""



type
  Expression = ref object of Node
func statementExpression(e : Expression): void

type
  Program = ref object of Node
    Statements : seq[Statement]

func TokenLiteral(p: Program): string =
  if len(p.Statements) > 0:
    return p.Statements[0].TokenLiteral()
  else:
    return ""

proc String(p: Program): string =

  var ss = newStringStream()

  for st in p.Statements:
    ss.write(st.String())

  let out_str = ss.readAll()
  ss.close()

  return out_str

type
  Identifier = ref object of Node
    Token: token.Token
    Value: string

func expressionNode(i: Identifier):void =
  return

func TokenLiteral(i: Identifier): string=
  return i.Token.Literal

func String(i: Identifier): string=
  return i.Value

type
  LetStatement = ref object of Statement
    Token: token.Token
    Name : Identifier
    Value: Expression

func statementNode(ls: LetStatement): void =
  return

func TokenLiteral(ls: LetStatement): string =
  return ls.Token.Literal

func String(ls: LetStatement): string =
  var ss = newStringStream()

  ss.write(ls.TokenLiteral() & " ")
  ss.write(ls.Name.String(ls.Name.String()))

  if not ls.Value.isNone:
    ss.write(ls.Value.String)

  ss.write(";")

  let out_str = ss.readAll()
  ss.close()

  return out_str

type
  ReturnStatement = ref object of Node
    Token: token.Token
    ReturnValue: Expression

func statementNode(rs: ReturnStatement): void =
  return

func TokenLiteral(rs: ReturnStatement): string =
  return rs.Token.Literal

func String(rs: ReturnStatement): string =

  var ss = newStringStream()

  ss.write(rs.TokenLiteral() + " ")

  if rs.ReturnValue is not nil:
    rs.write(rs.ReturnValue.String())

  ss.write(";")

  let out_str = ss.readAll()
  ss.close()
  return out_str


type
  ExpressionStatement = ref object of Node
    Token: token.Token
    Expression: Expression


func statementNode(es: ExpressionStatement): void=
  return

func TokenLiteral(es: ExpressionStatement): string=
  return es.token.Literal

func String(es: ExpressionStatement): string=
  if ExpressionStatement is not nil:
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

func String(bs: BlockStatement): string=

  var ss = newStringStream()

  for bs in statements:
    ss.write(ss)

  let out_str = ss.readAll()
  ss.close()
  return out_str



type
  Boolean = ref object of Node
    Token: token.Token
    Value: bool

func expressionNode(b: Boolean): void=
  return

func TokenLiteral(b: Boolean): void=
  return b.Token.Literal

func String(b: Boolean): string=
  return b.Token.Literal

type
  IntegerLiteral = ref object of Node
    Token: token.Token
    Value: int64
func expressionNode(il: IntegerLiteral): void=
  return
func TokenLiteral(il: IntegerLiteral): string=
  return il.Token.Literal
func String(il: IntegerLiteral): string=
  return il.Token.Literal

type
  PrefixExpression = ref object of Node
    Token: token.Token
    Operator: string
    Right: Expression

func expressionNode(pe: PrefixExpression): void=
  return
func TokenLiteral(pe: PrefixExpression): void=
  return pe.Token.Literal
func String(pe: PrefixExpression): string=
  var ss = newStringStream()

  ss.write("(")
  ss.write(pe.Operator)
  ss.write(pe.Right.String())
  ss.write(")")

  let out_str = ss.readAll()
  ss.close()
  return out_str


type
  InfixExpression = ref object of Node
    Token: token.Token
    Left: Expression
    Operator: string
    Right: Expression

func expressionNode(oe: InfixExpression): void=
  return
func TokenLiteral(oe: InfixExpression): void=
  return ie.Token.Literal
func String(oe: IfExpression): string=

  var ss = newStringStream()
  ss.write("(")
  ss.write(oe.Left.String())
  ss.write(" " + oe.Operator + " ")
  ss.write(oe.Right.String())
  ss.write(")")

  let out_str = ss.readAll()
  ss.close()
  return out_str

type
  IfExpression = ref object of Node
    Token: token.Token
    Condition: Expression
    Consequence: BlockStatement
    Alternative: BlockStatement

func expressionNode(ie: IfExpression): void=
  return

func TokenLiteral(ie: IfExpression): void=
  return ie.Token.Literal

func String(ie: IfExpression): string=
  var ss = newStringStream()

  ss.write("if")
  ss.write(ie.Condition.String())
  ss.write(" ")
  ss.write(ie.Consequence.String())

  if ie.Alternative:
    ss.write("else ")
    ss.write(ie.Alternative.string())

  let out_str = ss.readAll()
  ss.close()
  return out_str

type
  FunctionLiteral = ref object of Node
    Token: token.Token
    Parameters: seq[Identifier]
    Body: BlockStatement

func expressionNode(fl: FunctionLiteral): void=
  return
func TokenLiteral(fl: FunctionLiteral): string=
  return fl.Token.Literal
func String(fl: FunctionLiteral): string=
  var ss = newStringStream()

  var params = newSeq[string]()

  for p in fl.Parameters:
    params.append(p.String())

  ss.write(fl.TokenLiteral())
  ss.write("(")
  ss.write(params.join(", "))
  ss.write(") ")
  ss.write(fl.Body.String())

  let out_str = ss.readAll()
  ss.closed()
  return out_str


type
  CallExpression = ref object of Node
    Token: token.Token
    Function: Expression
    Arguments: ref seq[Expression]

func expressionNode(ce: CallExpression): void=
  return
func TokenLiteral(ce: CallExpression): string=
  return ce.Token.Literal

func String(ce: CallExpression): string=
  var ss = newStringStream()

  var args = newSeq[string]

  for a in ce.Arguments:
    args.append(a.String())

  ss.write(ce.Function.String())
  ss.write("(")
  ss.write(args.join(", "))
  ss.write(")")

  let out_str = ss.readAll()
  ss.close()
  return out_str
