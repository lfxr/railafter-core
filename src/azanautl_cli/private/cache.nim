import
  options,
  os

import
  zippy/ziparchives

import
  packages,
  procs,
  types


const UnextracedZipFileName = "unextracted.zip"


type Cache* = object
  packages: ref Packages
  dirPath: string


type CachePlugins = object
  cache: ref Cache
  dirPath: string


type CachePlugin = object
  cache: ref Cache
  plugin: Plugin
  dirPath: string


proc newCache*(packagesFilePath, dirPath: string): ref Cache =
  result = new Cache
  result.packages = newPackages(packagesFilePath)
  result.dirPath = dirPath


func plugins*(cache: ref Cache): CachePlugins =
  result.cache = cache
  result.dirPath = cache.dirPath / "plugins"


func plugin*(cache: ref Cache, plugin: Plugin): CachePlugin =
  result.cache = cache
  result.plugin = plugin
  result.dirPath = cache.plugins.dirPath / plugin.id / plugin.version


proc cache*(
    cachePlugins: CachePlugins,
    plugin: Plugin,
    zipFilePath: string
): Result[void] =
  result = result.typeof()()
  let
    packages = cachePlugins.cache.packages
    pluginVersionCacheDirPath = cachePlugins.dirPath / plugin.id / plugin.version
    pluginVersionCacheExtractedDirPath = pluginVersionCacheDirPath / "extracted"
    expectedHashValue =
      packages.plugin(plugin.id).version(plugin.version).sha3_512_hash
    actualHashValue = sha3_512File(zipFilePath)

  # ZIPファイルのハッシュ値を検証
  if expectedHashValue != actualHashValue:
    result.err = option(
       Error(
         kind: invalidZipFileHashValueError,
         zipFilePath: zipFilepath,
         expectedHashValue: expectedHashValue,
         actualHashValue: actualHashValue
       )
    )
    return
  # ZIPファイルのコピー先ディレクトリを作成
  createDir(pluginVersionCacheDirPath)

  # ZIPファイルをコピー
  copyFile(zipFilePath, pluginVersionCacheDirPath / "unextracted.zip")

  # ZIPファイルを展開して生成されたファイル群を, 展開先ディレクトリにコピー
  extractAll(zipFilePath, pluginVersionCacheExtractedDirPath)


proc apply*(cachePlugin: CachePlugin, destDirPath: string): Result[void] =
  ## プラグインのキャッシュを適用する
  let
    packages = cachePlugin.cache.packages
    plugin = cachePlugin.plugin
    expectedHashValue =
      packages.plugin(plugin.id).version(plugin.version).sha3_512_hash
    actualHashValue = sha3_512File(cachePlugin.dirPath)

  # ZIPファイルのハッシュ値を検証
  if expectedHashValue != actualHashValue:
    result.err = option(
       Error(
         kind: invalidZipFileHashValueError,
         zipFilePath: cachePlugin.dirPath,
         expectedHashValue: expectedHashValue,
         actualHashValue: actualHashValue
       )
    )
    return

  # ZIPファイルをコピー
  copyFile(
    cachePlugin.dirPath / UnextracedZipFileName,
    destDirPath / UnextracedZipFileName
  )

