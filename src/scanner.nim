import std/strutils

var location: int = 0

proc inBounds(src: string): bool =
  return location < src.len - 1

proc comment(src: string) =
  inc location
  while src[location] != ')' and src.inBounds():
    inc location
  inc location

proc whitespace(src: string) =
  while ($src[location]).isEmptyOrWhitespace() and src.inBounds():
    inc location

proc word(src: string): string =
  var res: string
  while (not ($src[location]).isEmptyOrWhitespace()) and src.inBounds():
    res.add(src[location])
    inc location
  return res

proc str(src: string): string =
  var res: string
  inc location
  while src[location] != '"' and src.inBounds():
    res.add(src[location])
    inc location
  inc location
  return res

proc scan*(src: var string): seq[string] =
  var
    res: seq[string]
  src.add(' ')
  src.add('\0')
  while src.inBounds():
    if src[location] == '(':
      src.comment()
    elif src[location] == '"':
      res.add(src.str())
    elif not ($src[location]).isEmptyOrWhitespace():
      res.add(src.word())
    else:
      src.whitespace()
  location = 0
  return res