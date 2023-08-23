import
  options,
  sequtils

import
  github_api,
  packages_yaml,
  types


type Plugin* = object
  packagesYamlFilePath*: string
  id*, version*: string
  packageInfo*: PackagesYamlPlugin


# プロトタイプ宣言
proc loadPackageInfo(plugin: ref Plugin): Result[void]


proc init(plugin: ref Plugin): Result[void] =
  ## Pluginオブジェクトのコンストラクタ
  result = result.typeof()()

  ## プラグインのパッケージ情報を読み込む
  let res = plugin.loadPackageInfo()
  if res.err.isSome:
    result.err = res.err
    return


proc newPlugin*(
    id: string,
    version: string = "",
    packagesYamlFilePath: string = "",
): Result[ref Plugin] =
  result = result.typeof()()
  result.res = new Plugin
  result.res.id = id
  result.res.version = version
  result.res.packagesYamlFilePath = packagesYamlFilePath

  let res = result.res.init()
  if res.err.isSome:
    result.err = res.err
    return


proc loadPackageInfo(plugin: ref Plugin): Result[void] =
  ## プラグインのパッケージ情報を読み込む
  result = result.typeof()()

  # Packages Yamlを読み込む
  let
    reader = newPackagesYamlFileReader(plugin.packagesYamlFilePath)
    packagesYaml = reader.read()

  if packagesYaml.err.isSome:
    result.err = packagesYaml.err
    return

  # プラグインのパッケージ情報を取得する
  let matchedPackageInfo = packagesYaml.res.plugins.filterIt(it.id == plugin.id)
  if matchedPackageInfo.len == 0:
    result.err = option(Error(
      kind: pluginDoesNotExistError,
      pPluginId: plugin.id,
    ))
    return

  plugin.packageInfo = matchedPackageInfo[0]


func versionData*(plugin: ref Plugin): Result[PackagesYamlPluginVersion] =
  ## プラグインのバージョン情報を返す
  result = result.typeof()()

  let matchedPlugins = plugin.packageInfo.versions.filterIt(
    it.version == plugin.version
  )

  if matchedPlugins.len == 0:
    result.err = option(Error(
      kind: pluginSpecifiedVersionDoesNotExistError,
      psPluginId: plugin.id,
      pluginVersion: plugin.version,
    ))
    return

  result.res = matchedPlugins[0]


func canBeDownloadedViaGitHubApi*(plugin: ref Plugin): Result[bool] =
  ## GitHub API 経由でプラグインをダウンロードできるかどうかを返す
  result = result.typeof()()

  let pluginVersionData = plugin.versionData()
  if pluginVersionData.err.isSome:
    result.err = pluginVersionData.err
    return

  result.res = pluginVersionData.res.canBeDownloadedViaGitHubApi


proc download*(
    plugin: ref Plugin
): Result[void] =
  ## プラグインをダウンロードする
  result = result.typeof()()

  # プラグインのバージョンデータを取得する
  let pluginVersionDataRes = plugin.versionData
  if pluginVersionDataRes.err.isSome:
    result.err = pluginVersionDataRes.err
    return

  let res = newGitHubApi().downloadPlugin(plugin, "temp.zip")
  if res.err.isSome:
    result.err = res.err
    return

