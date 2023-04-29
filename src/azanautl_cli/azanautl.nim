import
  browsers,
  httpclient,
  options,
  os,
  osproc,
  sequtils,
  strformat

import
  zippy/ziparchives

import
  private/errors,
  private/github_api,
  private/packages,
  private/procs,
  private/types,
  private/yaml_file


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

proc create*(aucImages: AucImages, imageId, imageName: string) =
  ## イメージを作成する
  let
    sanitizedImageId = imageId.sanitizeFileOrDirName
    newImageDirPath = aucImages.imagesDirPath / sanitizedImageId
  if dirExists(newImageDirPath):
    raise newException(ValueError, fmt"Image named '{sanitizedImageId}' already exists")
  createDir newImageDirPath
  let
    newImageFilePath = newImageDirPath / "image.aviutliem.yaml"
    imageYamlFile = ImageYamlFile(filePath: newImageFilePath)
  discard imageYamlFile.update(ImageYaml(imageId: imageId, imageName: imageName))

proc delete*(aucImages: AucImages, imageId: string) =
  ## イメージを削除する
  let
    sanitizedImageId = imageId.sanitizeFileOrDirName
    targetImageDirPath = aucImages.imagesDirPath / sanitizedImageId
  try:
    removeDir(targetImageDirPath, checkDir = true)
  except OSError:
    raise newException(ValueError, fmt"Image named '{sanitizedImageId}' does not exist")


func image*(auc: ref AzanaUtlCli, imageId: string): AucImage =
  ## imageコマンド
  result.azanaUtlCli = auc
  result.imageDirPath = auc.appDirPath / "images" / imageId
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

