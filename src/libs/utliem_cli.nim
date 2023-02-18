type UtliemCli* = object
  appDirectoryPath: string

type UcImage = object
  discard

type UcContainer = object
  discard


proc newUtliemCli*(appDirectoryPath: string): UtliemCli =
  result.appDirectoryPath = appDirectoryPath

proc image*(uc: UtliemCli): UcImage =
  discard

proc list*(i: UcImage): seq[string] =
  @["foo", "bar"]

proc delete*(i: UcImage, name: string) =
  discard
