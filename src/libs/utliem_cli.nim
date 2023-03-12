import
  browsers,
  os,
  osproc,
  strformat

import
  procs,
  templates,
  types,
  yaml_file

import
  zippy/ziparchives


type UtliemCli = object
  appDirPath: string
  tempDirPath: string

type UcImages = object
  utliemCli: ref UtliemCli
  imagesDirPath: string

type UcImage = object
  utliemCli: ref UtliemCli
  imageDirPath: string
  imageFileName: string
  imageFilePath: string

type UcContainers = object
  utliemCli: ref UtliemCli
  containersDirPath: string

type UcPlugins = object
  ucImage: UcImage

type UcContainer = object
  utliemCli: ref UtliemCli
  tempDirPath: string
  containerDirPath: string
  containerFileName: string
  containerFilePath: string
  aviutlDirPath: string

type UcContainerPlugins = object
  ucContainer: UcContainer
  dirPath: string
  tempDirPath: string
  tempSrcDirPath: string
  tempDestDirPath: string


proc newUtliemCli*(appDirPath: string): ref UtliemCli =
  result = new UtliemCli
  result.appDirPath = appDirPath
  result.tempDirPath = appDirPath / "temp"

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
  let
    sanitizedImageName = imageName.sanitizeFileOrDirName
    newImageDirPath = ucImages.imagesDirPath / sanitizedImageName
  if dirExists(newImageDirPath):
    raise newException(ValueError, fmt"Image named '{sanitizedImageName}' already exists")
  createDir newImageDirPath
  let
    newImageFilePath = newImageDirPath / "image.aviutliem.yaml"
    imageYamlFile = ImageYamlFile(filePath: newImageFilePath)
  discard imageYamlFile.update(yamlTemplates.imageYaml)

proc delete*(ucImages: UcImages, imageName: string) =
  let
    sanitizedImageName = imageName.sanitizeFileOrDirName
    targetImageDirPath = ucImages.imagesDirPath / sanitizedImageName
  try:
    removeDir(targetImageDirPath, checkDir = true)
  except OSError:
    raise newException(ValueError, fmt"Image named '{sanitizedImageName}' does not exist")


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


proc containers*(uc: ref UtliemCli): UcContainers =
  result.utliemCli = uc
  result.containersDirPath = uc.appDirPath / "containers"

proc list*(ucContainers: UcContainers): seq[string] =
  for fileOrDir in ucContainers.containersDirPath.listDirectories:
    result.add(fileOrDir.splitPath.tail)

proc create*(ucContainers: UcContainers, containerName: string,
    imageName: string) =
  let
    sanitizedContainerName = containerName.sanitizeFileOrDirName
    newContainerDirPath = ucContainers.containersDirPath / sanitizedContainerName
  if dirExists(newContainerDirPath):
    raise newException(ValueError, fmt"Container named '{sanitizedContainerName}' already exists")
  createDir newContainerDirPath
  # 対象イメージをイメージファイルから読み込む
  let
    image = ucContainers.utliemCli.image(imageName)
    imageYamlFile = ImageYamlFile(filePath: image.imageFilePath)
    imageYaml = imageYamlFile.load()
    containerYaml = ContainerYaml(
      container_name: containerName,
      base: imageYaml.base,
      plugins: ContainerPlugins(enabled: imageYaml.plugins),
      scripts: ContainerScripts(enabled: imageYaml.scripts),
    )
  # コンテナファイルを作成
  let
    newContainerFilePath = newContainerDirPath / "container.aviutliem.yaml"
    containerYamlFile = ContainerYamlFile(filePath: newContainerFilePath)
  discard containerYamlFile.update(containerYaml)

proc delete*(ucContainers: UcContainers, containerName: string) =
  let
    sanitizedContainerName = containerName.sanitizeFileOrDirName
    targetContainerDirPath = ucContainers.containersDirPath / sanitizedContainerName
  try:
    removeDir(targetContainerDirPath, checkDir = true)
  except OSError:
    raise newException(ValueError, fmt"Container named '{sanitizedContainerName}' does not exist")


proc container*(uc: ref UtliemCli, containerName: string): UcContainer =
  result.utliemCli = uc
  result.tempDirPath = uc.tempDirPath / "container"
  result.containerDirPath = uc.appDirPath / "containers" / containerName
  result.containerFileName = "container.aviutliem.yaml"
  result.containerFilePath = result.containerDirPath / result.containerFileName
  result.aviutlDirPath = result.containerDirPath / "aviutl"

proc plugins*(ucContainer: UcContainer): UcContainerPlugins =
  result.ucContainer = ucContainer
  result.dirPath = ucContainer.aviutlDirPath / "plugins"
  result.tempDirPath = ucContainer.tempDirPath / "plugins"
  result.tempSrcDirPath = result.tempDirPath / "src"
  result.tempDestDirPath = result.tempDirPath / "dest"

proc download*(ucContainerPlugins: UcContainerPlugins, plugin: Plugin) =
  # プラグインの配布ページをデフォルトブラウザで開く
  openDefaultBrowser("https://example.com")
  # tempSrcディレクトリをエクスプローラーで開く
  discard execProcess(
    "explorer",
    args = [ucContainerPlugins.tempSrcDirPath],
    options = {poUsePath}
  )

proc install*(ucContainerPlugins: UcContainerPlugins, plugin: Plugin) =
  let
    tempSrcDirPath = ucContainerPlugins.tempSrcDirPath
    tempDestDirPath = ucContainerPlugins.tempDestDirPath
    pluginZipFilePath = listDirectories(tempSrcDirPath)[0]
    containerPluginsDirPath = ucContainerPlugins.dirPath
  # プラグインのzipファイルを解凍
  extractAll(pluginZipFilePath, tempDestDirPath)
  # コンテナのaviutl/pluginsディレクトリに解凍されたファイルを移動
  for file in walkDirRec(tempDestDirPath):
    moveFile(file, containerPluginsDirPath / file.splitPath.tail)
  # 解凍されたファイルが存在していたディレクトリを削除
  removeDir(tempDestDirPath, checkDir = true)
  removeFile pluginZipFilePath
