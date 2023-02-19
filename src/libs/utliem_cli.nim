import
  os


type UtliemCli = object
  appDirectoryPath: string

type UcImage = object
  utliemCli: ref UtliemCli
  imagesDirPath: string

type UcContainer = object
  discard


proc newUtliemCli*(appDirectoryPath: string): ref UtliemCli =
  result = new UtliemCli
  result.appDirectoryPath = appDirectoryPath

proc listDirectories(dirPath: string): seq[string] =
  for fd in walkDir(dirPath):
    result.add(fd.path)

proc image*(uc: ref UtliemCli): UcImage =
  result.utliemCli = uc
  result.imagesDirPath = uc.appDirectoryPath / "images"

proc list*(i: UcImage): seq[string] =
  i.imagesDirPath.listDirectories

proc delete*(i: UcImage, name: string) =
  discard
