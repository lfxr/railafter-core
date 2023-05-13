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
  private/github_api,
  private/packages,
  private/procs,
  private/templates,
  private/types


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
  isolatedDirPath: string
  isolatedPluginsDirPath: string

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

proc create*(aucImages: AucImages, unsafeImageId, imageName: string): Result[void] =
  ## イメージを作成する
  result = result.typeof()()
  let
    sanitizedImageId = unsafeImageId.sanitizeFileOrDirName
    newImageDirPath = aucImages.imagesDirPath / sanitizedImageId
  if dirExists(newImageDirPath):
    result.err = option(
      Error(kind: imageAlreadyExistsError, imageId: sanitizedImageId)
    )
    return
  createDir newImageDirPath
  openImageYamlFile(newImageDirPath / "image.aviutliem.yaml", fmWrite):
    imageYaml = ImageYaml(imageId: sanitizedImageId, imageName: imageName)

proc delete*(aucImages: AucImages, unsafeImageId: string): Result[void] =
  ## イメージを削除する
  result = result.typeof()()
  let
    sanitizedImageId = unsafeImageId.sanitizeFileOrDirName
    targetImageDirPath = aucImages.imagesDirPath / sanitizedImageId
  try:
    removeDir(targetImageDirPath, checkDir = true)
  except OSError:
    result.err = option(
      Error(kind: imageDoesNotExistError, imageId: sanitizedImageId)
    )
    return


func image*(auc: ref AzanaUtlCli, unsafeImageId: string): AucImage =
  ## imageコマンド
  result.azanaUtlCli = auc
  result.imageDirPath = auc.appDirPath / "images" / unsafeImageId.sanitizeFileOrDirName
  result.imageFileName = "image.aviutliem.yaml"
  result.imageFilePath = result.imageDirPath / result.imageFileName

func plugins*(aucImage: AucImage): AucPlugins =
  ## image.pluginsコマンド
  result.aucImage = aucImage

proc list*(aucPlugins: AucPlugins): seq[Plugin] =
  ## イメージ内のプラグイン一覧を返す
  openImageYamlFile(aucPlugins.aucImage.imageFilePath, fmRead):
    return imageYaml.plugins

proc add*(aucPlugins: AucPlugins, plugin: Plugin) =
  ## プラグインを追加する
  openImageYamlFile(aucPlugins.aucImage.imageFilePath, fmWrite):
    imageYaml.plugins.add(plugin)

proc delete*(aucPlugins: AucPlugins, pluginId: string) =
  ## プラグインを削除する
  openImageYamlFile(aucPlugins.aucImage.imageFilePath, fmWrite):
    imageYaml.plugins = imageYaml.plugins.filterIt(it.id != pluginId)


func containers*(auc: ref AzanaUtlCli): AucContainers =
  ## containersコマンド
  result.azanaUtlCli = auc
  result.containersDirPath = auc.appDirPath / "containers"

proc list*(aucContainers: AucContainers): seq[string] =
  ## コンテナ一覧を返す
  for fileOrDir in aucContainers.containersDirPath.listDirs:
    result.add(fileOrDir.splitPath.tail)

proc create*(aucContainers: AucContainers,
    unsafeContainerId, containerName, unsafeImageId: string): Result[void] =
  ## コンテナを作成する
  result = result.typeof()()
  let
    sanitizedContainerId = unsafeContainerId.sanitizeFileOrDirName
    newContainerDirPath = aucContainers.containersDirPath / sanitizedContainerId
  if dirExists(newContainerDirPath):
    result.err = option(
      Error(kind: containerAlreadyExistsError, containerId: sanitizedContainerId)
    )
    return
  createDir newContainerDirPath
  # 対象イメージをイメージファイルから読み込む
  let
    image = aucContainers.azanaUtlCli.image(unsafeImageId.sanitizeFileOrDirName)
  openImageYamlFile(image.imageFilePath, fmRead):
    let generatedContainerYaml = ContainerYaml(
      containerId: sanitizedContainerId,
      containerName: containerName,
      bases: ContainerBases(
        aviutl: (version: imageYaml.bases.aviutlVersion, isInstalled: false),
        exedit: (version: imageYaml.bases.exeditVersion, isInstalled: false),
      ),
      plugins: imageYaml.plugins.mapIt(
        ContainerPlugin(
          id: it.id,
          version: it.version,
          isInstalled: false,
          isEnabled: false,
          previouslyInstalledVersions: @[]
        )
      ),
    )
    openContainerYamlFile(newContainerDirPath / "container.aviutliem.yaml", fmWrite):
      containerYaml = generatedContainerYaml

