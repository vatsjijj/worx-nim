import std/[strutils, tables], scanner, stack

var
  toks: seq[string]
  tok: string
  loc: int = 0
  ds, rs: Stack = Stack(content: @[])
  vars: Table[string, (float64, string)] = initTable[string, (float64, string)]()
  botLim, topLim: array[512, int]
  jmp: seq[int] = @[]
  jmpCount, level: int = 0
  beginWord, endWord: int = -1
  words: Table[string, array[2, int]] = initTable[string, array[2, int]]()

proc setToks*(src: var string) =
  toks = scan(src)
  tok = toks[0]

proc adv() =
  inc loc
  if loc > toks.len - 1:
    return
  tok = toks[loc]

proc setVar(name: string, val: (float64, string)) =
  vars[name] = val

proc delVar(name: string) =
  vars.del(name)

proc getVar(name: string) =
  ds.push(vars[name])

proc add() =
  let
    a: int = ds.popInt()
    b: int = ds.popInt()
  ds.push(b + a)

proc sub() =
  let
    a: int = ds.popInt()
    b: int = ds.popInt()
  ds.push(b - a)

proc mul() =
  let
    a: int = ds.popInt()
    b: int = ds.popInt()
  ds.push(b * a)

proc divi() =
  let
    a: int = ds.popInt()
    b: int = ds.popInt()
  ds.push(b div a)

proc modu() =
  let
    a: int = ds.popInt()
    b: int = ds.popInt()
  ds.push(b mod a)

proc equ() =
  let
    a: int = ds.popInt()
    b: int = ds.popInt()
  ds.push(if b == a: 1 else: 0)

proc gt() =
  let
    a: int = ds.popInt()
    b: int = ds.popInt()
  ds.push(if b > a: 1 else: 0)

proc lt() =
  let
    a: int = ds.popInt()
    b: int = ds.popInt()
  ds.push(if b < a: 1 else: 0)

proc addl() =
  let
    a: int64 = ds.popI64()
    b: int64 = ds.popI64()
  ds.push(b + a)

proc subl() =
  let
    a: int64 = ds.popI64()
    b: int64 = ds.popI64()
  ds.push(b - a)

proc mull() =
  let
    a: int64 = ds.popI64()
    b: int64 = ds.popI64()
  ds.push(b * a)

proc divil() =
  let
    a: int64 = ds.popI64()
    b: int64 = ds.popI64()
  ds.push(b div a)

proc equl() =
  let
    a: int64 = ds.popI64()
    b: int64 = ds.popI64()
  ds.push(if b == a: 1 else: 0)

proc addd() =
  let
    a: float64 = ds.popFloat()
    b: float64 = ds.popFloat()
  ds.push(b + a)

proc subd() =
  let
    a: float64 = ds.popFloat()
    b: float64 = ds.popFloat()
  ds.push(b - a)

proc muld() =
  let
    a: float64 = ds.popFloat()
    b: float64 = ds.popFloat()
  ds.push(b * a)

proc divid() =
  let
    a: float64 = ds.popFloat()
    b: float64 = ds.popFloat()
  ds.push(b / a)

proc equd() =
  let
    a: float64 = ds.popFloat()
    b: float64 = ds.popFloat()
  ds.push(if b == a: 1 else: 0)

proc gtd() =
  let
    a: float64 = ds.popFloat()
    b: float64 = ds.popFloat()
  ds.push(if b > a: 1 else: 0)

proc ltd() =
  let
    a: float64 = ds.popFloat()
    b: float64 = ds.popFloat()
  ds.push(if b < a: 1 else: 0)

proc dup() =
  let a: (float64, string) = ds.pop()
  ds.push(a)
  ds.push(a)

proc swap() =
  let
    a: (float64, string) = ds.pop()
    b: (float64, string) = ds.pop()
  ds.push(a)
  ds.push(b)

proc drop() =
  discard ds.pop()

proc toR() =
  rs.push(ds.pop())

proc rFrom() =
  ds.push(rs.pop())

proc rFetch() =
  rFrom()
  dup()
  toR()

proc over() =
  toR()
  dup()
  rFrom()
  swap()

proc rot() =
  toR()
  swap()
  rFrom()
  swap()

proc print() =
  stdout.write(ds.popString())

proc printLn() =
  echo(ds.popString())