proc create*(aucContainers: AucContainers, containerId, containerName, imageId: string) =
  ## コンテナを作成する
  let
    sanitizedContainerId = containerId.sanitizeFileOrDirName
    newContainerDirPath = aucContainers.containersDirPath / sanitizedContainerId
  if dirExists(newContainerDirPath):
    raise newException(ValueError, fmt"Container named '{sanitizedContainerId}' already exists")
  createDir newContainerDirPath
  # 対象イメージをイメージファイルから読み込む
  let
    image = aucContainers.azanaUtlCli.image(imageId)
    imageYamlFile = ImageYamlFile(filePath: image.imageFilePath)
    imageYaml = imageYamlFile.load()
    containerYaml = ContainerYaml(
      container_id: containerId,
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

proc delete*(aucContainers: AucContainers, containerId: string) =
  ## コンテナを削除する
  let
    sanitizedContainerId = containerId.sanitizeFileOrDirName
    targetContainerDirPath = aucContainers.containersDirPath / sanitizedContainerId
  try:
    removeDir(targetContainerDirPath, checkDir = true)
  except OSError:
    raise newException(ValueError, fmt"Container named '{sanitizedContainerId}' does not exist")


func container*(auc: ref AzanaUtlCli, containerId: string): AucContainer =
  ## containerコマンド
  result.azanaUtlCli = auc
  result.tempDirPath = auc.tempDirPath / "containers" / containerId
  result.containerDirPath = auc.appDirPath / "containers" / containerId
  result.containerFileName = "container.aviutliem.yaml"
  result.containerFilePath = result.containerDirPath / result.containerFileName
  result.aviutlDirPath = result.containerDirPath / "aviutl"

func bases*(aucContainer: AucContainer): AucContainerBases =
  ## container.baseコマンド
  result.aucContainer = aucContainer
  result.dirPath = aucContainer.aviutlDirPath
  result.tempDirPath = aucContainer.tempDirPath / "base"
  result.tempSrcDirPath = result.tempDirPath / "src"
  result.tempDestDirPath = result.tempDirPath / "dest"

proc list*(aucContainerBases: AucContainerBases): Bases =
  ## コンテナ内の基盤を返す
  let
    containerYamlFile = ContainerYamlFile(
      filePath: aucContainerBases.aucContainer.containerFilePath
    )
    containerYaml = containerYamlFile.load()
  return containerYaml.bases

proc get*(aucContainerBases: AucContainerBases) =
  ## AviUtl本体と拡張編集を入手 (ダウンロード・インストール) する
  proc get(id, version: string) =
    let
      packages = aucContainerBases.aucContainer.azanaUtlCli.packages
      targetBasis = packages.basis(id).version(version)
      tempSrcDirPath = aucContainerBases.tempSrcDirPath
      tempDestDirPath = aucContainerBases.tempDestDirPath
      dirPath = aucContainerBases.dirPath
      downloadedFilePath = tempSrcDirPath / id & ".zip"
    newHttpClient().downloadFile(targetBasis.url, downloadedFilePath)
    # ダウンロードされたファイルのハッシュ値を検証
    let
      downloadedFileSha3_512Hash = sha3_512File(downloadedFilePath)
      correctDownloadedFileSha3_512Hash = targetBasis.sha3_512_hash
    if downloadedFileSha3_512Hash != correctDownloadedFileSha3_512Hash:
      invalidZipFileHashValue(downloadedFilePath.absolutePath)
    # ダウンロードされたファイルを解凍
    extractAll(downloadedFilePath, tempDestDirPath)
    # コンテナのaviutlディレクトリに解凍されたファイルを移動
    for file in walkDirRec(tempDestDirPath):
      moveFile(file, dirPath / file.splitPath.tail)
    # 解凍されたファイルが存在していたディレクトリとダウンロードされたファイルを削除
    removeDir(tempDestDirPath, checkDir = true)
    removeFile downloadedFilePath
  get("aviutl", aucContainerBases.list.aviutl_version)
  sleep 5000
  get("exedit", aucContainerBases.list.exedit_version)
  createDir(aucContainerBases.dirPath / "plugins")

func plugins*(aucContainer: AucContainer): AucContainerPlugins =
  ## container.pluginsコマンド
  result.aucContainer = aucContainer
  result.dirPath = aucContainer.aviutlDirPath / "plugins"
  result.tempDirPath = aucContainer.tempDirPath / "plugins"
  result.tempSrcDirPath = result.tempDirPath / "src"
  result.tempDestDirPath = result.tempDirPath / "dest"

proc list*(aucContainerPlugins: AucContainerPlugins): seq[ContainerPlugin] =
  ## コンテナ内のプラグイン一覧を返す
  let
    containerYamlFile = ContainerYamlFile(
      filePath: aucContainerPlugins.aucContainer.containerFilePath
    )
    containerYaml = containerYamlFile.load()
  return containerYaml.plugins

proc download*(aucContainerPlugins: AucContainerPlugins, plugin: Plugin,
    useBrowser: bool = false) =
  ## プラグインをダウンロードする
  let
    packages = aucContainerPlugins.aucContainer.azanaUtlCli.packages
    targetPlugin = packages.plugin(plugin.id)
    specifiedPluginVersion = targetPlugin.version(plugin.version)
    tempSrcDirPath = aucContainerPlugins.tempSrcDirPath
    assetId = specifiedPluginVersion.github_asset_id.get(-1)
  if useBrowser or assetId == -1:
    if not useBrowser:
      echo "[error] The plugin cannot be downloaded via GitHub API."
      echo "[info] Use the default browser instead."
    # プラグインの配布ページをデフォルトブラウザで開く
    echo "[info] Opening the plugin's distribution page in the default browser..."
    openDefaultBrowser(specifiedPluginVersion.url)
    # tempSrcディレクトリをエクスプローラーで開く
    echo "[info] Opening the temporary directory in Explorer..."
    discard execProcess(
      "explorer",
      args = [tempSrcDirPath],
      options = {poUsePath}
    )
    return
  # GitHub APIを使ってZIPファイルをダウンロードする
  let
    ghApi = newGitHubApi()
    destPath = tempSrcDirPath / "asset.zip"
    githubRepository = targetPlugin.githubRepository
    tag = specifiedPluginVersion.github_release_tag.get
  echo "[info] Downloading the ZIP file via GitHub API..."
  ghApi
    .repository(githubRepository)
    .release(tag)
    .asset(assetId)
    .download(destPath)
  echo fmt"[info] Successfully downloaded plugin: {plugin.id}:{plugin.version}"

proc install*(aucContainerPlugins: AucContainerPlugins, targetPlugin: Plugin) =
  ## プラグインをインストールする
  let
    packages = aucContainerPlugins.aucContainer.azanaUtlCli.packages
    packagePlugin = packages.plugin(targetPlugin.id)
    dependencies = packagePlugin.dependencies(targetPlugin.version)
    tempSrcDirPath = aucContainerPlugins.tempSrcDirPath
    tempDestDirPath = aucContainerPlugins.tempDestDirPath
    pluginZipFilePath = listDirs(tempSrcDirPath)[0]
    pluginZipSha3_512Hash = sha3_512File(pluginZipFilePath)
    correctPluginZipSha3_512Hash =
      packagePlugin.version(targetPlugin.version).sha3_512_hash
    containerPluginsDirPath = aucContainerPlugins.dirPath
    trackedFilesAndDirs =
      packagePlugin.trackedFilesAndDirs(targetPlugin.version)
    jobs = packagePlugin.jobs(targetPlugin.version)
  # 依存関係を満たしているか確認
  echo "[info] Checking dependencies..."
  let
    dependenciesBases = dependencies.bases.get(DependenciesBases())
    dependenciesPlugins = dependencies.plugins.get(@[])
    dependenciesTuple = (
      bases: (
        aviutl: dependenciesBases.aviutl_versions.get(@[]),
        exedit: dependenciesBases.exedit_versions.get(@[]),
      ),
      plugins: dependenciesPlugins,
    )
    containerBases = aucContainerPlugins.aucContainer.bases.list
    containerPlugins = aucContainerPlugins.list
    installedPackagesTuple = (
      bases: (
        aviutl: containerBases.aviutl_version,
        exedit: containerBases.exedit_version,
      ),
      plugins: containerPlugins,
    )
  # 依存関係の基盤がインストールされているか確認
  if dependenciesTuple.bases.aviutl != @[]:
    var isSatisfied = false
    for version in dependenciesTuple.bases.aviutl:
      if version == installedPackagesTuple.bases.aviutl:
        isSatisfied = true
        break
    if not isSatisfied:
      dependencyNotSatisfied(
        "AviUtl",
        dependenciesTuple.bases.aviutl,
        installedPackagesTuple.bases.aviutl
      )
  if dependenciesTuple.bases.exedit != @[]:
    var isSatisfied = false
    for version in dependenciesTuple.bases.exedit:
      if version == installedPackagesTuple.bases.exedit:
        isSatisfied = true
        break
    if not isSatisfied:
      dependencyNotSatisfied(
        "拡張編集",
        dependenciesTuple.bases.exedit,
        installedPackagesTuple.bases.exedit
      )
  # 依存関係のプラグインがインストールされているか確認
  for dependencyPlugin in dependenciesTuple.plugins:
    var isDependencyPluginInstalledAndEnabled = false
    for installedPlugin in installedPackagesTuple.plugins:
      if dependencyPlugin.id == installedPlugin.id:
        if not (installedPlugin.is_installed and installedPlugin.is_enabled):
          break
        isDependencyPluginInstalledAndEnabled = true
        var isDependencyPluginVersionInstalled = false
        for version in dependencyPlugin.versions:
          if version == installedPlugin.version:
            isDependencyPluginVersionInstalled = true
            break
        if not isDependencyPluginVersionInstalled:
          dependencyNotSatisfied(
            dependencyPlugin.id,
            dependencyPlugin.versions,
            installedPlugin.version
          )
    if not isDependencyPluginInstalledAndEnabled:
      dependencyNotSatisfied(
        dependencyPlugin.id, dependencyPlugin.versions, "None"
      )
  # ダウンロードしたzipファイルのハッシュ値を検証
  echo "[info] Verifying the hash value of the ZIP file..."
  if pluginZipSha3_512Hash != correctPluginZipSha3_512Hash:
    invalidZipFileHashValue(pluginZipFilePath.absolutePath)
  # プラグインのzipファイルを解凍
  echo "[info] Extracting the ZIP file..."
  extractAll(pluginZipFilePath, tempDestDirPath)
  # 解凍されたファイルをコンテナの指定されたディレクトリに移動
  echo "[info] Moving files..."
  for trackedFileOrDir in trackedFilesAndDirs:
    let
      trackedFileOrDirPath = trackedFileOrDir.path
      srcFilePath = tempDestDirPath / trackedFileOrDirPath
      destFileOrDirPath =
        (
          case trackedFileOrDir.move_to:
          of MoveTo.Root: aucContainerPlugins.aucContainer.aviutlDirPath
          of MoveTo.Plugins: containerPluginsDirPath
        ) / trackedFileOrDirPath
    case trackedFileOrDir.fd_type:
    of FdType.File:
      if trackedFileOrDir.is_protected and destFileOrDirPath.fileExists: break
      moveFile(srcFilePath, destFileOrDirPath)
    of FdType.Dir:
      if trackedFileOrDir.is_protected and destFileOrDirPath.dirExists: break
      moveDir(srcFilePath, destFileOrDirPath)
  # タイプがAfterInstallationであるJobを実行
  echo "[info] Running tasks..."
  for job in jobs.filterIt(it.id == AfterInstallation):
    for task in job.tasks:
      let workingDir =
        case task.working_dir:
          of WorkingDir.Root:
            aucContainerPlugins.aucContainer.aviutlDirPath
          of WorkingDir.Plugins:
            containerPluginsDirPath
          of WorkingDir.DownloadedPlugin:
            tempDestDirPath
      case task.command:
        of Remove:
          for path in task.paths:
            removeFile(workingDir / sanitizeFileOrDirName(path))
        of Run:
          discard task.paths.mapIt(
            execProcess(workingDir / sanitizeFileOrDirName(it)))
  # 解凍されたファイルが存在していたディレクトリを削除
  echo "[info] Deleting temporary directory..."
  removeDir(tempDestDirPath, checkDir = true)
  removeFile pluginZipFilePath
  # インストールしたプラグインの情報をコンテナファイルに書き込む
  let
    containerYamlFile = ContainerYamlFile(
      filePath: aucContainerPlugins.aucContainer.containerFilePath
    )
  var
    containerYaml = containerYamlFile.load()
    isPluginInContainerFile = false
  for i, plugin in containerYaml.plugins:
    if plugin.id == targetPlugin.id:
      isPluginInContainerFile = true
      if containerYaml.plugins[i].version != targetPlugin.version:
        containerYaml.plugins[i]
          .previously_installed_versions
          .add(containerYaml.plugins[i].version)
      containerYaml.plugins[i].version = targetPlugin.version
      containerYaml.plugins[i].is_installed = true
      containerYaml.plugins[i].is_enabled = true
      break
  # コンテナファイルにプラグインが存在しない場合は追加
  if not isPluginInContainerFile:
    containerYaml.plugins.add(
      ContainerPlugin(
        id: targetPlugin.id,
        version: targetPlugin.version,
        is_installed: true,
        is_enabled: true,
        previously_installed_versions: @[]
      )
    )
  discard containerYamlFile.update(containerYaml)

  echo fmt"[info] Successfully installed plugin: {targetPlugin.id}:{targetPlugin.version}"


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
