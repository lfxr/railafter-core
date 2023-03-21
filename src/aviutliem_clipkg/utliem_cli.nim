import
  browsers,
  os,
  osproc,
  strformat

import
  errors,
  packages,
  procs,
  templates,
  types,
  yaml_file

import
  zippy/ziparchives


type UtliemCli = object
  appDirPath: string
  tempDirPath: string
  packages: ref Packages

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

type UcPackages = object
  utliemCli: ref UtliemCli

type UcPackagesPlugins = object
  ucPackages: UcPackages


proc newUtliemCli*(appDirPath: string): ref UtliemCli =
  result = new UtliemCli
  result.appDirPath = appDirPath
  result.tempDirPath = appDirPath / "temp"
  result.packages = newPackages(appDirPath / "packages.yaml")

proc listDirs(dirPath: string): seq[string] =
  ## 指定されたディレクトリ下のサブディレクトリのパスを返す
  for fileOrDir in walkDir(dirPath):
    result.add(fileOrDir.path)

func images*(uc: ref UtliemCli): UcImages =
  ## imagesコマンド
  result.utliemCli = uc
  result.imagesDirPath = uc.appDirPath / "images"

proc list*(ucImages: UcImages): seq[string] =
  ## イメージ一覧を返す
  for fileOrDir in ucImages.imagesDirPath.listDirs:
    result.add(fileOrDir.splitPath.tail)

proc create*(ucImages: UcImages, imageName: string) =
  ## イメージを作成する
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
  ## イメージを削除する
  let
    sanitizedImageName = imageName.sanitizeFileOrDirName
    targetImageDirPath = ucImages.imagesDirPath / sanitizedImageName
  try:
    removeDir(targetImageDirPath, checkDir = true)
  except OSError:
    raise newException(ValueError, fmt"Image named '{sanitizedImageName}' does not exist")


func image*(uc: ref UtliemCli, imageName: string): UcImage =
  ## imageコマンド
  result.utliemCli = uc
  result.imageDirPath = uc.appDirPath / "images" / imageName
  result.imageFileName = "image.aviutliem.yaml"
  result.imageFilePath = result.imageDirPath / result.imageFileName

func plugins*(ucImage: UcImage): UcPlugins =
  ## image.pluginsコマンド
  result.ucImage = ucImage

proc list*(ucPlugins: UcPlugins): seq[Plugin] =
  ## イメージ内のプラグイン一覧を返す
  let
    imageYamlFile = ImageYamlFile(filePath: ucPlugins.ucImage.imageFilePath)
    imageYaml = imageYamlFile.load()
  return imageYaml.plugins

proc add*(ucPlugins: UcPlugins, plugin: Plugin) =
  ## プラグインを追加する
  let imageYamlFile = ImageYamlFile(filePath: ucPlugins.ucImage.imageFilePath)
  var imageYaml = imageYamlFile.load()
  imageYaml.plugins.add(plugin)
  discard imageYamlFile.update(imageYaml)

proc delete*(ucPlugins: UcPlugins, pluginId: string) =
  ## プラグインを削除する
  let imageYamlFile = ImageYamlFile(filePath: ucPlugins.ucImage.imageFilePath)
  var imageYaml = imageYamlFile.load()

  var remainedPlugins: seq[Plugin] = @[]
  for i, plugin in imageYaml.plugins:
    if plugin.id != pluginId:
      remainedPlugins.add(plugin)

  imageYaml.plugins = remainedPlugins

  discard imageYamlFile.update(imageYaml)


func containers*(uc: ref UtliemCli): UcContainers =
  ## containersコマンド
  result.utliemCli = uc
  result.containersDirPath = uc.appDirPath / "containers"

proc list*(ucContainers: UcContainers): seq[string] =
  ## コンテナ一覧を返す
  for fileOrDir in ucContainers.containersDirPath.listDirs:
    result.add(fileOrDir.splitPath.tail)

