import
  os

import
  types,
  yaml_file


type UtliemCli = object
  appDirectoryPath: string

type UcImages = object
  utliemCli: ref UtliemCli
  imagesDirPath: string

type UcImage = object
  utliemCli: ref UtliemCli
  imageDirPath: string
  imageFileName: string
  imageFilePath: string

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
  result.imageFileName = "image.aviutliem.yaml"
  result.imageFilePath = result.imageDirPath / result.imageFileName

proc plugins*(i: UcImage): UcPlugins =
  result.ucImage = i

proc list*(p: UcPlugins): seq[Plugin] =
  let
    imageYamlFile = ImageYamlFile(filePath: p.ucImage.imageFilePath)
    imageYaml = imageYamlFile.load()
  return imageYaml.plugins

proc add*(p: UcPlugins, plugin: Plugin) =
  let imageYamlFile = ImageYamlFile(filePath: p.ucImage.imageFilePath)
  var imageYaml = imageYamlFile.load()
  imageYaml.plugins.add(plugin)
  discard imageYamlFile.update(imageYaml)

proc delete*(p: UcPlugins, pluginId: string) =
  let imageYamlFile = ImageYamlFile(filePath: p.ucImage.imageFilePath)
  var imageYaml = imageYamlFile.load()

  var remainedPlugins: seq[Plugin] = @[]
  for i, plugin in imageYaml.plugins:
    if plugin.id != pluginId:
      remainedPlugins.add(plugin)

  imageYaml.plugins = remainedPlugins

  discard imageYamlFile.update(imageYaml)
