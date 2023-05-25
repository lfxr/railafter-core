import
  options,
  os

import
  zippy/ziparchives

import
  packages,
  procs,
  types


type Cache = object
  packages: ref Packages
  dirPath: string


type CachePlugins = object
  cache: ref Cache
  dirPath: string


proc newCache*(packagesFilePath, dirPath: string): ref Cache =
  result = new Cache
  result.packages = newPackages(packagesFilePath)
  result.dirPath = dirPath


func plugins*(cache: ref Cache): CachePlugins =
  result.cache = cache
  result.dirPath = cache.dirPath / "plugins"


proc cache*(
    cachePlugins: CachePlugins,
    plugin: Plugin,
    zipFilePath: string
): Result[void] =
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

  # ZIPファイルをコピー
  copyFile(zipFilePath, pluginVersionCacheDirPath / "unextracted.zip")

  # ZIPファイルを展開して生成されたファイル群を, 作成した展開先ディレクトリにコピー
  createDir(pluginVersionCacheExtractedDirPath)
  extractAll(zipFilePath, pluginVersionCacheExtractedDirPath)

