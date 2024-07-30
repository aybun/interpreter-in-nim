import std/tables


const
  ILLEGAL* = "ILLEGAL"
  EOF*     = "EOF"

# Identifiers + literals
  IDENT* = "IDENT" # add, foobar, x, y, ...
  INT*   = "INT"   # 1343456

# Operators
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
  "false" : FALSE,
  "true" : TRUE,
  "false" : FALSE,
  "IF" : IF,
  "else" : ELSE,
  "return" : RETURN,
}.toTable()


proc LookUpIdent(ident :string) =
  let res_string = keywords.getOrDefault(iden, nil)
  if res_string != nil:
    return res_string
  else:
    return ident






