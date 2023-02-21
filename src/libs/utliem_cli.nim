import
  os


type UtliemCli = object
  appDirectoryPath: string

type UcImages = object
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

proc images*(uc: ref UtliemCli): UcImages =
  result.utliemCli = uc
  result.imagesDirPath = uc.appDirectoryPath / "images"

proc list*(i: UcImages): seq[string] =
  for fd in i.imagesDirPath.listDirectories:
    result.add(fd.splitPath.tail)

proc delete*(i: UcImages, name: string) =
  discard
