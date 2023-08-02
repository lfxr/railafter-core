import
  options,
  os,
  sequtils

import
  types


const CacheYamlFileName = "image.yaml"


type PluginCache* = object
  cachesDirPath, pluginCachesDirPath, dirPath, path: string
  plugin: ref Plugin


func newPluginCache*(
    cachesDirPath: string,
    plugin: ref Plugin
): ref PluginCache =
  result = new PluginCache
  result.cachesDirPath = cachesDirPath
  result.pluginCachesDirPath = cachesDirPath / "plugins"
  result.dirPath = result.pluginCachesDirPath / plugin.id
  result.path = result.dirPath / plugin.version
  result.plugin = plugin


func doesExist*(pluginCache: ref PluginCache): bool =
  ## キャッシュが存在するかどうかを返す
  result = fileExists(pluginCache.path)
