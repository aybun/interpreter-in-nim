
import token/[token]
import strutils

type
  Lexer* = object
    input : string
    position : int
    readPosition : int
    ch : byte

# Define before use.
proc peekChar(l : var Lexer): byte
proc newToken(tokenType :token.TokenType, ch :byte): token.Token
proc newToken(tokenType :TokenType, ch: char): Token #Refactor with template/macro
proc isLetter(b :byte): bool
proc isDigit(b :byte): bool
proc readChar(l : var Lexer): void
proc readIdentifier(l : var Lexer): string
proc readNumber(l : var Lexer): string

proc New*(input :string): Lexer =
  var l = Lexer(input: input)
  l.readChar()  # Why do I have to do this? To skip EOF?
  return l

proc readChar(l : var Lexer): void =
  if l.readPosition >= len(l.input):
    l.ch = 0
  else:
    l.ch = byte(l.input[l.readPosition])
  l.position = l.readPosition
  l.readPosition += 1

proc skipWhitespace(l : var Lexer): void =
  var ch_char = chr(l.ch)
  while (ch_char == ' ' or ch_char == '\t' or ch_char == '\n' or ch_char == '\r'):
    l.readChar()
    ch_char = chr(l.ch)

proc nextToken*(l : var Lexer): token.Token =
  var tok : token.Token
  l.skipWhitespace()

  case chr(l.ch):
    of '=':
      if chr(l.peekChar()) == '=':
        let ch = chr(l.ch)
        l.readChar()
        let literal = $ch & $chr(l.ch)
        tok.Type = token.EQ
        tok.Literal = literal
      else:
        tok = newToken(token.ASSIGN, l.ch)
    of '+':
      tok = newToken(token.PLUS, l.ch)
    of '-':
      tok = newToken(token.MINUS, l.ch)
    of '!':
      if chr(l.peekChar()) == '=':
        let ch = l.ch
        l.readChar()
        let literal = $chr(ch) & $chr(l.ch)
        tok = token.Token(Type: token.NOT_EQ, Literal: literal)
      else:
        tok = newToken(token.BANG, l.ch)
    of '/':
      tok = newToken(token.SLASH, l.ch)
    of '*':
      tok = newToken(token.ASTERISK, l.ch)
    of '<':
      tok = newToken(token.LT, l.ch)
    of '>':
      tok = newToken(token.GT, l.ch)
    of ';':
      tok = newToken(token.SEMICOLON, l.ch)
    of ',':
      tok = newToken(token.COMMA, l.ch)
    of '{':
      tok = newToken(token.LBRACE, l.ch)
    of '}':
      tok = newToken(token.RBRACE, l.ch)
    of '(':
      tok = newToken(token.LPAREN, l.ch)
    of ')':
      tok = newToken(token.RPAREN, l.ch)
    of chr(0):
      tok = newToken(token.EOF, byte(0))
      tok.Literal = ""
      #tok.Type = token.EOF
    else:
      if isLetter(l.ch):
        tok.Literal = l.readIdentifier()
        tok.Type = token.LookupIdent(tok.Literal)
        return tok
      elif isDigit(l.ch):
        tok.Type = token.INT
        tok.Literal = l.readNumber()
        return tok
      else:
        tok = newToken(token.ILLEGAL, l.ch)

  l.readChar()
  return tok

proc peekChar(l : var Lexer): byte =
  if l.readPosition >= len(l.input):
    return 0
  else:
    return byte(l.input[l.readPosition])

proc readIdentifier(l : var Lexer): string =
  let position = l.position
  while isLetter(l.ch):
    l.readChar()
  return l.input[position .. l.position-1]


proc readNumber(l : var Lexer): string =
  let position = l.position
  while isDigit(l.ch):
    l.readChar()
  return l.input[position .. l.position-1]

proc isLetter(b :byte): bool =
  let ch = chr(b)
  return 'a' <= ch and ch <= 'z' or 'A' <= ch and ch <= 'Z' or ch == '_'


proc isDigit(b :byte): bool =
  let ch = chr(b)
  return '0' <= ch and ch <= '9'


# Add multiple interfaces for newToken
proc newToken(tokenType :token.TokenType, ch :byte): token.Token =
  return token.Token(Type: tokenType, Literal: $chr(ch)) #byte -> char -> string

proc newToken(tokenType :TokenType, ch: char): Token =
  return Token(Type: tokenType, Literal: cast[string](ch))

