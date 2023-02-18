type UtliemCli* = object
  help: string
  name: string


proc newUtliemCli*(help: string, name: string): UtliemCli =
  result.help = help
  result.name = name
