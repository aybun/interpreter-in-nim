
import token/token
#import unicode
import strutils

type
  Lexer = object
    input : string
    position : int
    readPosition : int
    ch : byte

proc New(input :string): (ptr Lexer) =
  var l: Lexer
  l.input = input
  return addr(l)


proc nextToken(l :Lexer): token.Token =
  var tok : token.Token
  l.skipWhitespace()

  case l.ch:
    of '=':
      if l.peekChar() == '=':
        let ch = l.ch
        l.readChar()
        let literal = string(ch) + string(l.ch)
        tok.Type = token.EQ
        tok.Literal = literal
      else:
        tok = newToken(token.ASSIGN, l.ch)
    of '+':
      tok = newToken(token.PLUS, l.ch)
    of '-':
      tok = newToken(token.MINUS)
	  of '!':
      if l.peekChar() == '=':
			  ch := l.ch
			  l.readChar()
			  literal := string(ch) + string(l.ch)
			  tok = token.Token{Type: token.NOT_EQ, Literal: literal}
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
	  of 0:
	    tok = newTOken(toke.EOF, "")
		  #tok.Literal = ""
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

proc skilWhitespace(l :Lexer): void =
  while l.ch == ' ' or l.ch == '\t' or l.ch == '\n' or l.ch == '\r':
		l.readChar()

proc readchar(l :Lexer): void =
	if l.readPosition >= len(l.input):
		l.ch = 0
	else:
    l.ch = l.input[l.readPosition]
    l.position = l.readPosition
    l.readPosition += 1


proc peekChar(l :Lexer): byte =
	if l.readPosition >= len(l.input):
		return 0
	else:
		return l.input[l.readPosition]

proc readIdentifier(l :Lexer): string =
  let position = l.position
  while isLetter(l.ch):
    l.readChar()
  return l.input[position:l.position]


proc readNumber(l :Lexer): string =
  let position = l.position
  while isDigit(l.ch):
		l.readChar()
  return l.input[position:l.position]

proc isLetter(ch :byte): bool =
	return 'a' <= ch && ch <= 'z' || 'A' <= ch && ch <= 'Z' || ch == '_'


proc isDigit(ch :byte): bool =
	return '0' <= ch && ch <= '9'


proc newToken(tokenType :token.TokenType, ch :byte): token.Token =
	return token.Token{Type: tokenType, Literal: string(ch)}



