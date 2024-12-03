{.experimental: "codeReordering".}

import sequtils
import strformat
import strutils
import tables

import ast/[ast]
import lexer/[lexer]
import token/[token]

type #Tested
  Precedence = enum
    LOWEST = 0
    EQUALS      # ==
    LESSGREATER # > or <
    SUM         # +
    PRODUCT     # *
    PREFIX      # -X or !X
    CALL        # myFunction(X)

    NIL # Represent nil 


var precedences = {
  token.EQ:       EQUALS,
  token.NOT_EQ:   EQUALS,
  token.LT:       LESSGREATER,
  token.GT:       LESSGREATER,
  token.PLUS:     SUM,
  token.MINUS:    SUM,
  token.SLASH:    PRODUCT,
  token.ASTERISK: PRODUCT,
  token.LPAREN:   CALL,
}.toTable()


type 
  prefixParseFn = proc(p: Parser): ast.Expression
  infixParseFn = proc(p: Parser, e: ast.Expression): ast.Expression
# # The two functions below represent nil value for the above two types.
# let NIL_PREFIX_PARSE_FUNCTION = proc(p: Parser): ast.Expression = return nil
# let NIL_INFIX_PARSE_FUNCTION = proc(p: Parser, e: ast.Expression): ast.Expression = return nil

type
  Parser* = ref object of RootObj
    l* : lexer.Lexer
    errors* : seq[string]

    curToken* : token.Token
    peekToken* : token.Token

    prefixParseFns : Table[token.TokenType, prefixParseFn]
    infixParseFns : Table[token.TokenType, infixParseFn]

proc New*(l: lexer.Lexer): Parser =
  var p = Parser(l: l, errors: newSeq[string]())

  p.prefixParseFns = initTable[token.TokenType, prefixParseFn]()
  p.registerPrefix(token.IDENT, parseIdentifier)
  p.registerPrefix(token.INT, parseIntegerLiteral)
  p.registerPrefix(token.BANG, parsePrefixExpression)
  p.registerPrefix(token.MINUS, parsePrefixExpression)
  p.registerPrefix(token.TRUE, parseBoolean)
  p.registerPrefix(token.FALSE, parseBoolean)
  p.registerPrefix(token.LPAREN, parseGroupedExpression)
  p.registerPrefix(token.IF, parseIfExpression)
  p.registerPrefix(token.FUNCTION, parseFunctionLiteral)

  p.infixParseFns = initTable[token.TokenType,infixParseFn]()
  p.registerInfix(token.PLUS, parseInfixExpression)
  p.registerInfix(token.MINUS, parseInfixExpression)
  p.registerInfix(token.SLASH, parseInfixExpression)
  p.registerInfix(token.ASTERISK, parseInfixExpression)
  p.registerInfix(token.EQ, parseInfixExpression)
  p.registerInfix(token.NOT_EQ, parseInfixExpression)
  p.registerInfix(token.LT, parseInfixExpression)
  p.registerInfix(token.GT, parseInfixExpression)

  p.registerInfix(token.LPAREN, parseCallExpression)

  # Read two tokens, so curToken and peekToken are both set
  p.nextToken()
  p.nextToken()

  return p


proc nextToken(p: Parser): void = 
    p.curToken = p.peekToken
    p.peekToken = p.l.nextToken()

proc curTokenIs(p: Parser, t : token.TokenType): bool = 
  return p.curToken.Type == t 

proc peekTokenIs(p: Parser, t: token.TokenType): bool =
  return p.peekToken.Type == t    


proc expectPeek(p: Parser, t: token.TokenType): bool =

  if p.peekTokenIs(t):
    p.nextToken()
    return true
  else:
    p.peekError(t)
    return false

proc Errors(p: Parser): seq[string] = 
  return p.errors

proc peekError(p:Parser, t : token.TokenType): void =
  var msg = &"expected next token to be {t}, got {p.peekToken.Type} instead"
  p.errors.add(msg)

proc noPrefixParseFnError(p: Parser, t : token.TokenType): void =
  var msg = fmt"no prefix parse function for {t} found"
  p.errors.add(msg)