proc dumpDS() =
  ("DS: " & $ds.content).echo()

proc dumpRS() =
  ("RS: " & $rs.content).echo()

proc dumpVars() =
  ("VARS: " & $vars).echo()

proc variable() =
  vars[ds.popString()] = (0.0, "")

proc store() =
  vars[ds.popString()] = ds.pop()

proc fetch() =
  ds.push(vars[ds.popString()])

proc delVar() =
  vars.del(ds.popString())

proc jump(location: int) =
  if location >= toks.len:
    loc = location
    return
  loc = location
  tok = toks[loc]

proc cif() =
  inc jmpCount
  inc jmpCount
  inc jmpCount
  jmp.add(loc)
  jmp.add(-1)
  jmp.add(-1)
  while toks[loc] != "else":
    if toks[loc] == "then":
      jmp[jmpCount - 2] = -1
      jmp[jmpCount - 1] = loc
      break
    adv()
  if jmp[jmpCount - 1] == -1:
    jmp[jmpCount - 2] = loc
  while jmp[jmpCount - 2] != -1 and toks[loc] != "then":
    adv()
  if jmp[jmpCount - 2] != -1:
    jmp[jmpCount - 1] = loc
  setVar("[]ivif", ds.pop())
  getVar("[]ivif")
  if ds.popInt() == 1:
    jmp[jmpCount - 3].jump()
  elif jmp[jmpCount - 2] > -1:
    jmp[jmpCount - 2].jump()
  else:
    (jmp[jmpCount - 1] - 1).jump()

proc celse() =
  getVar("[]ivif")
  if (ds.popInt() == 1):
    (jmp[jmpCount - 1] - 1).jump()
  else:
    drop()
    delVar("[]ivif")

proc cdo() =
  inc level
  inc jmpCount
  botLim[level - 1] = 1
  topLim[level - 1] = ds.popInt()
  jmp.add(loc)

proc qmdo() =
  inc level
  inc jmpCount
  botLim[level - 1] = ds.popInt()
  topLim[level - 1] = ds.popInt()
  jmp.add(loc)

proc loop() =
  if topLim[level - 1] - 1 > botLim[level - 1]:
    inc botLim[level - 1]
    jmp[jmpCount - 1].jump()
    return
  dec level
  dec jmpCount
  discard jmp.pop()

proc colon() =
  let name: string = ds.popString()
  beginWord = loc + 1
  while toks[loc] != ";":
    adv()
  endWord = loc
  words[name] = [beginWord, endWord]

proc semicolon() =
  jmp[jmpCount - 1].jump()
  dec jmpCount
  discard jmp.pop()

proc run*() =
  while loc < toks.len:
    case tok:
      of "+": add()
      of "-": sub()
      of "*": mul()
      of "/": divi()
      of "f+": addd()
      of "f-": subd()
      of "f*": muld()
      of "f/": divid()
      of "l+": addl()
      of "l-": subl()
      of "l*": mull()
      of "l/": divil()
      of "l=": equl()
      of "%": modu()
      of "=": equ()
      of ">": gt()
      of "<": lt()
      of "f=": equd()
      of "f>": gtd()
      of "f<": ltd()
      of "dup": dup()
      of "swap": swap()
      of "drop": drop()
      of "over": over()
      of "rot": rot()
      of ">r": toR()
      of "r>": rFrom()
      of "r@": rFetch()
      of ".": print()
      of ".nl": printLn()
      of ".ds": dumpDS()
      of ".rs": dumpRS()
      of ".var": dumpVars()
      of "variable": variable()
      of "!": store()
      of "@": fetch()
      of "del": delVar()
      of "true": ds.push(1)
      of "false": ds.push(0)
      of "if": cif()
      of "else": celse()
      of "then":
        dec jmpCount
        dec jmpCount
        dec jmpCount
        discard jmp.pop()
        discard jmp.pop()
        discard jmp.pop()
        delVar("[]ivif")
      of "do": cdo()
      of "?do": qmdo()
      of "loop": loop()
      of "i": rs.push(botLim[level - 1])
      of ":": colon()
      of ";": semicolon()
      else:
        try:
          ds.push(tok.parseFloat())
        except CatchableError:
          if tok in words:
            inc jmpCount
            jmp.add(loc)
            (words[tok][0] - 1).jump()
          else:
            ds.push(tok)
    adv()