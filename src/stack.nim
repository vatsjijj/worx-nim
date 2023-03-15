type Stack* = object
  content*: seq[(float64, string)]

proc push*(self: var Stack, item: (float64, string)) =
  self.content.add(item)

proc push*(self: var Stack, item: float64) =
  self.content.add((item, ""))

proc push*(self: var Stack, item: string) =
  self.content.add((0.0, item))

proc push*(self: var Stack, item: int) =
  self.content.add((float64(item), ""))

proc push*(self: var Stack, item: int64) =
  self.content.add((float64(item), ""))

proc pop*(self: var Stack): (float64, string) =
  return self.content.pop()

proc popFloat*(self: var Stack): float64 =
  return self.pop()[0]

proc popString*(self: var Stack): string =
  let a: (float64, string) = self.pop()
  return if a[1] == "": $a[0] else: a[1]

proc popInt*(self: var Stack): int =
  return int(self.popFloat())

proc popI64*(self: var Stack): int64 =
  return int64(self.popFloat())