proc delete*(aucContainers: AucContainers, unsafeContainerId: string): Result[void] =
  ## コンテナを削除する
  result = result.typeof()()
  let
    sanitizedContainerId = unsafeContainerId.sanitizeFileOrDirName
    targetContainerDirPath = aucContainers.containersDirPath / sanitizedContainerId
  try:
    removeDir(targetContainerDirPath, checkDir = true)
  except OSError:
    result.err = option(
      Error(kind: containerDoesNotExistError, containerId: sanitizedContainerId)
    )
    return

func container*(auc: ref AzanaUtlCli, unsafeContainerId: string): AucContainer =
  ## containerコマンド
  let sanitizedContainerId = unsafeContainerId.sanitizeFileOrDirName
  result.azanaUtlCli = auc
  result.tempDirPath = auc.tempDirPath / "containers" / sanitizedContainerId
  result.containerDirPath = auc.appDirPath / "containers" / sanitizedContainerId
  result.containerFileName = "container.aviutliem.yaml"
  result.containerFilePath = result.containerDirPath / result.containerFileName
  result.aviutlDirPath = result.containerDirPath / "aviutl"
  result.isolatedDirPath = result.containerDirPath / "isolated"
  result.isolatedPluginsDirPath = result.isolatedDirPath / "plugins"

func bases*(aucContainer: AucContainer): AucContainerBases =
  ## container.baseコマンド
  result.aucContainer = aucContainer
  result.dirPath = aucContainer.aviutlDirPath
  result.tempDirPath = aucContainer.tempDirPath / "base"
  result.tempSrcDirPath = result.tempDirPath / "src"
  result.tempDestDirPath = result.tempDirPath / "dest"

proc list*(aucContainerBases: AucContainerBases): ContainerBases =
  ## コンテナ内の基盤を返す
  openContainerYamlFile(aucContainerBases.aucContainer.containerFilePath, fmRead):
    return containerYaml.bases

proc get*(aucContainerBases: AucContainerBases): Result[void] =
  ## AviUtl本体と拡張編集を入手 (ダウンロード・インストール) する
  proc get(id, version: string): Result[void] =
    result = result.typeof()()
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
      result.err = option(
        Error(
          kind: invalidZipFileHashValueError,
          zipFilePath: downloadedFilePath.absolutePath,
          expectedHashValue: correctDownloadedFileSha3_512Hash,
          actualHashValue: downloadedFileSha3_512Hash
        )
      )
      return
    # ダウンロードされたファイルを解凍
    extractAll(downloadedFilePath, tempDestDirPath)
    # コンテナのaviutlディレクトリに解凍されたファイルを移動
    for file in walkDirRec(tempDestDirPath):
      moveFile(file, dirPath / file.splitPath.tail)
    # 解凍されたファイルが存在していたディレクトリとダウンロードされたファイルを削除
    removeDir(tempDestDirPath, checkDir = true)
    removeFile downloadedFilePath
    # インストールした基盤の情報をコンテナファイルに書き込む
    openContainerYamlFile(aucContainerBases.aucContainer.containerFilePath, fmWrite):
      if id == "aviutl":
        containerYaml.bases.aviutl.isInstalled = true
      elif id == "exedit":
        containerYaml.bases.exedit.isInstalled = true
  result = result.typeof()()
  let res = result
  block:
    get("aviutl", aucContainerBases.list.aviutl.version).err.map(
      proc(err: Error) = res.err = option(err)
    )
    if res.err.isSome: return
  sleep 5000
  block:
    get("exedit", aucContainerBases.list.exedit.version).err.map(
      proc(err: Error) = res.err = option(err)
    )
    if res.err.isSome: return
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
  openContainerYamlFile(aucContainerPlugins.aucContainer.containerFilePath, fmRead):
    return containerYaml.plugins

