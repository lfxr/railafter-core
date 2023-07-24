import
  browsers,
  options,
  os

import
  github_api,
  plugin,
  templates,
  types,
  utils


const ContainerYamlFileName = "container.yaml"


type Container* = object
  containersDirPath, dirPath, path: string
  tempDirPath, tempSrcDirPath*: string
  id, name: string


func newContainer*(
    containersDirPath: string,
    id: string,
    name: string = ""
 ): ref Container =
  result = new Container
  result.containersDirPath = containersDirPath
  result.dirPath = containersDirPath / id
  result.path = containersDirPath / id / ContainerYamlFileName
  result.tempDirPath = result.dirPath / "temp"
  result.tempSrcDirPath = result.tempDirPath / "src"
  result.id = id
  result.name = name


func doesExist*(container: ref Container): bool =
  ## コンテナが存在するかどうかを返す
  result = fileExists(container.path)


proc create*(container: ref Container): Result[void] =
  ## コンテナを作成する
  result = result.typeof()()

  if container.doesExist:
    result.err = option(Error(
      kind: containerAlreadyExistsError,
      containerId: container.id,
    ))
    return

  createDir container.dirPath

  openContainerYamlFile(container.path, saveChanges = true):
    containerYaml = ContainerYaml(
      containerId: container.id,
      containerName: container.name,
    )
  

proc delete*(container: ref Container): Result[void] =
  ## コンテナを削除する
  result = result.typeof()()

  if not container.doesExist:
    result.err = option(Error(
      kind: containerDoesNotExistError,
      containerId: container.id,
    ))
    return

  removeDir(container.dirPath)


proc listPlugins*(container: ref Container): Result[seq[ContainerPlugin]] =
  ## コンテナに含まれるプラグインの一覧を返す
  result = result.typeof()()

  if not container.doesExist:
    result.err = option(Error(
      kind: containerDoesNotExistError,
      containerId: container.id,
    ))
    return

  openContainerYamlFile(container.path, saveChanges = false):
    result.res = containerYaml.plugins


proc downloadPlugin*(
    container: ref Container,
    plugin: ref Plugin,
    options: tuple[useBrowser: bool] = (useBrowser: false)
): Result[void] =
  ## コンテナにプラグインをダウンロードする
  result = result.typeof()()

  if not container.doesExist:
    result.err = option(Error(
      kind: containerDoesNotExistError,
      containerId: container.id,
    ))
    return

  if not plugin.doesExist:
    result.err = option(Error(
      kind: pluginDoesNotExistError,
      pPluginId: plugin.id,
    ))
    return

  block:
    # プラグインのバージョンデータを取得する
    let pluginVersionData = plugin.versionData

    if pluginVersionData.err.isSome:
      result.err = pluginVersionData.err
      return
    
    # プラグインのキャッシュが存在する場合は,
    # プラグインをインターネットからダウンロードせずに, キャッシュを適用する
    # TODO: キャッシュの処理を書く

    # プラグインのキャッシュが存在しない場合は,
    # プラグインをインターネットからダウンロードする
    block:
      let
        pluginCanBeDownloadedViaGitHubApi = plugin.canBeDownloadedViaGitHubApi.res
      if not options.useBrowser and not pluginCanBeDownloadedViaGitHubApi:
        occurNonfatalError(
          "このプラグインをGitHub API経由でダウンロードできません。"
        )
        occurNonfatalError(
          "代わりに, プラグインの配布ページをデフォルトブラウザで開きます。"
        )

      if options.useBrowser or not pluginCanBeDownloadedViaGitHubApi:
        # プラグインの配布ページをデフォルトブラウザで開く
        showInfo "プラグインの配布ページをデフォルトブラウザで開いています..."
        openDefaultBrowser(pluginVersionData.res.url)

        # tempSrcディレクトリをエクスプローラーで開く
        showInfo "一時ディレクトリをエクスプローラーで開いています..."
        revealDirInExplorer(container.tempSrcDirPath) 

      else:
        let packageInfo = plugin.packageInfo
        if packageInfo.err.isSome:
          result.err = packageInfo.err
          return

        let
          githubRepository = packageInfo.res.githubRepository
          owner = githubRepository.get.owner
          repo = githubRepository.get.repo
          assetId = pluginVersionData.res.githubAssetId

        let res =
          newGitHubApi()
            .repository((owner: owner, repo: repo))
            .asset(assetId.get)
            .download(container.tempSrcDirPath / "assets.zip")

        if res.err.isSome:
          result.err = res.err
          return