proc ParseProgram*(p: Parser): ast.Program = 
  var program = ast.Program()

  program.Statements = newSeq[ast.Statement]()

  while not p.curTokenIs(token.EOF):
    var statement = p.parseStatement()
    if statement != nil:
      program.Statements.add(statement)

    p.nextToken()
  
  return program

proc parseStatement(p: Parser): ast.Statement =
  case p.curToken.Type
  of token.LET:
    return p.parseLetStatement()
  of token.RETURN:
    return p.parseReturnStatement()
  else:
    return p.parseExpressionStatement()


proc parseLetStatement(p: Parser): ast.LetStatement =
  var stmt = ast.LetStatement(Token: p.curToken)

  if not p.expectPeek(token.IDENT):
    return nil

  stmt.Name = ast.Identifier(Token: p.curToken, Value: p.curToken.Literal )

  if not p.expectPeek(token.ASSIGN):
    return nil
  
  p.nextToken()

  stmt.Value = p.parseExpression(LOWEST)

  if p.peekTokenIs(token.SEMICOLON):
    p.nextToken()

  return stmt



proc parseReturnStatement(p: Parser): ast.ReturnStatement = 

  var stmt = ast.ReturnStatement(Token : p.curToken)

  p.nextToken()

  stmt.ReturnValue = p.parseExpression(LOWEST)

  if p.peekTokenIs(token.SEMICOLON):
    p.nextToken()

  return stmt


proc parseExpressionStatement(p: Parser): ast.ExpressionStatement =

  var stmt = ast.ExpressionStatement(Token : p.curToken)

  stmt.Expression = p.parseExpression(LOWEST)

  if (p.peekTokenIs(token.SEMICOLON)):
    p.nextToken()
  
  return stmt


# Q : How does it work???
# A : First, we assume that it is an infix expression. It it turns out not to be we just return that. 
proc parseExpression(p: Parser, precedence: Precedence): ast.Expression =

  var prefix: prefixParseFn
  
  try:
    prefix = p.prefixParseFns[p.curToken.Type]
  except KeyError as e:
    p.noPrefixParseFnError(p.curToken.Type)
    return nil
  
  var leftExp: ast.Expression = prefix(p)

  # Why do we need this?
  while not p.peekTokenIs(token.SEMICOLON) and precedence < p.peekPrecedence():

    var infix: infixParseFn
    try:
      infix = p.infixParseFns[p.curToken.Type]
    except KeyError as e:
      return leftExp

    p.nextToken()

    # Recursively evaluate the expression.
    # The left side is first evaluated by prefix().
    # Think about this expression : a + b + c     
    leftExp = infix(p, leftExp)

  # The return value should just be named result.
  # result = leftExp
  return leftExp 

proc peekPrecedence(p: Parser): Precedence =

  var p = precedences.getOrDefault(p.peekToken.Type, Precedence.NIL)
  
  if p != Precedence.NIL:
    return p
  else:
    return LOWEST

proc curPrecedence(p: Parser): Precedence =

  var p = precedences.getOrDefault(p.curToken.Type, Precedence.NIL)

  if p != Precedence.NIL:
    return p
  else:
    return LOWEST

proc parseIdentifier(p: Parser): ast.Expression = 
  return ast.Identifier(Token: p.curToken, Value: p.curToken.Literal)


proc parseIntegerLiteral(p: Parser): ast.Expression =

  var lit = ast.IntegerLiteral(Token: p.curToken)

  var msg:string

  var parsed : int64
  try:
    parsed = parseInt(p.curToken.Literal)
  except ValueError:
    msg = fmt"could not parse {p.curToken.Literal} as integer"
    p.errors.add(msg)
    return nil
  
  lit.Value = parsed
  
  return lit


proc parsePrefixExpression(p: Parser): ast.Expression =
  var expression = ast.PrefixExpression(
    Token :   p.curToken,
    Operator: p.curToken.Literal 
  )

  p.nextToken()

  expression.Right = p.parseExpression(PREFIX)

  return expression

