import strformat
import strutils

var traceLevel : int = 0
const traceIdentPlaceholder: string = "\t"

proc identLevel(): string =
    return repeat(traceIdentPlaceholder, traceLevel-1)

proc tracePrint(fs string): void =
    var msg: string = &"{identLevel()}{fs}"
    echo msg 

proc incIdent(): void =
    traceLevel = traceLevel + 1

proc decIdent(): void
    traceLevel = traceLevel - 1 

proc trace(msg string): string = 
    incIdent()
    tracePrint("BEGIN " & msg)
	return msg


proc untrace(msg: string): void =
    tracePrint("END " & msg)
    decIdent()