proc download*(aucContainerPlugins: AucContainerPlugins, plugin: Plugin,
    useBrowser: bool = false) =
  ## プラグインをダウンロードする
  let
    packages = aucContainerPlugins.aucContainer.azanaUtlCli.packages
    targetPlugin = packages.plugin(plugin.id)
    specifiedPluginVersion = targetPlugin.version(plugin.version)
    tempSrcDirPath = aucContainerPlugins.tempSrcDirPath
    assetId = specifiedPluginVersion.githubAssetId.get(-1)
  if useBrowser or assetId == -1:
    if not useBrowser:
      occurNonfatalError "このプラグインをGitHub API経由でダウンロードできません"
      showInfo "代わりにデフォルトブラウザを使用します"
    # プラグインの配布ページをデフォルトブラウザで開く
    showInfo "プラグインの配布ページをデフォルトブラウザで開いています..."
    openDefaultBrowser(specifiedPluginVersion.url)
    # tempSrcディレクトリをエクスプローラーで開く
    showInfo "一時ディレクトリをエクスプローラーで開いています..."
    revealDirInExplorer(tempSrcDirPath)
    return
  # GitHub APIを使ってZIPファイルをダウンロードする
  let
    ghApi = newGitHubApi()
    destPath = tempSrcDirPath / "asset.zip"
    githubRepository = targetPlugin.githubRepository
    tag = specifiedPluginVersion.githubReleaseTag.get
  showInfo "ZIPファイルをGitHub API経由でダウンロードしています..."
  ghApi
    .repository(githubRepository)
    .release(tag)
    .asset(assetId)
    .download(destPath)
  showInfo fmt"プラグインが正常にダウンロードされました: {plugin.id}:{plugin.version}"

