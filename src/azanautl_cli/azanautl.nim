import
  browsers,
  os,
  osproc,
  sequtils,
  strformat

import
  zippy/ziparchives

import
  errors,
  packages,
  procs,
  templates,
  types,
  yaml_file


type AzanaUtlCli = object
  appDirPath: string
  tempDirPath: string
  packages: ref Packages

type AucImages = object
  azanaUtlCli: ref AzanaUtlCli
  imagesDirPath: string

type AucImage = object
  azanaUtlCli: ref AzanaUtlCli
  imageDirPath: string
  imageFileName: string
  imageFilePath: string

type AucContainers = object
  azanaUtlCli: ref AzanaUtlCli
  containersDirPath: string

type AucPlugins = object
  aucImage: AucImage

type AucContainer = object
  azanaUtlCli: ref AzanaUtlCli
  tempDirPath: string
  containerDirPath: string
  containerFileName: string
  containerFilePath: string
  aviutlDirPath: string

type AucContainerPlugins = object
  aucContainer: AucContainer
  dirPath: string
  tempDirPath: string
  tempSrcDirPath: string
  tempDestDirPath: string

type AucContainerBases = object
  aucContainer: AucContainer
  dirPath: string
  tempDirPath: string
  tempSrcDirPath: string
  tempDestDirPath: string

type AucPackages = object
  azanaUtlCli: ref AzanaUtlCli

type AucPackagesBases = object
  aucPackages: AucPackages

type AucPackagesPlugins = object
  aucPackages: AucPackages


proc newAzanaUtlCli*(appDirPath: string): ref AzanaUtlCli =
  result = new AzanaUtlCli
  result.appDirPath = appDirPath
  result.tempDirPath = appDirPath / "temp"
  result.packages = newPackages(appDirPath / "packages.yaml")

proc listDirs(dirPath: string): seq[string] =
  ## 指定されたディレクトリ下のサブディレクトリのパスを返す
  for fileOrDir in walkDir(dirPath):
    result.add(fileOrDir.path)

func images*(auc: ref AzanaUtlCli): AucImages =
  ## imagesコマンド
  result.azanaUtlCli = auc
  result.imagesDirPath = auc.appDirPath / "images"

proc list*(aucImages: AucImages): seq[string] =
  ## イメージ一覧を返す
  for fileOrDir in aucImages.imagesDirPath.listDirs:
    result.add(fileOrDir.splitPath.tail)

proc create*(aucImages: AucImages, imageName: string) =
  ## イメージを作成する
  let
    sanitizedImageName = imageName.sanitizeFileOrDirName
    newImageDirPath = aucImages.imagesDirPath / sanitizedImageName
  if dirExists(newImageDirPath):
    raise newException(ValueError, fmt"Image named '{sanitizedImageName}' already exists")
  createDir newImageDirPath
  let
    newImageFilePath = newImageDirPath / "image.aviutliem.yaml"
    imageYamlFile = ImageYamlFile(filePath: newImageFilePath)
  discard imageYamlFile.update(yamlTemplates.imageYaml)

proc delete*(aucImages: AucImages, imageName: string) =
  ## イメージを削除する
  let
    sanitizedImageName = imageName.sanitizeFileOrDirName
    targetImageDirPath = aucImages.imagesDirPath / sanitizedImageName
  try:
    removeDir(targetImageDirPath, checkDir = true)
  except OSError:
    raise newException(ValueError, fmt"Image named '{sanitizedImageName}' does not exist")


func image*(auc: ref AzanaUtlCli, imageName: string): AucImage =
  ## imageコマンド
  result.azanaUtlCli = auc
  result.imageDirPath = auc.appDirPath / "images" / imageName
  result.imageFileName = "image.aviutliem.yaml"
  result.imageFilePath = result.imageDirPath / result.imageFileName

func plugins*(aucImage: AucImage): AucPlugins =
  ## image.pluginsコマンド
  result.aucImage = aucImage

proc list*(aucPlugins: AucPlugins): seq[Plugin] =
  ## イメージ内のプラグイン一覧を返す
  let
    imageYamlFile = ImageYamlFile(filePath: aucPlugins.aucImage.imageFilePath)
    imageYaml = imageYamlFile.load()
  return imageYaml.plugins

proc add*(aucPlugins: AucPlugins, plugin: Plugin) =
  ## プラグインを追加する
  let imageYamlFile = ImageYamlFile(filePath: aucPlugins.aucImage.imageFilePath)
  var imageYaml = imageYamlFile.load()
  imageYaml.plugins.add(plugin)
  discard imageYamlFile.update(imageYaml)

proc delete*(aucPlugins: AucPlugins, pluginId: string) =
  ## プラグインを削除する
  let imageYamlFile = ImageYamlFile(filePath: aucPlugins.aucImage.imageFilePath)
  var imageYaml = imageYamlFile.load()

  var remainedPlugins: seq[Plugin] = @[]
  for i, plugin in imageYaml.plugins:
    if plugin.id != pluginId:
      remainedPlugins.add(plugin)

  imageYaml.plugins = remainedPlugins

  discard imageYamlFile.update(imageYaml)


func containers*(auc: ref AzanaUtlCli): AucContainers =
  ## containersコマンド
  result.azanaUtlCli = auc
  result.containersDirPath = auc.appDirPath / "containers"

proc list*(aucContainers: AucContainers): seq[string] =
  ## コンテナ一覧を返す
  for fileOrDir in aucContainers.containersDirPath.listDirs:
    result.add(fileOrDir.splitPath.tail)

