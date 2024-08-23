import std/tables


const
  ILLEGAL* = "ILLEGAL"
  EOF*     = "EOF"

# Identifiers + literals
  IDENT* = "IDENT" # add, foobar, x, y, ...
  INT*   = "INT"   # 1343456

# Operators
  ASSIGN* = "="
  PLUS*     = "+"
  MINUS*    = "-"
  BANG*   = "!"
  ASTERISK* = "*"
  SLASH*    = "/"

  LT* = "<"
  GT* = ">"

  EQ*     = "=="
  NOT_EQ* = "!="

#	 Delimiters
  COMMA*     = ","
  SEMICOLON* = ";"

  LPAREN* = "("
  RPAREN* = ")"
  LBRACE* = "{"
  RBRACE* = "}"

#	 Keywords
  FUNCTION* = "FUNCTION"
  LET*      = "LET"
  TRUE*     = "TRUE"
  FALSE*    = "FALSE"
  IF*       = "IF"
  ELSE*     = "ELSE"
  RETURN*   = "RETURN"


# Tokens
type TokenType* = string

type
  Token* = object
    Type*: TokenType
    Literal*: string

var keywords = {
  "fn" : FUNCTION,
  "let" : LET,
  "true" : TRUE,
  "false" : FALSE,
  "if" : IF,
  "else" : ELSE,
  "return" : RETURN,
}.toTable()


proc LookupIdent*(ident :string):  TokenType=
  let res_string = keywords.getOrDefault(ident, "-")
  if res_string != "-":
    return res_string
  else:
    return IDENT





