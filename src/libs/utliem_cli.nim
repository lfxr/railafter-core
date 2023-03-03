import
  os,
  strformat

import
  templates,
  types,
  yaml_file


type UtliemCli = object
  appDirPath: string

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


proc newUtliemCli*(appDirPath: string): ref UtliemCli =
  result = new UtliemCli
  result.appDirPath = appDirPath

proc listDirectories(dirPath: string): seq[string] =
  for fileOrDir in walkDir(dirPath):
    result.add(fileOrDir.path)

proc images*(uc: ref UtliemCli): UcImages =
  result.utliemCli = uc
  result.imagesDirPath = uc.appDirPath / "images"

proc list*(ucImages: UcImages): seq[string] =
  for fileOrDir in ucImages.imagesDirPath.listDirectories:
    result.add(fileOrDir.splitPath.tail)

proc create*(ucImages: UcImages, imageName: string) =
  let newImageDirPath = ucImages.imagesDirPath / imageName
  if dirExists(newImageDirPath):
    raise newException(ValueError, fmt"Image named '{imageName}' already exists")
  createDir newImageDirPath
  let
    newImageFilePath = newImageDirPath / "image.aviutliem.yaml"
    imageYamlFile = ImageYamlFile(filePath: newImageFilePath)
  discard imageYamlFile.update(yamlTemplates.imageYaml)


proc delete*(ucImages: UcImages, name: string) =
  discard

proc image*(uc: ref UtliemCli, imageName: string): UcImage =
  result.utliemCli = uc
  result.imageDirPath = uc.appDirPath / "images" / imageName
  result.imageFileName = "image.aviutliem.yaml"
  result.imageFilePath = result.imageDirPath / result.imageFileName

proc plugins*(ucImage: UcImage): UcPlugins =
  result.ucImage = ucImage

proc list*(ucPlugins: UcPlugins): seq[Plugin] =
  let
    imageYamlFile = ImageYamlFile(filePath: ucPlugins.ucImage.imageFilePath)
    imageYaml = imageYamlFile.load()
  return imageYaml.plugins

proc add*(ucPlugins: UcPlugins, plugin: Plugin) =
  let imageYamlFile = ImageYamlFile(filePath: ucPlugins.ucImage.imageFilePath)
  var imageYaml = imageYamlFile.load()
  imageYaml.plugins.add(plugin)
  discard imageYamlFile.update(imageYaml)

proc delete*(ucPlugins: UcPlugins, pluginId: string) =
  let imageYamlFile = ImageYamlFile(filePath: ucPlugins.ucImage.imageFilePath)
  var imageYaml = imageYamlFile.load()

  var remainedPlugins: seq[Plugin] = @[]
  for i, plugin in imageYaml.plugins:
    if plugin.id != pluginId:
      remainedPlugins.add(plugin)

  imageYaml.plugins = remainedPlugins

  discard imageYamlFile.update(imageYaml)