proc create*(aucContainers: AucContainers, containerName: string,
    imageName: string) =
  ## コンテナを作成する
  let
    sanitizedContainerName = containerName.sanitizeFileOrDirName
    newContainerDirPath = aucContainers.containersDirPath / sanitizedContainerName
  if dirExists(newContainerDirPath):
    raise newException(ValueError, fmt"Container named '{sanitizedContainerName}' already exists")
  createDir newContainerDirPath
  # 対象イメージをイメージファイルから読み込む
  let
    image = aucContainers.azanaUtlCli.image(imageName)
    imageYamlFile = ImageYamlFile(filePath: image.imageFilePath)
    imageYaml = imageYamlFile.load()
    containerYaml = ContainerYaml(
      container_name: containerName,
      bases: imageYaml.bases,
      plugins: imageYaml.plugins.mapIt(
        ContainerPlugin(
          id: it.id,
          version: it.version,
          is_installed: false,
          is_enabled: false,
          previously_installed_versions: @[]
        )
      ),
    )
  # コンテナファイルを作成
  let
    newContainerFilePath = newContainerDirPath / "container.aviutliem.yaml"
    containerYamlFile = ContainerYamlFile(filePath: newContainerFilePath)
  discard containerYamlFile.update(containerYaml)

proc delete*(aucContainers: AucContainers, containerName: string) =
  ## コンテナを削除する
  let
    sanitizedContainerName = containerName.sanitizeFileOrDirName
    targetContainerDirPath = aucContainers.containersDirPath / sanitizedContainerName
  try:
    removeDir(targetContainerDirPath, checkDir = true)
  except OSError:
    raise newException(ValueError, fmt"Container named '{sanitizedContainerName}' does not exist")


func container*(auc: ref AzanaUtlCli, containerName: string): AucContainer =
  ## containerコマンド
  result.azanaUtlCli = auc
  result.tempDirPath = auc.tempDirPath / "container"
  result.containerDirPath = auc.appDirPath / "containers" / containerName
  result.containerFileName = "container.aviutliem.yaml"
  result.containerFilePath = result.containerDirPath / result.containerFileName
  result.aviutlDirPath = result.containerDirPath / "aviutl"

func plugins*(aucContainer: AucContainer): AucContainerPlugins =
  ## container.pluginsコマンド
  result.aucContainer = aucContainer
  result.dirPath = aucContainer.aviutlDirPath / "plugins"
  result.tempDirPath = aucContainer.tempDirPath / "plugins"
  result.tempSrcDirPath = result.tempDirPath / "src"
  result.tempDestDirPath = result.tempDirPath / "dest"

proc download*(aucContainerPlugins: AucContainerPlugins, plugin: Plugin) =
  ## プラグインをダウンロードする
  # プラグインの配布ページをデフォルトブラウザで開く
  let
    packages = aucContainerPlugins.aucContainer.azanaUtlCli.packages
    url = packages.plugin(plugin.id).version(plugin.version).url
  openDefaultBrowser(url)
  # tempSrcディレクトリをエクスプローラーで開く
  discard execProcess(
    "explorer",
    args = [aucContainerPlugins.tempSrcDirPath],
    options = {poUsePath}
  )

proc install*(aucContainerPlugins: AucContainerPlugins, plugin: Plugin) =
  ## プラグインをインストールする
  let
    packages = aucContainerPlugins.aucContainer.azanaUtlCli.packages
    tempSrcDirPath = aucContainerPlugins.tempSrcDirPath
    tempDestDirPath = aucContainerPlugins.tempDestDirPath
    pluginZipFilePath = listDirs(tempSrcDirPath)[0]
    pluginZipSha3_512Hash = sha3_512File(pluginZipFilePath)
    correctPluginZipSha3_512Hash =
      packages.plugin(plugin.id).version(plugin.version).sha3_512_hash
    containerPluginsDirPath = aucContainerPlugins.dirPath
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

func bases*(aucContainer: AucContainer): AucContainerBases =
  ## container.baseコマンド
  result.aucContainer = aucContainer
  result.dirPath = aucContainer.aviutlDirPath
  result.tempDirPath = aucContainer.tempDirPath / "base"
  result.tempSrcDirPath = result.tempDirPath / "src"
  result.tempDestDirPath = result.tempDirPath / "dest"


func packages*(auc: ref AzanaUtlCli): AucPackages =
  ## packagesコマンド
  result.azanaUtlCli = auc

func bases*(aucPackages: AucPackages): AucPackagesBases =
  ## packages.baseコマンド
  result.aucPackages = aucPackages

func list*(aucPackagesBases: AucPackagesBases): seq[PackagesYamlBasis] =
  ## 入手可能な基盤一覧を返す
  aucPackagesBases.aucPackages.azanaUtlCli.packages.bases.list

func plugins*(aucPackages: AucPackages): AucPackagesPlugins =
  ## packages.pluginsコマンド
  result.aucPackages = aucPackages

func list*(aucPackagesPlugins: AucPackagesPlugins): seq[PackagesYamlPlugin] =
  ## 入手可能なパッケージ一覧を返す
  aucPackagesPlugins.aucPackages.azanaUtlCli.packages.plugins.list

func find*(aucPackagesPlugins: AucPackagesPlugins, query: string): seq[
    PackagesYamlPlugin] =
  ## 入手可能なパッケージを検索する
  aucPackagesPlugins.aucPackages.azanaUtlCli.packages.plugins.find(query)
