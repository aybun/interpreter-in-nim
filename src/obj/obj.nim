
import ast/[ast]

import strformat

type ObjType string

const
   	NULL_OBJ  = "NULL"
	ERROR_OBJ = "ERROR"

	INTEGER_OBJ = "INTEGER"
	BOOLEAN_OBJ = "BOOLEAN"

	RETURN_VALUE_OBJ = "RETURN_VALUE"

	FUNCTION_OBJ = "FUNCTION"
 

type
    Obj* = ref object of RootObj

proc Type(obj: Obj): ObjType = 
    ""

proc Inspect(obj: Obj): ObjType = 
    ""

# Integer
type
    Integer = ref object of Obj
        Value : int64

proc Type(integer: Integer): ObjType =
    return INTEGER_OBJ

proc Inspect(integer: Integer): string =
    return &"{integer.Value}"

# Boolean
type 
    Boolean = ref object of Obj
        Value : bool
    
proc Type(boolean: Boolean): ObjType = 
    return BOOLEAN_OBJ

proc Inspect(boolean: Boolean) string =
    return &"{boolean.Value}"

# Null
type
    Null = ref object of Obj

proc Type(n: Null): ObjType = return NULL_OBJ
proc Inspect(n: Null): string = return "null"


# ReturnValue
type
    ReturnValue = ref object of Obj
        Value : Obj

proc Type(rv: ReturnValue): ObjType = return RETURN_VALUE_OBJ
proc Inspect(rv: ReturnValue): string = return rv.Value.Inspect()

# Error
type
    Error = ref object of Obj
        Message : string 

proc Type(e: Error): ObjType = return ERROR_OBJ
proc Instpect(e: Errof): string = return "ERROR: " + e.Message 

import obj/environment # Very Strange!!!

type
    Function = ref object of Obj
        Parameters : seq[ast.Identifier]
        Body :          ast.BlockStatement
        Env   :      Environment


proc Type(f : Function): ObjType = return FUNCTION_OBJ
proc Inspect(f : Function): string = 

    var ss = newStringStream()
    var params = newSeq[string](len(f.Parameters))
    
    for i in 0..(len(f.Parameters) - 1): # 0..10 -> 0, 1, ..., 9, 10 not 0, 1, .., 9 
        params[i] = f.Parameters[i]
    
    ss.write("fn")
    ss.write("(")
    ss.write( join(params, ", ")
    ss.write(") {\n")
    ss.write(f.Body.String())
    ss.write("\n")

    let out_str = ss.readAll()
    ss.close()

    return out_str
    





