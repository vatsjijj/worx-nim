import std/os, runtime

when isMainModule:
  var src: string = readFile(commandLineParams()[0])
  src.setToks()
  run()