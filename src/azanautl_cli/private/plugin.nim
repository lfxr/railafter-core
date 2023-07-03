import
  options,
  sequtils

import
  packages_yaml,
  types


type Plugin* = object
  packagesYamlFilePath*: string
  id*, version*: string


func newPlugin*(
    id: string,
    version: string = "",
    packagesYamlFilePath: string = "",
): ref Plugin =
  result = new Plugin
  result.id = id
  result.version = version
  result.packagesYamlFilePath = packagesYamlFilePath


func doesExist*(plugin: ref Plugin): bool =
  ## プラグインが存在するかどうかを返す
  result = true


proc packageInfo(plugin: ref Plugin): Result[PackagesYamlPlugin] =
  ## プラグインのパッケージ情報を返す
  result = result.typeof()()

  if not plugin.doesExist:
    result.err = option(Error(
      kind: pluginDoesNotExistError,
      pPluginId: plugin.id,
    ))
    return
  
  block:
    let
      reader = newPackagesYamlFileReader(plugin.packagesYamlFilePath)
      packagesYaml = reader.read()

    if packagesYaml.err.isSome:
      result.err = packagesYaml.err
      return

    let packagesYamlPlugins = packagesYaml.res.plugins
    result.res = packagesYamlPlugins.filterIt(it.id == plugin.id)[0]


proc versionData*(plugin: ref Plugin): Result[PackagesYamlPluginVersion] =
  ## プラグインのバージョン情報を返す
  result = result.typeof()()

  if not plugin.doesExist:
    result.err = option(Error(
      kind: pluginDoesNotExistError,
      pPluginId: plugin.id,
    ))
    return

  result.res =
    plugin.packageInfo.res.versions.filterIt(it.version == plugin.version)[0]
