import obj/[obj] 


type 
    Environment* = ref object of RootObj
        store : Table[string, Obj]
        outer : Environment

proc Get(e : Environment, name: string): (Obj, bool) =
    var obj = e.store.getOrDefault(name, nil)
    if obj != nil:
        return (obj, true)
    elif e.outer != nil:
        return e.outer.Get(name)
    else:
        return (nil, false)

proc Set(e : Environment, name : string, val : Obj): Obj =
    e.store[name] = val
    return val