proc install*(aucContainerPlugins: AucContainerPlugins, targetPlugin: Plugin):
    Result[void] =
  ## プラグインをインストールする
  result = result.typeof()()
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
  showInfo "依存関係を確認しています..."
  let
    dependenciesBases = dependencies.bases.get(DependenciesBases())
    dependenciesPlugins = dependencies.plugins.get(@[])
    dependenciesTuple = (
      bases: (
        aviutl: dependenciesBases.aviutlVersions.get(@[]),
        exedit: dependenciesBases.exeditVersions.get(@[]),
      ),
      plugins: dependenciesPlugins,
    )
    containerBases = aucContainerPlugins.aucContainer.bases.list
    containerPlugins = aucContainerPlugins.list
    installedPackagesTuple = (
      bases: (
        aviutl: containerBases.aviutl,
        exedit: containerBases.exedit,
      ),
      plugins: containerPlugins,
    )
  # 依存関係の基盤がインストールされているか確認
  # AviUtl
  if not installedPackagesTuple.bases.aviutl.isInstalled:
    result.err = option(
      Error(
        kind: depencyNotSatisfiedError,
        depencyName: "AviUtl",
        expectedVersions: dependenciesTuple.bases.aviutl,
        actualVersion: "None",
      )
    )
    return
  if dependenciesTuple.bases.aviutl != @[]:
    var isSatisfied = false
    for version in dependenciesTuple.bases.aviutl:
      if version == installedPackagesTuple.bases.aviutl.version:
        isSatisfied = true
        break
    if not isSatisfied:
      result.err = option(
        Error(
          kind: depencyNotSatisfiedError,
          depencyName: "AviUtl",
          expectedVersions: dependenciesTuple.bases.aviutl,
          actualVersion: installedPackagesTuple.bases.aviutl.version,
        )
      )
      return
  # 拡張編集
  if not installedPackagesTuple.bases.exedit.isInstalled:
    result.err = option(
      Error(
        kind: depencyNotSatisfiedError,
        depencyName: "拡張編集",
        expectedVersions: dependenciesTuple.bases.exedit,
        actualVersion: "None",
      )
    )
    return
  if dependenciesTuple.bases.exedit != @[]:
    var isSatisfied = false
    for version in dependenciesTuple.bases.exedit:
      if version == installedPackagesTuple.bases.exedit.version:
        isSatisfied = true
        break
    if not isSatisfied:
      result.err = option(
        Error(
          kind: depencyNotSatisfiedError,
          depencyName: "拡張編集",
          expectedVersions: dependenciesTuple.bases.exedit,
          actualVersion: installedPackagesTuple.bases.exedit.version,
        )
      )
      return
  # 依存関係のプラグインがインストールされているか確認
  for dependencyPlugin in dependenciesTuple.plugins:
    var isDependencyPluginInstalledAndEnabled = false
    for installedPlugin in installedPackagesTuple.plugins:
      if dependencyPlugin.id == installedPlugin.id:
        if not (installedPlugin.isInstalled and installedPlugin.isEnabled):
          break
        isDependencyPluginInstalledAndEnabled = true
        var isDependencyPluginVersionInstalled = false
        for version in dependencyPlugin.versions:
          if version == installedPlugin.version:
            isDependencyPluginVersionInstalled = true
            break
        if not isDependencyPluginVersionInstalled:
          result.err = option(
            Error(
              kind: depencyNotSatisfiedError,
              depencyName: dependencyPlugin.id,
              expectedVersions: dependencyPlugin.versions,
              actualVersion: installedPlugin.version,
            )
          )
          return
    if not isDependencyPluginInstalledAndEnabled:
      result.err = option(
        Error(
          kind: depencyNotSatisfiedError,
          depencyName: dependencyPlugin.id,
          expectedVersions: dependencyPlugin.versions,
          actualVersion: "None",
        )
      )
      return
  # ダウンロードしたzipファイルのハッシュ値を検証
  showInfo "ZIPファイルのハッシュ値を検証しています..."
  if pluginZipSha3_512Hash != correctPluginZipSha3_512Hash:
    result.err = option(
      Error(
        kind: invalidZipFileHashValueError,
        zipFilePath: pluginZipFilePath.absolutePath,
        expectedHashValue: correctPluginZipSha3_512Hash,
        actualHashValue: pluginZipSha3_512Hash,
      )
    )
    return
  # プラグインのzipファイルを解凍
  showInfo "ZIPファイルを解凍しています..."
  extractAll(pluginZipFilePath, tempDestDirPath)
  # 解凍されたファイルをコンテナの指定されたディレクトリに移動
  showInfo "ファイルを移動しています..."
  for trackedFileOrDir in trackedFilesAndDirs:
    let
      trackedFileOrDirPath = trackedFileOrDir.path
      srcFilePath = tempDestDirPath / trackedFileOrDirPath
      destFileOrDirPath =
        (
          case trackedFileOrDir.moveTo:
          of MoveTo.Root: aucContainerPlugins.aucContainer.aviutlDirPath
          of MoveTo.Plugins: containerPluginsDirPath
        ) / trackedFileOrDirPath
    case trackedFileOrDir.fdType:
    of FdType.File:
      if trackedFileOrDir.isProtected and destFileOrDirPath.fileExists: break
      moveFile(srcFilePath, destFileOrDirPath)
    of FdType.Dir:
      if trackedFileOrDir.isProtected and destFileOrDirPath.dirExists: break
      moveDir(srcFilePath, destFileOrDirPath)
  # タイプがAfterInstallationであるJobを実行
  showInfo "タスクを実行しています..."
  for job in jobs.filterIt(it.id == AfterInstallation):
    for task in job.tasks:
      let workingDir =
        case task.workingDir:
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
  showInfo "一時ディレクトリを削除しています..."
  removeDir(tempDestDirPath, checkDir = true)
  removeFile pluginZipFilePath
  # インストールしたプラグインの情報をコンテナファイルに書き込む
  var isPluginInContainerFile = false
  let filePath = aucContainerPlugins.aucContainer.containerFilePath
  openContainerYamlFile(filePath, fmWrite):
    for i, plugin in containerYaml.plugins:
      if plugin.id == targetPlugin.id:
        isPluginInContainerFile = true
        if containerYaml.plugins[i].version != targetPlugin.version:
          containerYaml.plugins[i]
            .previouslyInstalledVersions
            .add(containerYaml.plugins[i].version)
        containerYaml.plugins[i].version = targetPlugin.version
        containerYaml.plugins[i].isInstalled = true
        containerYaml.plugins[i].isEnabled = true
        break
  if not isPluginInContainerFile:
    containerYaml.plugins.add(
      ContainerPlugin(
        id: targetPlugin.id,
        version: targetPlugin.version,
        isInstalled: true,
        isEnabled: true,
        previouslyInstalledVersions: @[],
      )
    )
  showInfo fmt"プラグインが正常にインストールされました: {targetPlugin.id}:{targetPlugin.version}"

