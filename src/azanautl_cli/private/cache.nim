import
  options,
  os

import
  zippy/ziparchives

import
  packages,
  procs,
  types


const
  ExtractedDirName = "extracted"
  UnextracedZipFileName = "unextracted.zip"


type Cache* = object
  packages: ref Packages
  dirPath: string


type CacheBases = object
  cache: ref Cache
  dirPath: string


type CacheBasis = object
  cache: ref Cache
  basis: Basis
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
  ## cache.pluginsコマンド
  result.cache = cache
  result.dirPath = cache.dirPath / "plugins"


func plugin*(cache: ref Cache, plugin: Plugin): CachePlugin =
  ## cache.pluginコマンド
  result.cache = cache
  result.plugin = plugin
  result.dirPath = cache.plugins.dirPath / plugin.id / plugin.version


proc cache*(
    cachePlugins: CachePlugins,
    plugin: Plugin,
    zipFilePath: string
): Result[void] =
  ## プラグインをキャッシュする
  result = result.typeof()()
  let
    packages = cachePlugins.cache.packages
    pluginVersionCacheDirPath = cachePlugins.dirPath / plugin.id / plugin.version
    pluginVersionCacheExtractedDirPath = pluginVersionCacheDirPath / ExtractedDirName
    expectedHashValue =
      packages.plugin(plugin.id).version(plugin.version).sha3_512_hash
    actualHashValue = sha3_512File(zipFilePath)

  if actualHashValue.err.isSome:
    result.err = actualHashValue.err
    return

  # ZIPファイルのハッシュ値を検証
  if expectedHashValue != actualHashValue.res:
    result.err = option(
       Error(
         kind: invalidZipFileHashValueError,
         zipFilePath: zipFilepath,
         expectedHashValue: expectedHashValue,
         actualHashValue: actualHashValue.res
       )
    )
    return
  # ZIPファイルのコピー先ディレクトリを作成
  createDir(pluginVersionCacheDirPath)

  # ZIPファイルをコピー
  copyFile(zipFilePath, pluginVersionCacheDirPath / UnextracedZipFileName)

  # ZIPファイルを展開して生成されたファイル群を, 展開先ディレクトリにコピー
  extractAll(zipFilePath, pluginVersionCacheExtractedDirPath)


func exists*(cachePlugin: CachePlugin): bool =
  ## プラグインのキャッシュが存在するかどうかを返す
  dirExists(cachePlugin.dirPath)


proc apply*(cachePlugin: CachePlugin, destFilePath: string): Result[void] =
  ## プラグインのキャッシュを適用する
  result = result.typeof()()
  let
    packages = cachePlugin.cache.packages
    plugin = cachePlugin.plugin
    expectedHashValue =
      packages.plugin(plugin.id).version(plugin.version).sha3_512_hash
    actualHashValue = sha3_512File(cachePlugin.dirPath / UnextracedZipFileName)

  if actualHashValue.err.isSome:
    result.err = actualHashValue.err
    return

  # ZIPファイルのハッシュ値を検証
  if expectedHashValue != actualHashValue.res:
    result.err = option(
       Error(
         kind: invalidZipFileHashValueError,
         zipFilePath: cachePlugin.dirPath,
         expectedHashValue: expectedHashValue,
         actualHashValue: actualHashValue.res
       )
    )
    return

  # ZIPファイルをコピー
  copyFile(
    cachePlugin.dirPath / UnextracedZipFileName,
    destFilePath
  )


func bases*(cache: ref Cache): CacheBases =
  ## cache.basesコマンド
  result.cache = cache
  result.dirPath = cache.dirPath / "bases"


func basis*(cache: ref Cache, basis: Basis): CacheBasis =
  ## cache.basisコマンド
  result.cache = cache
  result.basis = basis
  result.dirPath = cache.bases.dirPath / basis.id / basis.version


proc cache*(
    cacheBases: CacheBases,
    basis: Basis,
    zipFilePath: string
): Result[void] =
  ## 基盤をキャッシュする
  result = result.typeof()()
  let
    packages = cacheBases.cache.packages
    basisVersionCacheDirPath = cacheBases.dirPath / basis.id / basis.version
    basisVersionCacheExtractedDirPath = basisVersionCacheDirPath / ExtractedDirName
    expectedHashValue =
      packages.basis(basis.id).version(basis.version).sha3_512_hash
    actualHashValue = sha3_512File(zipFilePath)

  if actualHashValue.err.isSome:
    result.err = actualHashValue.err
    return

  # ZIPファイルのハッシュ値を検証
  if expectedHashValue != actualHashValue.res:
    result.err = option(
       Error(
         kind: invalidZipFileHashValueError,
         zipFilePath: zipFilepath,
         expectedHashValue: expectedHashValue,
         actualHashValue: actualHashValue.res
       )
    )
    return

  # ZIPファイルのコピー先ディレクトリを作成
  createDir(basisVersionCacheDirPath)

  # ZIPファイルをコピー
  copyFile(zipFilePath, basisVersionCacheDirPath / UnextracedZipFileName)

  # ZIPファイルを展開して生成されたファイル群を, 展開先ディレクトリにコピー
  extractAll(zipFilePath, basisVersionCacheExtractedDirPath)


func exists*(cacheBasis: CacheBasis): bool =
  ## 基盤のキャッシュが存在するかどうかを返す
  dirExists(cacheBasis.dirPath)


proc apply*(cacheBasis: CacheBasis, destFilePath: string): Result[void] =
  ## 基盤のキャッシュを適用する
  result = result.typeof()()
  let
    packages = cacheBasis.cache.packages
    basis = cacheBasis.basis
    expectedHashValue =
      packages.basis(basis.id).version(basis.version).sha3_512_hash
    actualHashValue = sha3_512File(cacheBasis.dirPath / UnextracedZipFileName)

  if actualHashValue.err.isSome:
    result.err = actualHashValue.err
    return

  # ZIPファイルのハッシュ値を検証
  if expectedHashValue != actualHashValue.res:
    result.err = option(
       Error(
         kind: invalidZipFileHashValueError,
         zipFilePath: cacheBasis.dirPath,
         expectedHashValue: expectedHashValue,
         actualHashValue: actualHashValue.res
       )
    )
    return

  # ZIPファイルをコピー
  copyFile(
    cacheBasis.dirPath / UnextracedZipFileName,
    destFilePath
  )

