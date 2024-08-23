
import streams
import token/[token]

type
  Node = concept n
    n.TokenLiteral() is string
    n.String() is string

type
  Statement = ref object of Node

proc statementNode(s: ref Statement): void


type
  Expression = ref object of Node

proc statementExpression(e : ref Expression): void


type
  Program = object
    Statements : ref seq[Statement]



proc TokenLiteral(p: ref Program): string =
  if len(p.Statements) > 0:
    return p.Statements[0].TokenLiteral()
  else:
    return ""

proc String(p: ref Program): string =

  var ss = newStringStream()

  for st in p.Statements:
    ss.write(st.String())

  let out_str = ss.readAll()
  ss.close()

  return out_str


type
  LetStatement = object
    Token: token.Token
    Name : ref Identifier
    Value: Expression

proc statementNode(ls: ref LetStatement): void =
  return

proc TokenLiteral(ls: ref LetStatement): string =
  return ls.Token.Literal

proc String(ls: ref LetStatement): string =
  var ss = newStringStream()

  ss.write(ls.TokenLiteral() + " ")
  ss.write(ls.Name.String(ls.Name.String()))

  if ls.Value:#? check if it's none.
    ss.write(ls.Value.String)

  ss.write(";")

  let out_str = ss.readAll()
  ss.close()

  return out_str

type
  returnStatement = object
    Token: token.Token
    ReturnValue: Expression

proc statementNode(rs: ref ReturnStatement): void =
  return

proc TokenLiteral(rs: ref ReturnStatement): string =
  return rs.Token.Literal

proc String(rs: ref ReturnStatement): string =

  var ss = newStringStream()

  ss.write(rs.TokenLiteral() + " ")

  if rs.ReturnValue:
    rs.write(rs.ReturnValue.String())

  ss.write(";")

  let out_str = ss.readAll()
  ss.close()
  return out_str


type
  ExpressionStatement = object
    Token: token.Token
    Expression: Expression


proc statementNode(es: ref ExpressionStatement): void=
  return

proc TokenLiteral(es: ref ExpressionStatement): string=
  return es.token.Literal

proc String(es: ref ExpressionStatement): string=
  if es.Expression: #? can we check addr is not null?
    return es.Expression.String()
  else:
    return ""


type
  BlockStatement = object
    Token: token.Token
    Statements: var seq[Statement]

proc statementNode(bs: BlockStatement): void=
  return

proc TokenLiteral(bs: BlockStatement): string=
  return bs.Token.Literal

proc String(bs:BlockStatement): string=

  var ss = newStringStream()

  for bs in statements:
    ss.write(ss)

  let out_str = ss.readAll()
  ss.close()
  return out


type
  Identifier = object
    Token: token.Token
    Value: string

proc expressionNode(i: ref Identifier):void =
  return

proc TokenLiteral(i: ref Identifier): string=
  return i.Token.Literal

proc String(i: ref Identifier): string=
  return i.Value

type
  Boolean = object
    Token: token.Token
    Value: bool

proc expressionNode(b: ref Boolean): void=
  return

proc TokenLiteral(b: ref Boolean): void=
  return b.Token.Literal

proc String(b: ref Boolean): string=
  return b.Token.Literal

type
  IntegerLiteral = object
    Token: token.Token
    Value: int64
proc expressionNode(il: ref IntegerLiteral): void=
  return
proc TokenLiteral(il: ref IntegerLiteral): string=
  return il.Token.Literal
proc String(il: ref IntegerLiteral): string=
  return il.Token.Literal


type
  PrefixExpression = object
    Token: token.Token
    Operator: string
    Right: Expression

proc expressionNode(pe: ref PrefixExpression): void=
  return
proc TokenLiteral(pe: PrefixExpression): void=
  return pe.Token.Literal
proc String(pe: ref PrefixExpression): string=
  var ss = newStringStream()

  ss.write("(")
  ss.write(pe.Operator)
  ss.write(pe.Right.String())
  ss.write(")")

  let out_str = ss.readAll()
  ss.close()
  return out_str


type
  InfixExpression = object
    Token: token.Token
    Left: Expression
    Operator: string
    Right: Expression

proc expressionNode(oe: ref InfixExpression): void=
  return
proc TokenLiteral(oe: ref InfixExpression): void=
  return ie.Token.Literal
proc String(oe: ref IfExpression): string=

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
  IfExpression = object
    Token: token.Token
    Condition: Expression
    Consequence: ref BlockStatement
    Alternative: ref BlockStatement

proc expressionNode(ie: ref IfExpression): void=
  return

proc TokenLiteral(ie: ref IfExpression): void=
  return ie.Token.Literal
proc String(ie: ref IfExpression): string=
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
  FunctionLiteral = object
    Token: token.Token
    Parameters: ref seq[Identifier]
    Body: ref BlockStatement

proc expressionNode(fl: ref FunctionLiteral): void=
  return
proc TokenLiteral(fl: ref FunctionLiteral): string=
  return fl.Token.Literal
proc String(fl: ref FunctionLiteral): string=
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
  CallExpression = object
    Token: token.Token
    Function: Expression
    Arguments: ref seq[Expression]

proc expressionNode(ce: CallExpression): void=
  return
proc TokenLiteral(ce: CallExpression): string=
  return ce.Token.Literal

proc String(ce: CallExpression): string=
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
