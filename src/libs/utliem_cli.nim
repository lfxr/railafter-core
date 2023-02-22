import
  os,
  streams

import
  yaml/serialization

import
  types


type UtliemCli = object
  appDirectoryPath: string

type UcImages = object
  utliemCli: ref UtliemCli
  imagesDirPath: string

type UcImage = object
  utliemCli: ref UtliemCli
  imageDirPath: string

type UcPlugins = object
  ucImage: UcImage

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

proc image*(uc: ref UtliemCli, imageName: string): UcImage =
  result.utliemCli = uc
  result.imageDirPath = uc.appDirectoryPath / "images" / imageName

proc plugins*(i: UcImage): UcPlugins =
  result.ucImage = i

proc list*(p: UcPlugins): seq[Plugin] =
  var imageYaml: ImageYaml
  var s = newFileStream(p.ucImage.imageDirPath / "image.aviutliem.yaml")
  # echo s.readAll
  s.load(imageYaml)
  s.close
  return imageYaml.plugins
