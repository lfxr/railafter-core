import
  options,
  sequtils

import
  packages_yaml,
  types


type Plugin* = object
  packagesYamlFilePath*: string
  id*, version*: string
  packagesYaml: PackagesYaml


# プロトタイプ宣言
proc loadPackagesYaml(plugin: ref Plugin): Result[void]
func versionData*(plugin: ref Plugin): Result[PackagesYamlPluginVersion]


proc init(plugin: ref Plugin): Result[void] =
  ## Pluginオブジェクトのコンストラクタ
  result = result.typeof()()

  let res = plugin.loadPackagesYaml()
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


proc loadPackagesYaml(plugin: ref Plugin): Result[void] =
  ## プラグインのパッケージ情報を読み込む
  result = result.typeof()()

  let
    reader = newPackagesYamlFileReader(plugin.packagesYamlFilePath)
    packagesYaml = reader.read()

  if packagesYaml.err.isSome:
    result.err = packagesYaml.err
    return

  plugin.packagesYaml = packagesYaml.res


func doesExist*(plugin: ref Plugin): bool =
  ## プラグインが存在するかどうかを返す
  plugin.packagesYaml.plugins.filterIt(it.id == plugin.id).len != 0


func canBeDownloadedViaGitHubApi*(plugin: ref Plugin): Result[bool] =
  ## GitHub API 経由でプラグインをダウンロードできるかどうかを返す
  result = result.typeof()()

  if not plugin.doesExist:
    result.err = option(Error(
      kind: pluginDoesNotExistError,
      pPluginId: plugin.id,
    ))
    return

  let pluginVersionData = plugin.versionData()
  if pluginVersionData.err.isSome:
    result.err = pluginVersionData.err
    return

  result.res = pluginVersionData.res.canBeDownloadedViaGitHubApi


func packageInfo*(plugin: ref Plugin): Result[PackagesYamlPlugin] =
  ## プラグインのパッケージ情報を返す
  result = result.typeof()()

  if not plugin.doesExist:
    result.err = option(Error(
      kind: pluginDoesNotExistError,
      pPluginId: plugin.id,
    ))
    return
  
  result.res = plugin.packagesYaml.plugins.filterIt(it.id == plugin.id)[0]


func versionData*(plugin: ref Plugin): Result[PackagesYamlPluginVersion] =
  ## プラグインのバージョン情報を返す
  result = result.typeof()()

  if not plugin.doesExist:
    result.err = option(Error(
      kind: pluginDoesNotExistError,
      pPluginId: plugin.id,
    ))
    return

  let matchedPlugins = plugin.packageInfo.res.versions.filterIt(
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