proc create*(ucContainers: UcContainers, containerName: string,
    imageName: string) =
  ## コンテナを作成する
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
  ## コンテナを削除する
  let
    sanitizedContainerName = containerName.sanitizeFileOrDirName
    targetContainerDirPath = ucContainers.containersDirPath / sanitizedContainerName
  try:
    removeDir(targetContainerDirPath, checkDir = true)
  except OSError:
    raise newException(ValueError, fmt"Container named '{sanitizedContainerName}' does not exist")


func container*(uc: ref UtliemCli, containerName: string): UcContainer =
  ## containerコマンド
  result.utliemCli = uc
  result.tempDirPath = uc.tempDirPath / "container"
  result.containerDirPath = uc.appDirPath / "containers" / containerName
  result.containerFileName = "container.aviutliem.yaml"
  result.containerFilePath = result.containerDirPath / result.containerFileName
  result.aviutlDirPath = result.containerDirPath / "aviutl"

func plugins*(ucContainer: UcContainer): UcContainerPlugins =
  ## container.pluginsコマンド
  result.ucContainer = ucContainer
  result.dirPath = ucContainer.aviutlDirPath / "plugins"
  result.tempDirPath = ucContainer.tempDirPath / "plugins"
  result.tempSrcDirPath = result.tempDirPath / "src"
  result.tempDestDirPath = result.tempDirPath / "dest"

proc download*(ucContainerPlugins: UcContainerPlugins, plugin: Plugin) =
  ## プラグインをダウンロードする
  # プラグインの配布ページをデフォルトブラウザで開く
  openDefaultBrowser("https://example.com")
  # tempSrcディレクトリをエクスプローラーで開く
  discard execProcess(
    "explorer",
    args = [ucContainerPlugins.tempSrcDirPath],
    options = {poUsePath}
  )

proc install*(ucContainerPlugins: UcContainerPlugins, plugin: Plugin) =
  ## プラグインをインストールする
  let
    packages = ucContainerPlugins.ucContainer.utliemCli.packages
    tempSrcDirPath = ucContainerPlugins.tempSrcDirPath
    tempDestDirPath = ucContainerPlugins.tempDestDirPath
    pluginZipFilePath = listDirs(tempSrcDirPath)[0]
    pluginZipSha3_512Hash = sha3_512File(pluginZipFilePath)
    correctPluginZipSha3_512Hash =
      packages.plugin(plugin.id).version(plugin.version).sha3_512_hash
    containerPluginsDirPath = ucContainerPlugins.dirPath
  # ダウンロードしたzipファイルのハッシュ値を検証
  if pluginZipSha3_512Hash != correctPluginZipSha3_512Hash:
    invalidZipFileHashValue(pluginZipFilePath.absolutePath)
  # プラグインのzipファイルを解凍
  extractAll(pluginZipFilePath, tempDestDirPath)
  # コンテナのaviutl/pluginsディレクトリに解凍されたファイルを移動
  for file in walkDirRec(tempDestDirPath):
    moveFile(file, containerPluginsDirPath / file.splitPath.tail)
  # 解凍されたファイルが存在していたディレクトリを削除
  removeDir(tempDestDirPath, checkDir = true)
  removeFile pluginZipFilePath


func packages*(uc: ref UtliemCli): UcPackages =
  ## packagesコマンド
  result.utliemCli = uc

func plugins*(ucPackages: UcPackages): UcPackagesPlugins =
  ## packages.pluginsコマンド
  result.ucPackages = ucPackages

func list*(ucPackagesPlugins: UcPackagesPlugins): seq[PackagesYamlPlugin] =
  ## 入手可能なパッケージ一覧を返す
  ucPackagesPlugins.ucPackages.utliemCli.packages.plugins.list

func find*(ucPackagesPlugins: UcPackagesPlugins, query: string): seq[
    PackagesYamlPlugin] =
  ## 入手可能なパッケージを検索する
  ucPackagesPlugins.ucPackages.utliemCli.packages.plugins.find(query)
