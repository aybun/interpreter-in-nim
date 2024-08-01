
import strutils
import strformat

import lexer/lexer
import token/token

proc printf(formatstr: cstring) {.importc: "printf", varargs, header: "<stdio.h".}
const PROMPT = ">> "

proc Start(): void =
  while true:

    var line :string
    let ok =  readLineFromStdin(PROMPT, line)
    if not ok:
      break

    l = lexer.New(line)

    while true:
      let tok = l.NextToken()
      if tok == token.EOF:
        break

      printf("%+v\n", tok)

      tok = l.NextToken()

  return