proc enable*(aucContainerPlugins: AucContainerPlugins, pluginId: string) =
  ## プラグインを有効化する
  var
    isPluginInContainerFile = false
    pluginVersion = ""
  let filePath = aucContainerPlugins.aucContainer.containerFilePath
  openContainerYamlFile(filePath, fmWrite):
    for i, plugin in containeryaml.plugins:
      if plugin.id == pluginId:
        isPluginInContainerFile = true
        pluginVersion = plugin.version
        containeryaml.plugins[i].isEnabled = true
        break
  let
    packages = aucContainerPlugins.aucContainer.azanaUtlCli.packages
    trackedFds = packages.plugin(pluginId).trackedFilesAndDirs(pluginVersion)
    isolatedPluginsDirPath = aucContainerPlugins.aucContainer.isolatedPluginsDirPath
  processTrackedFds(
    trackedFds,
    (root: aucContainerPlugins.aucContainer.aviutlDirPath, plugins: aucContainerPlugins.dirPath),
    (src: false, dest: true),
    (src: isolatedPluginsDirPath / pluginId, dest: "")
  )

proc disable*(aucContainerPlugins: AucContainerPlugins, pluginId: string) =
  ## プラグインを無効化する
  var
    isPluginInContainerFile = false
    pluginVersion = ""
  let containerFilePath = aucContainerPlugins.aucContainer.containerFilePath
  openContainerYamlFile(containerFilePath, fmWrite):
    for i, plugin in containeryaml.plugins:
      if plugin.id == pluginId:
        isPluginInContainerFile = true
        pluginVersion = plugin.version
        containerYaml.plugins[i].isEnabled = false
        break
  let
    packages = aucContainerPlugins.aucContainer.azanaUtlCli.packages
    trackedFds = packages.plugin(pluginId).trackedFilesAndDirs(pluginVersion)
    isolatedPluginsDirPath = aucContainerPlugins.aucContainer.isolatedPluginsDirPath
  processTrackedFds(
    trackedFds,
    (root: aucContainerPlugins.aucContainer.aviutlDirPath, plugins: aucContainerPlugins.dirPath),
    (src: true, dest: false),
    (src: "", dest: isolatedPluginsDirPath / pluginId)
  )


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