# Q : Why doe we assume that the left is already parsed?
# A : Read parseExpression
# Q : Where is this function called?
# A : It is bound by the Parser.registerInfix function.
proc parseInfixExpression(p: Parser, left: ast.Expression): ast.Expression =
  var expression = ast.InfixExpression(
    Token: p.curToken,
    Operator: p.curToken.Literal,
    Left: left
  )

  var precedence = p.curPrecedence
  p.nextToken()
  expression.Right = p.parseExpression(precedence)

  return expression


proc parseBoolean(p: Parser): ast.Expression =
  return ast.Boolean(Token: p.curToken, Value: p.curTokenIs(token.TRUE))

proc parseGroupedExpression(p: Parser): ast.Expression =

  p.nextToken()

  var exp = p.parseExpression(LOWEST)

  if not p.expectPeek(token.RPAREN):
      return nil
  
  return exp


proc parseIfExpression(p:Parser): ast.Expression =

  var expression = ast.IfExpression(Token : p.curToken)

  if not p.expectPeek(token.LPAREN):
    return nil
  
  p.nextToken()

  expression.Condition = p.parseExpression(LOWEST)

  if not p.expectPeek(token.RPAREN):
    return nil
  
  if not p.expectPeek(token.LBRACE):
    return nil

  expression.Consequence = p.parseBlockStatement()

  if p.peekTokenIs(token.ELSE):
    p.nextToken()

    if not p.expectPeek(token.LBRACE):
      return nil

    expression.Alternative = p.parseBlockStatement()
  
  return expression


proc parseBlockStatement(p: Parser): ast.BlockStatement = 
    
  var b = ast.BlockStatement(Token: p.curToken,
    Statements : newSeq[ast.Statement]())

  p.nextToken()

  while not p.curTokenIs(token.RBRACE) and not p.curTokenIs(token.EOF):
      
    var stmt = p.parseStatement()

    if stmt != nil:
      b.Statements.add(stmt)
    
    p.nextToken()

  return b

proc parseFunctionLiteral(p: Parser): ast.Expression =

  var lit = ast.FunctionLiteral(Token : p.curToken)

  if not p.expectPeek(token.LPAREN):
    return nil

  lit.Parameters = p.parseFunctionParameters()

  if not p.expectPeek(token.LBRACE):
    return nil

  lit.Body = p.parseBlockStatement()

  return lit

proc parseFunctionParameters(p: Parser): seq[ast.Identifier] =

  var identifiers = newSeq[ast.Identifier]()

  if p.peekTokenIs(token.RPAREN):
    p.nextToken()
    return identifiers

  p.nextToken()

  var ident = ast.Identifier(Token: p.curToken, Value: p.curToken.Literal)
  identifiers.add(ident)

  while p.peekTokenIs(token.COMMA):
    p.nextToken()
    p.nextToken()

    ident = ast.Identifier(Token: p.curToken, Value: p.curToken.Literal)
    identifiers.add(ident)

  
  if not p.expectPeek(token.RPAREN):
    #return nil
    return newSeq[Identifier]()
    
  return identifiers

proc parseCallExpression(p: Parser, function : ast.Expression): ast.Expression =
  var exp = ast.CallExpression(Token: p.curToken, Function: function)
  exp.Arguments = p.parseCallArguments()
  return exp


proc parseCallArguments(p: Parser): seq[ast.Expression] =

  var args = newSeq[ast.Expression]()

  if p.peekTokenIs(token.RPAREN):
    p.nextToken()
    return args

  p.nextToken()
  args.add(p.parseExpression(LOWEST))

  while p.peekTokenIs(token.COMMA):
    p.nextToken()
    p.nextToken()

    args.add(p.parseExpression(LOWEST))
  
  if not p.expectPeek(token.RPAREN):
    #return nil
    return newSeq[ast.Expression]()
  
  return args


func registerPrefix(p: Parser, tokenType: token.TokenType, fn: prefixParseFn): void =
  p.prefixParseFns[tokenType] = fn


func registerInfix(p: Parser, tokenType: token.TokenType, fn: infixParseFn): void =
  p.infixParseFns[tokenType] = fn

